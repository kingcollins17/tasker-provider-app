import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api.dart';
import '../models/api/api.dart';
import '../utils/app_exception_handler.dart';
import '../utils/extensions/error_ext.dart';
import 'notifications_state.dart';

export 'notifications_state.dart';

class NotificationsNotifier extends AsyncNotifier<NotificationsState> {
  @override
  Future<NotificationsState> build() async {
    // Initial fetch when provider is first watched
    final client = ref.read(notificationsClientProvider);

    // We can fetch initial data in parallel
    final results = await Future.wait([
      client.getNotifications(page: 1, perPage: 20),
      client.getCounts(),
    ]);

    final notificationsRes =
        results[0] as BaseApiResponse<PaginatedData<NotificationItem>>;
    final countsRes = results[1] as BaseApiResponse<NotificationCounts>;

    return NotificationsState(
      paginatedData: notificationsRes.data,
      counts: countsRes.data,
    );
  }

  Future<void> fetchMore() async {
    if (state.isLoading || state.hasError || state.value == null) return;

    final currentData = state.value!.paginatedData;
    if (currentData == null || currentData.items == null) return;

    // Check if we reached the end
    final itemsCount = currentData.items!.length;
    final total = currentData.total ?? 0;
    if (itemsCount >= total) return;

    final currentPage = currentData.page ?? 1;
    final perPage = currentData.perPage ?? 20;

    state = AsyncData(state.value!.copyWith(isLoadingMore: true));

    try {
      final client = ref.read(notificationsClientProvider);
      final response = await client.getNotifications(
        page: currentPage + 1,
        perPage: perPage,
      );

      if (response.data != null) {
        final newData = response.data!;
        final combinedItems = List<NotificationItem>.from(currentData.items!)
          ..addAll(newData.items ?? []);

        final newPaginatedData = PaginatedData<NotificationItem>(
          items: combinedItems,
          total: newData.total ?? currentData.total,
          page: newData.page,
          perPage: newData.perPage,
        );

        state = AsyncData(
          state.value!.copyWith(
            paginatedData: newPaginatedData,
            isLoadingMore: false,
          ),
        );
      } else {
        state = AsyncData(state.value!.copyWith(isLoadingMore: false));
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      state = AsyncData(state.value!.copyWith(isLoadingMore: false));
    }
  }

  Future<void> markAsRead(
    List<String> notificationIds, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(notificationsClientProvider);
      await client.markAsRead(
        MarkReadRequest(notificationIds: notificationIds),
      );

      // Refresh state
      ref.invalidateSelf();
      await future;

      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, NotificationsState>(
      () => NotificationsNotifier(),
    );
