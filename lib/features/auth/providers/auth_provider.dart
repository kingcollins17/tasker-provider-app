import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/users_client.dart';
import '../../../core/models/models.dart';
import '../../../core/services/local_storage_service.dart';

/// A Riverpod Notifier managing authentication state and actions.
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    final token = await appStorage.get<String>(HiveKeys.accessToken.name);
    if (token == null) return null;
    try {
      final response = await ref.read(usersClientProvider).getMe();
      if (response.isSuccessful && response.data != null) {
        return User.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // In case token is invalid/expired, delete it
      await appStorage.delete(HiveKeys.accessToken.name);
    }
    return null;
  }

  /// Authenticates a user using credentials.
  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(usersClientProvider).login(
            username: username,
            password: password,
          );

      if (response.isSuccessful) {
        final data = response.data;
        String? token;
        if (data is Map) {
          token = data['access_token'] as String?;
        }
        if (token != null) {
          await appStorage.save(HiveKeys.accessToken.name, token);
          // Invalidate/refresh provider to fetch the authenticated user profile
          ref.invalidateSelf();
          await future;
        } else {
          state = AsyncValue.error('Access token missing in response payload.', StackTrace.current);
        }
      } else {
        state = AsyncValue.error(response.detail ?? 'Authentication failed.', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Registers a new user.
  Future<void> signup(RegisterRequest request) async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(usersClientProvider).register(request);
      if (response.isSuccessful) {
        // Registration successful; keep state at null since user has to log in or verify
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(response.detail ?? 'Registration failed.', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Logs out the user by clearing credentials.
  Future<void> logout() async {
    await appStorage.delete(HiveKeys.accessToken.name);
    state = const AsyncValue.data(null);
  }
}

/// Provider to read and interact with authentication state.
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});
