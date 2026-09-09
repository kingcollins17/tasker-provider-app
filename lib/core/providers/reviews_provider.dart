import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_startup_binding.dart';
import '../api/api.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';
import '../ui/widgets/submit_review_sheet.dart';
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

/// AsyncNotifier tracking when review bottom sheets were last displayed per task.
class TaskReviewPromptTrackerNotifier
    extends AsyncNotifier<List<TaskReviewPromptTrack>> {
  static const String _storageKey = 'task_review_prompt_tracks';

  @override
  Future<List<TaskReviewPromptTrack>> build() async {
    final rawData = await appStorage.get<dynamic>(_storageKey);
    if (rawData == null) return [];

    if (rawData is List) {
      return rawData
          .whereType<Map>()
          .map((json) => TaskReviewPromptTrack.fromJson(
                Map<String, dynamic>.from(json),
              ))
          .toList();
    }
    return [];
  }

  /// Updates or inserts a prompt tracking record for [taskId].
  Future<void> updatePromptTrack({
    required String taskId,
    DateTime? lastShownAt,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final currentTime = lastShownAt ?? DateTime.now();
      final currentList = state.value ?? [];
      final index = currentList.indexWhere((t) => t.taskId == taskId);

      List<TaskReviewPromptTrack> updatedList;
      if (index >= 0) {
        updatedList = List.from(currentList);
        updatedList[index] = updatedList[index].copyWith(lastShownAt: currentTime);
      } else {
        updatedList = [
          ...currentList,
          TaskReviewPromptTrack(taskId: taskId, lastShownAt: currentTime),
        ];
      }

      await appStorage.save(
        _storageKey,
        updatedList.map((e) => e.toJson()).toList(),
      );

      ref.invalidateSelf();
      await future;
      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Resets tracking for a specific [taskId], or resets all tracked items if [taskId] is omitted/null.
  Future<void> resetTrack({
    String? taskId,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      List<TaskReviewPromptTrack> updatedList;
      if (taskId != null && taskId.isNotEmpty) {
        final currentList = state.value ?? [];
        updatedList = currentList.where((t) => t.taskId != taskId).toList();
      } else {
        updatedList = [];
      }

      await appStorage.save(
        _storageKey,
        updatedList.map((e) => e.toJson()).toList(),
      );

      ref.invalidateSelf();
      await future;
      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

/// AsyncNotifierProvider managing the list of [TaskReviewPromptTrack].
final taskReviewPromptTrackerProvider = AsyncNotifierProvider<
    TaskReviewPromptTrackerNotifier, List<TaskReviewPromptTrack>>(
  TaskReviewPromptTrackerNotifier.new,
);

/// Provider that listens to [pendingProviderReviewsProvider] and automatically shows
/// [SubmitReviewSheet] for a random pending review if it has not been shown or if
/// 1 day has passed since it was last shown.
final pendingReviewPrompterProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<PendingProviderReviewItem>>>(
    pendingProviderReviewsProvider,
    (previous, next) async {
      final items = next.value;
      if (items == null || items.isEmpty) return;

      final trackerState = ref.read(taskReviewPromptTrackerProvider);
      final tracks = trackerState.value ?? [];

      // Pick a random item from pending reviews
      final randomItem = items[Random().nextInt(items.length)];
      final taskId = randomItem.id;
      if (taskId == null || taskId.isEmpty) return;

      // Find tracking record for this task
      TaskReviewPromptTrack? trackRecord;
      for (final track in tracks) {
        if (track.taskId == taskId) {
          trackRecord = track;
          break;
        }
      }

      final now = DateTime.now();
      final shouldShow = trackRecord == null ||
          trackRecord.lastShownAt == null ||
          now.difference(trackRecord.lastShownAt!).inHours >= 24;

      if (shouldShow) {
        debugLog(trackRecord?.toJson());
        debugLog('[pendingReviewPrompterProvider]: pending review');
        await ref
            .read(taskReviewPromptTrackerProvider.notifier)
            .updatePromptTrack(taskId: taskId, lastShownAt: now);

        appQueue.add(() async {
          await SubmitReviewSheet.show(taskId: taskId);
        });
      }
    },
  );
});


