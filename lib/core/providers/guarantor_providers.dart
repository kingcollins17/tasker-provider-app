import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/core/utils/retry_util.dart';

import '../api/users_client.dart';
import '../models/models.dart';
import '../utils/app_exception_handler.dart';
import '../utils/debug_logger.dart';
import '../utils/extensions/error_ext.dart';

/// AsyncNotifier for managing Guarantor status and handling submission/resubmission mutations.
class GuarantorNotifier extends AsyncNotifier<Guarantor?> {
  @override
  Future<Guarantor?> build() async {
    return _fetchGuarantor();
  }

  Future<Guarantor?> _fetchGuarantor() async {
    try {
      debugLog('[GuarantorNotifier] Fetching latest guarantor details...');
      final client = ref.watch(usersClientProvider);
      final response = await client.getLatestGuarantor();

      if (response.isSuccessful && response.hasData) {
        debugLog('[GuarantorNotifier] Guarantor details fetched successfully');
        return response.data;
      }
    } catch (e, st) {
      debugLog('[GuarantorNotifier] Error fetching guarantor: $e', level: DebugLevel.error);
      AppExceptionHandler.instance.handleError(e, st);
    }
    return null;
  }

  /// Submits initial guarantor details.
  Future<void> submitGuarantor(
    GuarantorRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog('[GuarantorNotifier.submitGuarantor] Submitting guarantor...');
      final client = ref.read(usersClientProvider);
      final response = await client.addGuarantor(request);

      if (response.isSuccessful) {
        debugLog('[GuarantorNotifier.submitGuarantor] Guarantor submitted successfully');
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.errorMessage ?? response.detailMessage ?? 'Failed to submit guarantor details');
      }
    } catch (e, st) {
      debugLog(
        '[GuarantorNotifier.submitGuarantor] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Resubmits guarantor details following a failed verification.
  Future<void> resubmitGuarantor(
    GuarantorRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog('[GuarantorNotifier.resubmitGuarantor] Resubmitting guarantor...');
      final client = ref.read(usersClientProvider);
      final response = await client.resubmitGuarantor(request);

      if (response.isSuccessful) {
        debugLog('[GuarantorNotifier.resubmitGuarantor] Guarantor resubmitted successfully');
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.errorMessage ?? response.detailMessage ?? 'Failed to resubmit guarantor details');
      }
    } catch (e, st) {
      debugLog(
        '[GuarantorNotifier.resubmitGuarantor] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

/// Main Provider for [GuarantorNotifier].
final guarantorNotifierProvider =
    AsyncNotifierProvider<GuarantorNotifier, Guarantor?>(
  () => GuarantorNotifier(),
  retry: retryFunc(3),
);

/// Convenience FutureProvider for watching the current [Guarantor] state.
final guarantorProvider = FutureProvider<Guarantor?>((ref) async {
  return ref.watch(guarantorNotifierProvider.future);
});
