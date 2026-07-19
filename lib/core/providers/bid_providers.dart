import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../api/tasks_client.dart';
import '../utils/app_exception_handler.dart';
import '../utils/extensions/error_ext.dart';
import 'tasks_provider.dart';

class SubmitBidNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submitBid(
    String taskId,
    CreateBidRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.submitBid(taskId, request);

      if (response.data == null) {
        throw Exception(response.detail ?? 'Failed to submit bid');
      }

      state = const AsyncValue.data(null);
      ref.invalidate(taskDetailProvider(taskId));
      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      state = AsyncValue.error(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

final submitBidProvider = AsyncNotifierProvider<SubmitBidNotifier, void>(
  SubmitBidNotifier.new,
);
