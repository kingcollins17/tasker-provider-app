import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/features/auth/providers/auth_provider.dart';

import '../api/tasks_client.dart';
import '../models/models.dart';
import '../utils/app_exception_handler.dart';
import '../utils/debug_logger.dart';

/// AsyncNotifier managing a paginated [List<Offer>] state.
class OffersNotifier extends AsyncNotifier<List<Offer>> {
  int _page = 1;
  int _total = 0;
  bool _isLoadingMore = false;

  int get currentPage => _page;
  int get totalOffers => _total;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => (state.value?.length ?? 0) < _total;

  @override
  Future<List<Offer>> build() async {
    ref.watch(isAuthenticatedProvider);
    _page = 1;
    _total = 0;
    _isLoadingMore = false;
    return _fetchInitial();
  }

  Future<List<Offer>> _fetchInitial() async {
    debugLog('[OffersNotifier] Fetching initial offers...');
    final client = ref.watch(tasksClientProvider);
    final response = await client.getMyOffers(page: 1, perPage: 20);

    if (response.isSuccessful && response.hasData) {
      final data = response.data!;
      _total = data.total ?? 0;
      _page = data.page ?? 1;
      debugLog(
        '[OffersNotifier] Loaded ${data.items?.length ?? 0} offers (Total: $_total)',
      );
      return data.items ?? [];
    }

    return [];
  }

  /// Fetches the next page of offers and appends them to the current state list
  /// without causing state flicker or setting full screen loading/error.
  Future<void> fetchMore() async {
    final currentList = state.value;
    if (currentList == null || _isLoadingMore || currentList.length >= _total) {
      return;
    }

    _isLoadingMore = true;

    try {
      final nextPage = _page + 1;
      debugLog('[OffersNotifier.fetchMore] Fetching page $nextPage...');

      final client = ref.read(tasksClientProvider);
      final response = await client.getMyOffers(
        page: nextPage,
        perPage: 20,
      );

      if (response.isSuccessful && response.hasData) {
        final newData = response.data!;
        final newItems = newData.items ?? [];

        _page = newData.page ?? nextPage;
        _total = newData.total ?? _total;

        final updatedList = List<Offer>.from(currentList)..addAll(newItems);
        state = AsyncData(updatedList);

        debugLog(
          '[OffersNotifier.fetchMore] Loaded page $_page (${updatedList.length}/$_total total items)',
        );
      }
    } catch (e, st) {
      debugLog(
        '[OffersNotifier.fetchMore] Error fetching more offers: $e',
        level: DebugLevel.error,
      );
      AppExceptionHandler.instance.handleError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refreshes the list of offers.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Main Provider for [OffersNotifier] yielding [AsyncValue<List<Offer>>].
final offersNotifierProvider =
    AsyncNotifierProvider<OffersNotifier, List<Offer>>(
  () => OffersNotifier(),
);
