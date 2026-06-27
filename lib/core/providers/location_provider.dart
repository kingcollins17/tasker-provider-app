import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:location/location.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Represents the user's geographic coordinates.
class Coordinates {
  final double? latitude;
  final double? longitude;

  const Coordinates({this.latitude, this.longitude});

  @override
  String toString() => 'UserCoordinates($latitude, $longitude)';
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
  final location = ref.watch(locationServiceProvider);

  // 1. Ensure the device's location service is enabled.
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable them in device settings.',
      );
    }
  }

  // 2. Ensure the app has location permission.
  PermissionStatus permission = await location.hasPermission();
  if (permission == PermissionStatus.denied) {
    permission = await location.requestPermission();
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.grantedLimited) {
      throw Exception(
        'Location permission denied. Please grant permission in device settings.',
      );
    }
  }

  if (permission == PermissionStatus.deniedForever) {
    throw Exception(
      'Location permission permanently denied. '
      'Please enable it manually from device settings.',
    );
  }

  // 3. Fetch the current position.
  final locationData = await location.getLocation();

  return Coordinates(
    latitude: locationData.latitude,
    longitude: locationData.longitude,
  );
});

/// Reverse-geocodes the user's coordinates into a readable [Address].
/// Depends on [userCoordinatesProvider], so it waits for coordinates first.
final userAddressProvider = FutureProvider<Address>((ref) async {
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
});

/// Provides a live stream of location updates as the user moves.
///
/// Useful for real-time tracking scenarios. Consumers should use
/// `ref.watch(locationStreamProvider)` to react to position changes.
final locationStreamProvider = StreamProvider<Coordinates>((ref) {
  final location = ref.watch(locationServiceProvider);

  return location.onLocationChanged.map(
    (data) => Coordinates(latitude: data.latitude, longitude: data.longitude),
  );
});
