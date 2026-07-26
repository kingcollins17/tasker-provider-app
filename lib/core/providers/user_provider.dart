import 'dart:io';
import 'dart:ui';
import 'dart:async';
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
      final response = await client.addProviderService(
        AddServiceRequest(serviceId: serviceId),
      );
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

  Future<void> submitSelfie(
    File selfie, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(usersClientProvider);
      final response = await client.submitKycSelfie(selfie: selfie);
      if (response.isSuccessful) {
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to submit selfie');
      }
    } catch (e, st) {
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
      final client = ref.read(usersClientProvider);
      final response = await client.submitKycDocument(
        idType: idType,
        idNumber: idNumber,
        idDoc: idDoc,
      );
      if (response.isSuccessful) {
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to submit document');
      }
    } catch (e, st) {
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
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to update profile');
      }
    } catch (e, st) {
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
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to update payout account');
      }
    } catch (e, st) {
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
      final client = ref.read(usersClientProvider);
      final response = await client.updateOnlineStatus(
        UpdateOnlineStatusRequest(isOnline: isOnline),
      );
      if (response.isSuccessful) {
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to update online status');
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

final syncRegionProvider = FutureProvider<void>((ref) async {
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

// Is user online
final isOnlineProvider = FutureProvider<bool>((ref) {
  final isOnline = ref.watch(
    userProvider.selectAsync((user) => user.providerProfile?.isOnline ?? false),
  );
  return isOnline;
});

final pingLocationProvider = Provider<void>((ref) {
  final isOnline = ref.watch(isOnlineProvider).value ?? false;

  if (isOnline) {
    void ping() async {
      try {
        final address = await ref.read(userAddressProvider.future);
        if (address.coordinates?.latitude != null &&
            address.coordinates?.longitude != null) {
          final client = ref.read(usersClientProvider);
          await client.pingLocation(
            PingLocationRequest(
              latitude: address.coordinates!.latitude!,
              longitude: address.coordinates!.longitude!,
            ),
          );
        }
      } catch (e, st) {
        AppExceptionHandler.instance.handleError(e, st);
      }
    }

    // Ping immediately when going online
    ping();

    final timer = Timer.periodic(const Duration(minutes: 2), (_) {
      ping();
    });

    ref.onDispose(() {
      timer.cancel();
    });
  }
});
// KYC Providers
final hasSelfieProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(userProvider.future);
  return user.providerProfile?.selfieUrl != null;
});

enum KycStatus { pending, submitted, underReview, approved, rejected }

final kycStatusProvider = FutureProvider<KycStatus>((ref) async {
  final user = await ref.watch(userProvider.future);
  final status = user.providerProfile?.status;
  return switch (status?.toLowerCase().trim()) {
    "pending_submission" || "pending" => KycStatus.pending,
    "submitted" => KycStatus.submitted,
    "pending_admin_review" ||
    "review" ||
    "under_review" => KycStatus.underReview,
    "approved" || "success" || "verified" => KycStatus.approved,
    "rejected" || "failed" => KycStatus.rejected,
    _ => KycStatus.pending,
  };
});

final documentRejectionReasonProvider = FutureProvider<String?>((ref) async {
  final user = await ref.watch(userProvider.future);
  return user.providerProfile?.rejectionReason;
});
