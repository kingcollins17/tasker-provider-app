import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/core/utils/retry_util.dart';
import '../api/users_client.dart';
import '../models/models.dart';

/// Provider for retrieving scheduled interview details for the current provider.
final interviewProvider = FutureProvider<Interview?>((ref) async {
  final client = ref.watch(usersClientProvider);
  final response = await client.getMyInterview();

  if (response.isSuccessful && response.hasData) {
    return response.data;
  }
  return null;
}, retry: retryFunc(3));
