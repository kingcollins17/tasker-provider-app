import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../api/api.dart';
import '../models/models.dart';
import 'region_provider.dart';
import 'location_provider.dart';
import '../utils/app_exception_handler.dart';
import '../utils/debug_logger.dart';
import '../utils/extensions/error_ext.dart';

class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    return _fetchUser();
  }

  Future<User> _fetchUser() async {
    debugLog('[UserNotifier] Fetching user profile...');
    final client = ref.watch(usersClientProvider);
    final response = await client.getMe();

    if (response.data == null) {
      debugLog(
        '[UserNotifier] User data returned null',
        level: DebugLevel.error,
      );
      throw Exception('User data is null');
    }

    debugLog('[UserNotifier] User profile loaded successfully');
    return response.data!;
  }

  Future<void> addService(
    String serviceId, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog('[UserNotifier.addService] Adding service: $serviceId');
      final client = ref.read(usersClientProvider);
      final response = await client.addProviderService(
        AddServiceRequest(serviceId: serviceId),
      );
      if (response.isSuccessful) {
        debugLog('[UserNotifier.addService] Service added successfully');
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to add service');
      }
    } catch (e, st) {
      debugLog('[UserNotifier.addService] Error: $e', level: DebugLevel.error);
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
      debugLog('[UserNotifier.removeService] Removing service: $serviceId');
      final client = ref.read(usersClientProvider);
      final response = await client.removeProviderService(serviceId);
      if (response.isSuccessful) {
        debugLog('[UserNotifier.removeService] Service removed successfully');
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to remove service');
      }
    } catch (e, st) {
      debugLog(
        '[UserNotifier.removeService] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> submitSelfie(
    File selfie, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog('[UserNotifier.submitSelfie] Submitting selfie image...');
      final client = ref.read(usersClientProvider);
      final response = await client.submitKycSelfie(selfie: selfie);
      if (response.isSuccessful) {
        debugLog('[UserNotifier.submitSelfie] Selfie submitted successfully');
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to submit selfie');
      }
    } catch (e, st) {
      debugLog(
        '[UserNotifier.submitSelfie] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> submitDocument({
    required String idType,
    required String idNumber,
    required File idDoc,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog(
        '[UserNotifier.submitDocument] Submitting document: type=$idType, number=$idNumber',
      );
      final client = ref.read(usersClientProvider);
      final response = await client.submitKycDocument(
        idType: idType,
        idNumber: idNumber,
        idDoc: idDoc,
      );
      if (response.isSuccessful) {
        debugLog(
          '[UserNotifier.submitDocument] Document submitted successfully',
        );
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to submit document');
      }
    } catch (e, st) {
      debugLog(
        '[UserNotifier.submitDocument] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> updateProviderProfile({
    String? firstName,
    String? lastName,
    String? gender,
    String? phoneNumber,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog(
        '[UserNotifier.updateProviderProfile] Updating profile: firstName=$firstName, lastName=$lastName',
      );
      final client = ref.read(usersClientProvider);
      final response = await client.updateProviderProfile(
        UpdateProviderProfileRequest(
          firstName: firstName,
          lastName: lastName,
          gender: gender,
          phoneNumber: phoneNumber,
        ),
      );
      if (response.isSuccessful) {
        debugLog(
          '[UserNotifier.updateProviderProfile] Profile updated successfully',
        );
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to update profile');
      }
    } catch (e, st) {
      debugLog(
        '[UserNotifier.updateProviderProfile] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> updatePayoutAccount({
    String? bankCode,
    String? bankName,
    String? accountName,
    String? accountNumber,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog(
        '[UserNotifier.updatePayoutAccount] Updating payout account: bank=$bankName, account=$accountNumber',
      );
      final client = ref.read(payoutsClientProvider);
      final response = await client.createOrUpdatePaymentAccount(
        CreatePaymentAccountRequest(
          bankCode: bankCode,
          bankName: bankName,
          accountName: accountName,
          accountNumber: accountNumber,
        ),
      );
      if (response.isSuccessful) {
        debugLog(
          '[UserNotifier.updatePayoutAccount] Payout account updated successfully',
        );
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to update payout account');
      }
    } catch (e, st) {
      debugLog(
        '[UserNotifier.updatePayoutAccount] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> updateOnlineStatus({
    required bool isOnline,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      debugLog(
        '[UserNotifier.updateOnlineStatus] Updating online status to isOnline=$isOnline',
      );
      final client = ref.read(usersClientProvider);
      final response = await client.updateOnlineStatus(
        UpdateOnlineStatusRequest(isOnline: isOnline),
      );
      if (response.isSuccessful) {
        debugLog(
          '[UserNotifier.updateOnlineStatus] Online status updated successfully',
        );
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to update online status');
      }
    } catch (e, st) {
      debugLog(
        '[UserNotifier.updateOnlineStatus] Error: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User>(
  () => UserNotifier(),
);

final updateCloudMessagingTokenProvider = FutureProvider<void>((ref) async {
  try {
    debugLog('[updateCloudMessagingTokenProvider] Updating FCM token...');
    final token = const Uuid().v4();
    final platform = defaultTargetPlatform == TargetPlatform.iOS
        ? 'ios'
        : 'android';
    final client = ref.read(usersClientProvider);
    final response = await client.updateCloudMessagingToken(
      UpdateCloudMessagingTokenRequest(token: token, platform: platform),
    );
    if (!response.isSuccessful) throw response.detail ?? 'Something went wrong';
    debugLog(
      '[updateCloudMessagingTokenProvider] FCM token updated successfully',
    );
  } catch (e, st) {
    debugLog(
      '[updateCloudMessagingTokenProvider] Error updating FCM token: $e',
      level: DebugLevel.error,
    );
    AppExceptionHandler.instance.handleError(e, st);
    rethrow;
  }
});

final syncRegionProvider = FutureProvider<void>((ref) async {
  debugLog('[syncRegionProvider] Syncing user region...');
  final user = await ref.watch(userProvider.future);
  final currentRegion = await ref.watch(currentRegionProvider.future);

  if (currentRegion != null && currentRegion.id != null) {
    if (user.regionId != null && user.regionId != currentRegion.id) {
      debugLog(
        '[syncRegionProvider] Region mismatch (user.regionId=${user.regionId}, currentRegion.id=${currentRegion.id}). Updating region...',
      );
      final client = ref.read(usersClientProvider);
      await client.updateRegion(
        UpdateRegionRequest(regionId: currentRegion.id!),
      );
      debugLog('[syncRegionProvider] Region updated successfully');
    } else if (user.regionId == null) {
      debugLog(
        '[syncRegionProvider] User regionId is null. Setting region to ${currentRegion.id}...',
      );
      final client = ref.read(usersClientProvider);
      await client.updateRegion(
        UpdateRegionRequest(regionId: currentRegion.id!),
      );
      debugLog('[syncRegionProvider] Region updated successfully');
    } else {
      debugLog('[syncRegionProvider] User region is already up to date');
    }
  } else {
    debugLog('[syncRegionProvider] currentRegion is null or missing id');
  }
});

// Is user online
final isOnlineProvider = FutureProvider<bool>((ref) {
  debugLog('[isOnlineProvider] Reading online status...');
  final isOnline = ref.watch(
    userProvider.selectAsync((user) => user.providerProfile?.isOnline ?? false),
  );
  return isOnline;
});

final pingLocationProvider = Provider<void>((ref) {
  final isOnline = ref.watch(isOnlineProvider).value ?? false;
  debugLog(
    '[pingLocationProvider] Online status evaluated: isOnline=$isOnline',
  );

  if (isOnline) {
    void ping() async {
      try {
        debugLog('[pingLocationProvider] Attempting location ping...');
        final address = await ref.read(userAddressProvider.future);
        if (address.coordinates?.latitude != null &&
            address.coordinates?.longitude != null) {
          debugLog(
            '[pingLocationProvider] Sending ping to backend: lat=${address.coordinates!.latitude}, lng=${address.coordinates!.longitude}',
          );
          final client = ref.read(usersClientProvider);
          await client.pingLocation(
            PingLocationRequest(
              latitude: address.coordinates!.latitude!,
              longitude: address.coordinates!.longitude!,
            ),
          );
          debugLog('[pingLocationProvider] Ping successful');
        } else {
          debugLog(
            '[pingLocationProvider] Ping skipped: coordinates null',
            level: DebugLevel.warn,
          );
        }
      } catch (e, st) {
        debugLog(
          '[pingLocationProvider] Ping failed: $e',
          level: DebugLevel.error,
        );
        AppExceptionHandler.instance.handleError(e, st);
      }
    }

    // Ping immediately when going online
    ping();

    final timer = Timer.periodic(const Duration(minutes: 2), (_) {
      ping();
    });

    ref.onDispose(() {
      debugLog(
        '[pingLocationProvider] Provider disposed, canceling ping timer',
      );
      timer.cancel();
    });
  }
});

// KYC Providers
final hasSelfieProvider = FutureProvider<bool>((ref) async {
  debugLog('[hasSelfieProvider] Checking selfie availability...');
  final user = await ref.watch(userProvider.future);
  final hasSelfie = user.providerProfile?.selfieUrl != null;
  debugLog('[hasSelfieProvider] hasSelfie=$hasSelfie');
  return hasSelfie;
});

enum KycStatus { pending, submitted, underReview, approved, rejected }

final kycStatusProvider = FutureProvider<KycStatus>((ref) async {
  debugLog('[kycStatusProvider] Resolving KYC status...');
  final user = await ref.watch(userProvider.future);
  final status = user.providerProfile?.status;
  final kycStatus = switch (status?.toLowerCase().trim()) {
    "pending_submission" || "pending" => KycStatus.pending,
    "submitted" => KycStatus.submitted,
    "pending_admin_review" ||
    "review" ||
    "under_review" => KycStatus.underReview,
    "approved" || "success" || "verified" => KycStatus.approved,
    "rejected" || "failed" => KycStatus.rejected,
    _ => KycStatus.pending,
  };
  debugLog(
    '[kycStatusProvider] KYC Status resolved to: $kycStatus (raw status="$status")',
  );
  return kycStatus;
});

final documentRejectionReasonProvider = FutureProvider<String?>((ref) async {
  debugLog(
    '[documentRejectionReasonProvider] Checking document rejection reason...',
  );
  final user = await ref.watch(userProvider.future);
  final reason = user.providerProfile?.rejectionReason;
  debugLog('[documentRejectionReasonProvider] Rejection reason: $reason');
  return reason;
});
