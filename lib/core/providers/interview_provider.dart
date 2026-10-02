import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/core/utils/retry_util.dart';
import 'package:tasker_app/features/auth/providers/auth_provider.dart';
import '../api/users_client.dart';
import '../models/models.dart';
import '../utils/debug_logger.dart';

/// Provider for retrieving scheduled interview details for the current provider.
final interviewProvider = FutureProvider<Interview?>((ref) async {
  try {
    ref.watch(isAuthenticatedProvider);
    final client = ref.watch(usersClientProvider);
    final response = await client.getMyInterview();

    if (response.isSuccessful && response.hasData) {
      return response.data;
    }
  } catch (e) {
    debugLog('[interviewProvider] Error fetching interview: $e');
  }
  return null;
}, retry: retryFunc(3));

