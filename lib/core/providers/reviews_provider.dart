import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api.dart';
import '../models/models.dart';
import '../utils/app_exception_handler.dart';
import '../utils/debug_logger.dart';
import '../utils/extensions/error_ext.dart';
import '../utils/retry_util.dart';

/// AsyncNotifier managing the list of pending provider reviews.
class PendingProviderReviewsNotifier
    extends AsyncNotifier<List<PendingProviderReviewItem>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;
  int get currentPage => _page;
  int get perPage => _perPage;

  @override
  Future<List<PendingProviderReviewItem>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPage(1);
  }

  Future<List<PendingProviderReviewItem>> _fetchPage(int page) async {
   final client = ref.read(reviewsClientProvider);
    final response = await client.getPendingProviderReviews(
      page: page,
      perPage: _perPage,
    );

    
    if (response.isError || response.data == null) {
      throw Exception(response.detail ?? 'Failed to load pending reviews');
    }

    final items = response.data!.items ?? [];
    if (items.length < _perPage) {
      _hasMore = false;
    }
    debugLog(items);
    return items;
  }

  /// Refreshes the pending reviews list.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Loads the next page of pending reviews and appends them to current state.
  Future<void> loadMore() async {
    if (state.isLoading || state.hasError || !_hasMore) return;

    final currentItems = state.value ?? [];

    state = await AsyncValue.guard(() async {
      _page++;
      final nextItems = await _fetchPage(_page);
      return [...currentItems, ...nextItems];
    });
  }
}

/// AsyncNotifierProvider exposing the list of pending provider reviews.
final pendingProviderReviewsProvider = AsyncNotifierProvider<
    PendingProviderReviewsNotifier, List<PendingProviderReviewItem>>(
  PendingProviderReviewsNotifier.new,
  retry: retryFunc(3),
);

/// Notifier handling submission of a review for a completed task.
class SubmitReviewNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Submits a star rating and optional comment for a task.
  Future<void> submitReview(
    SubmitReviewRequest request, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      debugLog('[SubmitReviewNotifier] Submitting review for task: ${request.taskId}, rating: ${request.rating}');
      final client = ref.read(reviewsClientProvider);
      final response = await client.submitReview(request);

      debugLog('[SubmitReviewNotifier] Response statusCode: ${response.statusCode}, detail: ${response.detail}');

      if (response.isError) {
        throw Exception(response.detail ?? 'Failed to submit review');
      }

      state = const AsyncData(null);
      debugLog('[SubmitReviewNotifier] Review submitted successfully. Invalidating pendingProviderReviewsProvider');
      ref.invalidate(pendingProviderReviewsProvider);

      onSuccess?.call();
    } catch (e, st) {
      debugLog('[SubmitReviewNotifier] Error submitting review: $e');
      state = AsyncError(e, st);
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

/// Provider exposing [SubmitReviewNotifier].
final submitReviewNotifierProvider =
    NotifierProvider<SubmitReviewNotifier, AsyncValue<void>>(
  SubmitReviewNotifier.new,
);
