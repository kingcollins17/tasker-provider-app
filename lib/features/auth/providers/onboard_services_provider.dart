import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/app_exception_handler.dart';
import '../../../core/utils/extensions/error_ext.dart';
import 'auth_provider.dart';

/// AsyncNotifier provider tracking whether a user has onboarded their services.
class OnboardedServicesNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    final userId = _getUserId();
    if (userId == null || userId.isEmpty) {
      return false;
    }
    final key = '$userId::hasOnboardedServices';
    final storedValue = await appStorage.get<bool>(key);
    if (storedValue != null) {
      return storedValue;
    }

    final user = ref.watch(userProvider).value ?? ref.watch(authProvider).value;
    return (user?.services ?? []).isNotEmpty;
  }

  String? _getUserId() {
    return ref.watch(userProvider).value?.id ??
        ref.watch(authProvider).value?.id;
  }

  /// Sets the onboarding status for services and persists to appStorage.
  Future<void> setHasOnboardedServices(
    bool value, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final userId = ref.read(userProvider).value?.id ??
          ref.read(authProvider).value?.id;
      if (userId != null && userId.isNotEmpty) {
        final key = '$userId::hasOnboardedServices';
        await appStorage.save(key, value);
      }
      state = AsyncData(value);
      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Convenience method for setting onboarded services status.
  Future<void> setOnboardedServices(
    bool value, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    return setHasOnboardedServices(
      value,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

/// Provider to read and interact with service onboarding status.
final onboardedServicesProvider =
    AsyncNotifierProvider<OnboardedServicesNotifier, bool>(() {
  return OnboardedServicesNotifier();
});

/// Alias provider for hasOnboardedServices.
final hasOnboardedServicesProvider = onboardedServicesProvider;
