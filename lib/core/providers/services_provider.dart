import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../api/services_client.dart';

// -----------------------------------------------------------------------------
// Categories Provider
// -----------------------------------------------------------------------------

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  final String? search;

  CategoriesNotifier({this.search});

  @override
  Future<List<Category>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPage(1);
  }

  Future<List<Category>> _fetchPage(int page) async {
    final client = ref.read(servicesClientProvider);
    final response = await client.getCategories(
      page: page,
      perPage: _perPage,
      search: search,
    );

    if (response.data == null) {
      throw Exception(response.detail ?? 'Failed to load categories');
    }

    final newItems = response.data!.items ?? [];
    if (newItems.length < _perPage) {
      _hasMore = false;
    }

    return newItems;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError || !_hasMore) return;

    final currentData = state.value ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      _page++;
      final newItems = await _fetchPage(_page);
      return [...currentData, ...newItems];
    });
  }
}

final categoriesProvider =
    AsyncNotifierProvider.family<CategoriesNotifier, List<Category>, String?>(
      (arg) => CategoriesNotifier(search: arg),
    );

// -----------------------------------------------------------------------------
// Services Provider
// -----------------------------------------------------------------------------

class ServicesNotifier extends AsyncNotifier<List<Service>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  final String? search, categoryId;

  ServicesNotifier({this.search, this.categoryId});
  @override
  Future<List<Service>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPage(1);
  }

  Future<List<Service>> _fetchPage(int page) async {
    final client = ref.read(servicesClientProvider);
    final response = await client.getServices(
      page: page,
      perPage: _perPage,
      search: search,
      categoryId: categoryId,
    );

    if (response.data == null) {
      throw Exception(response.detail ?? 'Failed to load services');
    }

    final newItems = response.data!.items ?? [];
    if (newItems.length < _perPage) {
      _hasMore = false;
    }

    return newItems;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError || !_hasMore) return;

    final currentData = state.value ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      _page++;
      final newItems = await _fetchPage(_page);
      return [...currentData, ...newItems];
    });
  }
}

final servicesProvider =
    AsyncNotifierProvider.family<
      ServicesNotifier,
      List<Service>,
      ({String? search, String? categoryId})?
    >(
      (arg) =>
          ServicesNotifier(search: arg?.search, categoryId: arg?.categoryId),
    );

// -----------------------------------------------------------------------------
// By ID Providers
// -----------------------------------------------------------------------------

final categoryByIdProvider = FutureProvider.family<Category, String>((
  ref,
  id,
) async {
  final client = ref.watch(servicesClientProvider);
  final response = await client.getCategory(id);

  if (response.data == null) {
    throw Exception('Category not found');
  }

  return response.data!;
});

final serviceByIdProvider = FutureProvider.family<Service, String>((
  ref,
  id,
) async {
  final client = ref.watch(servicesClientProvider);
  final response = await client.getService(id);

  if (response.data == null) {
    throw Exception('Service not found');
  }

  return response.data!;
});
