---
name: code-style
description: Established architectural patterns for API client integration, AsyncNotifier state management & mutations, paginated lists, and UI screen integration in the Tasker app.
---

# Code Style & Architecture Patterns

This skill documents the standard patterns for API integration, Riverpod state management, paginated notifiers, and UI component integration across the Tasker Provider app.

---

## 1. API Client Integration (Retrofit / Dio)

- Define Rest API methods in Retrofit client interfaces (e.g., `UsersClient`, `TasksClient`).
- Wrap single resource responses in `BaseApiResponse<T>`:
  ```dart
  @GET("vetting/guarantor")
  Future<BaseApiResponse<Guarantor>> getLatestGuarantor();
  ```
- Wrap paginated endpoints in `BaseApiResponse<PaginatedData<T>>` with `page` and `per_page` query parameters:
  ```dart
  @GET("offers")
  Future<BaseApiResponse<PaginatedData<Offer>>> getMyOffers({
    @Query("page") int page = 1,
    @Query("per_page") int perPage = 20,
  });
  ```

---

## 2. Models & Status Enum Mapping

- Model classes use `@JsonSerializable()` (and `@JsonKey(name: 'snake_case')` when needed).
- For status fields coming from backend APIs, store `status` as a `String?` field to maintain compatibility with backend raw strings.
- Expose a getter mapping the string to a strongly-typed Dart enum for UI logic checking:

```dart
@JsonSerializable()
class Guarantor {
  final String? id;
  final String? status;
  
  /// Maps string [status] to [VerificationStatus] enum for clean status checks.
  VerificationStatus get verificationStatus {
    switch (status?.toUpperCase().trim()) {
      case 'PASSED':
        return VerificationStatus.passed;
      case 'FAILED':
        return VerificationStatus.failed;
      case 'UNDER_REVIEW':
        return VerificationStatus.underReview;
      case 'PENDING':
      default:
        return VerificationStatus.pending;
    }
  }
}
```

---

## 3. Riverpod AsyncNotifier Patterns

### Mutation Notifiers (Submissions / Resubmissions)
- Include optional `VoidCallback? onSuccess` and `void Function(String)? onError` parameters.
- Upon successful API mutation, call `ref.invalidateSelf();` and `await future;` before invoking `onSuccess`.
- In catch blocks, pass error to `AppExceptionHandler.instance.handleError(e, st);` and pass `e.toFriendlyString()` to `onError`.

```dart
Future<void> submitGuarantor(
  GuarantorRequest request, {
  VoidCallback? onSuccess,
  void Function(String)? onError,
}) async {
  try {
    final client = ref.read(usersClientProvider);
    final response = await client.addGuarantor(request);

    if (response.isSuccessful) {
      ref.invalidateSelf();
      await future;
      onSuccess?.call();
    } else {
      throw (response.errorMessage ?? response.detailMessage ?? 'Failed to submit details');
    }
  } catch (e, st) {
    AppExceptionHandler.instance.handleError(e, st);
    onError?.call(e.toFriendlyString());
  }
}
```

### Paginated List Notifiers (`AsyncNotifier<List<T>>`)
- Extend `AsyncNotifier<List<T>>` directly.
- Maintain internal pagination variables: `int _page = 1; int _total = 0; bool _isLoadingMore = false;`.
- In `fetchMore()`, append new items directly to `state = AsyncData(updatedList)` without setting `state = AsyncLoading()` or `AsyncError()`.

```dart
class OffersNotifier extends AsyncNotifier<List<Offer>> {
  int _page = 1;
  int _total = 0;
  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => (state.value?.length ?? 0) < _total;

  @override
  Future<List<Offer>> build() async {
    _page = 1;
    _total = 0;
    _isLoadingMore = false;
    return _fetchInitial();
  }

  Future<List<Offer>> _fetchInitial() async {
    final client = ref.watch(tasksClientProvider);
    final response = await client.getMyOffers(page: 1, perPage: 20);
    if (response.isSuccessful && response.hasData) {
      _total = response.data?.total ?? 0;
      _page = response.data?.page ?? 1;
      return response.data?.items ?? [];
    }
    return [];
  }

  Future<void> fetchMore() async {
    final currentList = state.value;
    if (currentList == null || _isLoadingMore || currentList.length >= _total) return;

    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final client = ref.read(tasksClientProvider);
      final response = await client.getMyOffers(page: nextPage, perPage: 20);

      if (response.isSuccessful && response.hasData) {
        final newItems = response.data?.items ?? [];
        _page = response.data?.page ?? nextPage;
        _total = response.data?.total ?? _total;
        state = AsyncData(List<Offer>.from(currentList)..addAll(newItems));
      }
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
```

---

## 4. Routing & UI Integration

- **Modular Routes**: Group feature routes in dedicated class (e.g. `ProfileRoutes`). Store route names as `static const String`.
- **Navigation Back Button**: Always use standard `BackButton()` widget in `AppBar.leading`.
- **Async Loading Overlay**: Use `context.showLoading()` before async operations and `context.hideLoading()` inside completion/callbacks across async gaps.
- **Query Parameters**: Support optional query parameters (e.g. `is_resubmission=true`) when opening form screens.
