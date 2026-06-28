import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api.dart';
import '../models/models.dart';
import 'region_provider.dart';
import 'location_provider.dart';
import '../utils/app_exception_handler.dart';
import '../utils/extensions/error_ext.dart';
class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    return _fetchUser();
  }

  Future<User> _fetchUser() async {
    final client = ref.watch(usersClientProvider);
    final response = await client.getMe();

    if (response.data == null) {
      throw Exception('User data is null');
    }

    return response.data!;
  }

  Future<void> addService(
    String serviceId, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(usersClientProvider);
      final response = await client.addProviderService(AddServiceRequest(serviceId: serviceId));
      if (response.isSuccessful) {
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to add service');
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> removeService(
    String serviceId, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(usersClientProvider);
      final response = await client.removeProviderService(serviceId);
      if (response.isSuccessful) {
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to remove service');
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User>(
  () => UserNotifier(),
);

final regionSyncerProvider = FutureProvider<void>((ref) async {
  final user = await ref.watch(userProvider.future);
  final currentRegion = await ref.watch(currentRegionProvider.future);

  if (currentRegion != null && currentRegion.id != null) {
    if (user.regionId != null && user.regionId != currentRegion.id) {
      final client = ref.read(usersClientProvider);
      await client.updateRegion(
        UpdateRegionRequest(regionId: currentRegion.id!),
      );
    } else if (user.regionId == null) {
      final client = ref.read(usersClientProvider);
      await client.updateRegion(
        UpdateRegionRequest(regionId: currentRegion.id!),
      );
    }
  }
});

final locationSyncerProvider = FutureProvider<void>((ref) async {
  await ref.watch(userProvider.future);
  final address = await ref.watch(userAddressProvider.future);

  if (address.coordinates?.latitude != null &&
      address.coordinates?.longitude != null) {
    final client = ref.read(usersClientProvider);
    await client.updateLocation(
      UpdateLocationRequest(
        latitude: address.coordinates!.latitude!,
        longitude: address.coordinates!.longitude!,
        addressLine: address.formatted.isNotEmpty ? address.formatted : null,
      ),
    );
  }
});
