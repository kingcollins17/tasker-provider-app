import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../api/tasks_client.dart';
import '../utils/app_exception_handler.dart';
import '../utils/extensions/error_ext.dart';
import 'tasks_provider.dart';

class BidManagementNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submitBid(
    String taskId,
    CreateBidRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.submitBid(taskId, request);

      if (response.data == null) {
        throw Exception(response.detail ?? 'Failed to submit bid');
      }

      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);

      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> updateBid(
    String bidId,
    CreateBidRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.updateBid(bidId, request);

      if (response.data == null) {
        throw Exception(response.detail ?? 'Failed to update bid');
      }

      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);

      onError?.call(e.toFriendlyString());
    }
  }

  Future<void> withdrawBid(
    String bidId, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.withdrawBid(bidId);

      if (response.data == null) {
        throw Exception(response.detail ?? 'Failed to withdraw bid');
      }

      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);

      onError?.call(e.toFriendlyString());
    }
  }
}

final bidManagementProvider =
    AsyncNotifierProvider<BidManagementNotifier, void>(
      BidManagementNotifier.new,
    );

final myBidProvider = FutureProvider.family<TaskBid?, String>((
  ref,
  taskId,
) async {
  final client = ref.read(tasksClientProvider);
  try {
    final response = await client.getMyBidForTask(taskId);
    return response.data;
  } catch (e) {
    return null;
  }
});
