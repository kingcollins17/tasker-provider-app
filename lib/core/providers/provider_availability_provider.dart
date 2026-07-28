import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api.dart';
import '../models/models.dart';
import '../utils/app_exception_handler.dart';
import '../utils/extensions/error_ext.dart';

/// Notifier managing the authenticated provider's weekly availability schedule.
class ProviderAvailabilityNotifier
    extends AsyncNotifier<List<ProviderAvailability>> {
  @override
  Future<List<ProviderAvailability>> build() async {
    return _fetchAvailability();
  }

  Future<List<ProviderAvailability>> _fetchAvailability() async {
    final client = ref.watch(usersClientProvider);
    final response = await client.getProviderAvailability();

    if (response.isError) {
      throw Exception(
        response.detail ?? 'Failed to fetch provider availability',
      );
    }

    return response.data ?? [];
  }

  /// Replaces the weekly availability schedule for the authenticated provider.
  Future<void> updateAvailability(
    List<AvailabilityBlock> blocks, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(usersClientProvider);
      final response = await client.updateProviderAvailability(
        UpdateAvailabilityRequest(availabilityBlocks: blocks),
      );

      if (response.isSuccessful) {
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to update provider availability');
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

/// Provider exposing [ProviderAvailabilityNotifier] and the provider's availability list.
final providerAvailabilityProvider = AsyncNotifierProvider<
  ProviderAvailabilityNotifier,
  List<ProviderAvailability>
>(ProviderAvailabilityNotifier.new);
