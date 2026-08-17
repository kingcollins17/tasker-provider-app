import 'dart:async';
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

    final availabilityList = response.data ?? [];
    if (availabilityList.isEmpty) {
      unawaited(
        client.createDefaultProviderAvailability().then((res) {
          if (res.isSuccessful) {
            ref.invalidateSelf();
          }
        }).catchError((e, st) {
          AppExceptionHandler.instance.handleError(e, st);
        }),
      );
    }

    return availabilityList;
  }

  /// Updates a single availability block by ID.
  Future<void> updateAvailabilityBlock(
    String availabilityId, {
    String? startTime,
    String? endTime,
    bool? isActive,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(usersClientProvider);
      final response = await client.updateProviderAvailability(
        availabilityId,
        UpdateAvailabilityRequest(
          startTime: startTime,
          endTime: endTime,
          isActive: isActive,
        ),
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

  /// Updates multiple availability blocks by ID.
  Future<void> updateAvailabilityBlocks(
    List<({String id, String? startTime, String? endTime, bool? isActive})> items, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(usersClientProvider);
      for (final item in items) {
        final response = await client.updateProviderAvailability(
          item.id,
          UpdateAvailabilityRequest(
            startTime: item.startTime,
            endTime: item.endTime,
            isActive: item.isActive,
          ),
        );

        if (!response.isSuccessful) {
          throw (response.detail ?? 'Failed to update provider availability');
        }
      }

      ref.invalidateSelf();
      await future;
      onSuccess?.call();
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
