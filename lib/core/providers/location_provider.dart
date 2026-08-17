import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:location/location.dart';
import 'package:tasker_app/core/utils/app_exception_handler.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';
import '../api/api.dart';
import '../models/models.dart';
import 'region_provider.dart';
// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Represents the user's geographic coordinates.
class Coordinates {
  final double? latitude;
  final double? longitude;

  const Coordinates({this.latitude, this.longitude});

  @override
  String toString() => 'Coordinates($latitude, $longitude)';
}

/// Represents the user's resolved address alongside raw coordinates.
class Address {
  final Coordinates? coordinates;
  final String? street;
  final String? locality; // city / town
  final String? administrativeArea; // state / region
  final String? postalCode;
  final String? country;

  const Address({
    this.coordinates,
    this.street,
    this.locality,
    this.administrativeArea,
    this.postalCode,
    this.country,
  });

  /// Returns a concise, human-readable address string.
  String get formatted {
    final parts = [
      street,
      locality,
      administrativeArea,
      postalCode,
      country,
    ].where((p) => p != null && p.isNotEmpty);
    return parts.join(', ');
  }

  @override
  String toString() => 'Address($formatted)';
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Exposes a singleton [Location] instance for the whole app.
final locationServiceProvider = Provider<Location>((ref) {
  return Location();
});

/// Fetches the user's current coordinates, handling permission & service
/// checks. Returns an [AsyncValue] so consumers can react to loading /
/// error states.
final userCoordinatesProvider = FutureProvider<Coordinates>((ref) async {
  debugLog('[userCoordinatesProvider] Fetching user coordinates...');
  final location = ref.watch(locationServiceProvider);

  // 1. Ensure the device's location service is enabled.
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    debugLog(
      '[userCoordinatesProvider] Location service disabled. Requesting service...',
    );
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      debugLog(
        '[userCoordinatesProvider] Location service request denied',
        level: DebugLevel.warn,
      );
      throw Exception(
        'Location services are disabled. Please enable them in device settings.',
      );
    }
  }

  // 2. Ensure the app has location permission.
  PermissionStatus permission = await location.hasPermission();
  if (permission == PermissionStatus.denied) {
    debugLog(
      '[userCoordinatesProvider] Location permission denied. Requesting permission...',
    );
    permission = await location.requestPermission();
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.grantedLimited) {
      debugLog(
        '[userCoordinatesProvider] Location permission request denied',
        level: DebugLevel.warn,
      );
      throw Exception(
        'Location permission denied. Please grant permission in device settings.',
      );
    }
  }

  if (permission == PermissionStatus.deniedForever) {
    debugLog(
      '[userCoordinatesProvider] Location permission permanently denied',
      level: DebugLevel.error,
    );
    throw Exception(
      'Location permission permanently denied. '
      'Please enable it manually from device settings.',
    );
  }

  // 3. Fetch the current position.
  final locationData = await location.getLocation();
  debugLog(
    '[userCoordinatesProvider] Location fetched: lat=${locationData.latitude}, lng=${locationData.longitude}',
  );

  return Coordinates(
    latitude: locationData.latitude,
    longitude: locationData.longitude,
  );
});

/// Reverse-geocodes the user's coordinates into a readable [Address].
/// Depends on [userCoordinatesProvider], so it waits for coordinates first.
final userAddressProvider = FutureProvider<Address>((ref) async {
  debugLog('[userAddressProvider] Resolving address...');
  // MOCK: Mock address set to University of Nigeria, Nsukka
  const address = Address(
    coordinates: Coordinates(latitude: 6.8429, longitude: 7.4116),
    street: 'University of Nigeria, Nsukka',
    locality: 'Nsukka',
    administrativeArea: 'Enugu',
    postalCode: '410001',
    country: 'Nigeria',
  );
  debugLog('[userAddressProvider] Returning address: ${address.formatted}');
  return address;

  /*
  final coordinates = await ref.watch(userCoordinatesProvider.future);

  if (coordinates.latitude == null || coordinates.longitude == null) {
    return Address(coordinates: coordinates);
  }

  final placemarks = await placemarkFromCoordinates(
    coordinates.latitude!,
    coordinates.longitude!,
  );

  if (placemarks.isEmpty) {
    return Address(coordinates: coordinates);
  }

  final placemark = placemarks.first;

  return Address(
    coordinates: coordinates,
    street: placemark.street,
    locality: placemark.locality,
    administrativeArea: placemark.administrativeArea,
    postalCode: placemark.postalCode,
    country: placemark.country,
  );
  */
});

/// Provides a live stream of location updates as the user moves.
///
/// Useful for real-time tracking scenarios. Consumers should use
/// `ref.watch(locationStreamProvider)` to react to position changes.
final locationStreamProvider = StreamProvider<Coordinates>((ref) {
  debugLog('[locationStreamProvider] Initialized location stream');
  final location = ref.watch(locationServiceProvider);

  return location.onLocationChanged.map((data) {
    debugLog(
      '[locationStreamProvider] Location changed: lat=${data.latitude}, lng=${data.longitude}',
    );
    return Coordinates(latitude: data.latitude, longitude: data.longitude);
  });
});

/// Syncs the user's current location and region to the backend.
final syncUserLocationProvider = FutureProvider<void>((ref) async {
  try {
    debugLog('[syncUserLocationProvider] Sync process started');
    final address = await ref.watch(userAddressProvider.future);

    if (address.coordinates?.latitude == null ||
        address.coordinates?.longitude == null) {
      debugLog('[syncUserLocationProvider] Skipped: coordinates are null');
      return;
    }

    final region = await ref.watch(currentRegionProvider.future);
    final client = ref.read(usersClientProvider);

    debugLog(
      '[syncUserLocationProvider] Updating location: lat=${address.coordinates!.latitude}, lng=${address.coordinates!.longitude}, address=${address.formatted}, regionId=${region?.id}',
    );

    await client.updateLocation(
      UpdateLocationRequest(
        latitude: address.coordinates!.latitude!,
        longitude: address.coordinates!.longitude!,
        addressLine: address.formatted,
        regionId: region?.id,
      ),
    );
    debugLog('[syncUserLocationProvider] Location successfully updated');
  } catch (e, st) {
    debugLog(
      '[syncUserLocationProvider] Exception occurred: $e',
      level: DebugLevel.error,
    );
    AppExceptionHandler.instance.handleError(e, st);
  }
});
