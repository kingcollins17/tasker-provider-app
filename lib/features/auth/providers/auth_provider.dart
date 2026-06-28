import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';
import 'dart:ui';
import '../../../core/api/users_client.dart';
import '../../../core/models/models.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/utils/app_exception_handler.dart';
import '../../../core/utils/extensions/error_ext.dart';

/// A Riverpod Notifier managing authentication state and actions.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    final token = await appStorage.get<String>(HiveKeys.accessToken.name);
    if (token == null) return null;
    try {
      final response = await ref.read(usersClientProvider).getMe();
      if (response.isSuccessful && response.data != null) {
        return response.data!;
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      // In case token is invalid/expired, delete it
      await appStorage.delete(HiveKeys.accessToken.name);
    }
    return null;
  }

  /// Authenticates a user using credentials.
  Future<void> login(
    String username,
    String password, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final response = await ref
          .read(usersClientProvider)
          .login(username: username, password: password);

      final token = response.accessToken;
      if (token != null) {
        await appStorage.save(HiveKeys.accessToken.name, token);
        ref.invalidateSelf();
        await future;
        onSuccess?.call();
      } else {
        final errMsg = 'Access token missing in response payload.';
        throw (errMsg);
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Registers a new user.
  Future<void> signup(
    RegisterRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final response = await ref.read(usersClientProvider).register(request);
      if (response.isSuccessful) {
        onSuccess?.call();
      } else {
        onError?.call(response.detail ?? 'Registration failed.');
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Logs out the user by clearing credentials.
  Future<void> logout({
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      await appStorage.delete(HiveKeys.accessToken.name);
      ref.invalidateSelf();
      await future;
      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> requestEmailOtp(
    String email, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final response = await ref
          .read(usersClientProvider)
          .requestEmailOtp(RequestEmailOtpRequest(email: email));
      if (response.isSuccessful) {
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to request email OTP.');
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> requestPhoneOtp(
    String phoneNumber, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final response = await ref
          .read(usersClientProvider)
          .requestPhoneOtp(RequestPhoneOtpRequest(phoneNumber: phoneNumber));
      if (response.isSuccessful) {
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to request phone OTP.');
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  Future<bool> verifyEmail(
    String email,
    String code, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final response = await ref
          .read(usersClientProvider)
          .verifyEmail(VerifyEmailRequest(email: email, code: code));
      if (response.isSuccessful) {
        onSuccess?.call();
        return true;
      } else {
        throw (response.detail ?? 'Failed to verify email.');
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
      return false;
    }
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    String code, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final response = await ref
          .read(usersClientProvider)
          .verifyPhone(
            VerifyPhoneRequest(phoneNumber: phoneNumber, code: code),
          );
      if (response.isSuccessful) {
        onSuccess?.call();
      } else {
        throw (response.detail ?? 'Failed to verify phone number.');
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

/// Provider to read and interact with authentication state.
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});
