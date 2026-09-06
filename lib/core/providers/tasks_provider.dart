import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';
import 'package:tasker_app/features/tasks/presentation/widgets/offer_ping_bottom_sheet.dart';
import '../utils/app_exception_handler.dart';
import '../utils/extensions/error_ext.dart';
import '../models/models.dart';
import '../api/tasks_client.dart';
import 'location_provider.dart';
import 'user_provider.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasks_provider.freezed.dart';

const _radiusKm = 500.0;

@freezed
abstract class TasksFilter with _$TasksFilter {
  const factory TasksFilter({
    String? status,
    String? categoryId,
    String? serviceId,
    String? search,
    double? radiusKm,
    String? sortBy,
    bool? sortDesc,
    String? regionId,
    double? budgetMin,
    double? budgetMax,
    String? scheduledStartAt,
    String? expiresAt,
    String? customerId,
  }) = _TasksFilter;
}

class TasksFilterNotifier extends Notifier<TasksFilter> {
  @override
  TasksFilter build() => const TasksFilter();

  void updateFilter(TasksFilter newFilter) {
    state = newFilter;
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status);
  }

  void updateCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void updateService(String? serviceId) {
    state = state.copyWith(serviceId: serviceId);
  }

  void updateSearch(String? search) {
    state = state.copyWith(search: search);
  }

  void updateLocation({double? radiusKm}) {
    state = state.copyWith(radiusKm: radiusKm ?? state.radiusKm);
  }

  void updateSort({String? sortBy, bool? sortDesc}) {
    state = state.copyWith(
      sortBy: sortBy ?? state.sortBy,
      sortDesc: sortDesc ?? state.sortDesc,
    );
  }

  void updateRegion(String? regionId) {
    state = state.copyWith(regionId: regionId);
  }

  void updateBudget({double? min, double? max}) {
    state = state.copyWith(
      budgetMin: min ?? state.budgetMin,
      budgetMax: max ?? state.budgetMax,
    );
  }

  void updateSchedule({String? startAt, String? expiresAt}) {
    state = state.copyWith(
      scheduledStartAt: startAt ?? state.scheduledStartAt,
      expiresAt: expiresAt ?? state.expiresAt,
    );
  }

  void updateCustomer(String? customerId) {
    state = state.copyWith(customerId: customerId);
  }

  void reset() {
    state = const TasksFilter();
  }
}

final tasksFilterProvider = NotifierProvider<TasksFilterNotifier, TasksFilter>(
  TasksFilterNotifier.new,
);

class TasksNotifier extends AsyncNotifier<List<TaskLite>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  final TasksFilter? filter;

  TasksNotifier({this.filter});

  @override
  Future<List<TaskLite>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPage(1);
  }

  Future<List<TaskLite>> _fetchPage(int page) async {
    final client = ref.read(tasksClientProvider);
    Coordinates? coords;
    try {
      coords = await ref.read(userCoordinatesProvider.future);
    } catch (_) {}

    final response = await client.getTasks(
      page: page,
      perPage: _perPage,
      status: filter?.status,
      categoryId: filter?.categoryId,
      serviceId: filter?.serviceId,
      search: filter?.search,
      latitude: coords?.latitude,
      longitude: coords?.longitude,
      radiusKm: filter?.radiusKm ?? _radiusKm,
      sortBy: filter?.sortBy ?? "created_at",
      sortDesc: filter?.sortDesc ?? true,
      regionId: filter?.regionId,
      budgetMin: filter?.budgetMin,
      budgetMax: filter?.budgetMax,
      scheduledStartAt: filter?.scheduledStartAt,
      expiresAt: filter?.expiresAt,
      customerId: filter?.customerId,
    );

    if (response.data == null) {
      throw Exception(response.detail ?? 'Failed to load tasks');
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

final tasksProvider =
    AsyncNotifierProvider.family<TasksNotifier, List<TaskLite>, TasksFilter?>(
      (arg) => TasksNotifier(filter: arg),
    );

final openTasksProvider = FutureProvider<List<TaskLite>>((ref) async {
  final client = ref.watch(tasksClientProvider);
  Coordinates? coords;
  try {
    coords = await ref.watch(userCoordinatesProvider.future);
  } catch (_) {}

  final response = await client.getTasks(
    status: 'open',
    latitude: coords?.latitude,
    longitude: coords?.longitude,
    radiusKm: _radiusKm,
  );
  if (response.data == null) {
    throw Exception(response.detail ?? 'Failed to load open tasks');
  }
  return response.data!.items ?? [];
});

final biddingTasksProvider = FutureProvider<List<TaskLite>>((ref) async {
  final client = ref.watch(tasksClientProvider);
  Coordinates? coords;
  try {
    coords = await ref.watch(userCoordinatesProvider.future);
  } catch (_) {}

  final response = await client.getTasks(
    status: 'bidding',
    latitude: coords?.latitude,
    longitude: coords?.longitude,
    radiusKm: _radiusKm,
  );
  if (response.data == null) {
    throw Exception(response.detail ?? 'Failed to load bidding tasks');
  }
  return response.data!.items ?? [];
});

final customerTasksProvider = FutureProvider.family<List<TaskLite>, String>((
  ref,
  customerId,
) async {
  final client = ref.watch(tasksClientProvider);
  Coordinates? coords;
  try {
    coords = await ref.watch(userCoordinatesProvider.future);
  } catch (_) {}

  final response = await client.getTasks(
    customerId: customerId,
    latitude: coords?.latitude,
    longitude: coords?.longitude,
  );
  if (response.data == null) {
    throw Exception(response.detail ?? 'Failed to load customer tasks');
  }
  return response.data!.items ?? [];
});

final nearbyJobsProvider = FutureProvider<List<TaskLite>>((ref) async {
  final openTasks = await ref.watch(openTasksProvider.future);
  final biddingTasks = await ref.watch(biddingTasksProvider.future);

  final combined = [...openTasks, ...biddingTasks];
  combined.sort((a, b) {
    final aDate = a.createdAt ?? DateTime.now();
    final bDate = b.createdAt ?? DateTime.now();
    return bDate.compareTo(aDate);
  });
  return combined;
});

final taskDetailProvider = FutureProvider.family<Task, String>((
  ref,
  taskId,
) async {
  final client = ref.watch(tasksClientProvider);
  final response = await client.getTask(taskId);
  if (response.data == null) {
    throw Exception(response.detail ?? 'Failed to load task details');
  }
  return response.data!;
});

/// Handles responding to dispatch pings (accept / decline).
class DispatchPingNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Sends the provider's response (`accepted` or `declined`) for the given
  /// [taskId] dispatch ping.
  Future<void> respond(
    String taskId, {
    required String status,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.respondToDispatchPing(
        taskId,
        DispatchRespondRequest(
          status: status.toUpperCase(),
        ), // must be capitalized,
      );
      if (response.isError) {
        throw Exception(response.detail ?? 'Failed to respond to dispatch');
      }

      onSuccess?.call();
    } catch (e, st) {
      AppExceptionHandler.instance.handleError(e, st);

      onError?.call(e.toFriendlyString());
    }
  }
}

final dispatchPingProvider =
    NotifierProvider<DispatchPingNotifier, AsyncValue<void>>(
      DispatchPingNotifier.new,
    );

/// Notifier for task management operations (start, complete, etc.).
class TaskManagementNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Starts the task [taskId] using the customer's [pin].
  Future<void> startTask(
    String taskId, {
    required String pin,
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.startTask(
        taskId,
        StartTaskRequest(pin: pin),
      );

      if (response.isError) {
        throw Exception(response.detail ?? 'Failed to start task');
      }

      ref.invalidate(taskDetailProvider(taskId));
      ref.invalidate(taskAssignmentProvider(taskId));
      ref.invalidate(isUserAssignedToTaskProvider(taskId));

      state = const AsyncData(null);
      onSuccess?.call();
    } catch (e, st) {
      state = AsyncError(e, st);
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }

  /// Completes the task [taskId] using the customer's [pin] and [paymentMode].
  Future<void> completeTask(
    String taskId, {
    required String pin,
    String paymentMode = 'cash',
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.completeTask(
        taskId,
        CompleteTaskRequest(pin: pin, paymentMode: paymentMode),
      );

      if (response.isError) {
        throw Exception(response.detail ?? 'Failed to complete task');
      }

      ref.invalidate(taskDetailProvider(taskId));
      ref.invalidate(taskAssignmentProvider(taskId));
      ref.invalidate(isUserAssignedToTaskProvider(taskId));

      state = const AsyncData(null);
      onSuccess?.call();
    } catch (e, st) {
      state = AsyncError(e, st);
      AppExceptionHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyString());
    }
  }
}

final taskManagementProvider =
    NotifierProvider<TaskManagementNotifier, AsyncValue<void>>(
      TaskManagementNotifier.new,
    );

/// Future family provider to retrieve the provider's current active assignment.
final currentAssignmentProvider = FutureProvider<Assignment?>((ref) async {
  final client = ref.watch(tasksClientProvider);
  final response = await client.getCurrentAssignment();
  if (response.data == null) {
    if (response.isError) {
      throw Exception(response.detail ?? 'Failed to load current assignment');
    }
    return null;
  }
  return response.data;
}, retry: (retryCount, error) => null);

/// Future family provider to retrieve the assignment for a specific task if available.
final taskAssignmentProvider = FutureProvider.family<Assignment?, String>((
  ref,
  taskId,
) async {
  final client = ref.watch(tasksClientProvider);
  final response = await client.getTaskAssignment(taskId);
  if (response.data == null) {
    if (response.isError) {
      throw Exception(response.detail ?? 'Failed to load task assignment');
    }
    return null;
  }
  return response.data;
}, retry: (retryCount, error) => null);

/// Provider that checks if the current authenticated user is the assigned provider for the given [taskId].
final isUserAssignedToTaskProvider = FutureProvider.family<bool, String>((
  ref,
  taskId,
) async {
  final userAsync = ref.watch(userProvider);
  final user = userAsync.value;
  if (user == null) return false;

  final currentProviderId = user.id;
  if (currentProviderId == null || currentProviderId.isEmpty) return false;

  try {
    final assignment = await ref.watch(taskAssignmentProvider(taskId).future);
    if (assignment == null) return false;

    final assignedProviderId = assignment.providerId ?? assignment.provider?.id;
    return assignedProviderId == currentProviderId;
  } catch (_) {
    return false;
  }
});

/// Future provider to retrieve the provider's current pending dispatch attempt.
final currentDispatchProvider = FutureProvider.autoDispose<Dispatch?>((
  ref,
) async {
  final client = ref.watch(tasksClientProvider);
  try {
    final response = await client.getCurrentDispatch();
    if (response.data == null) {
      if (response.isError) {
        throw Exception(response.detail ?? 'Failed to load current dispatch');
      }
      return null;
    }
    return response.data;
  } catch (e) {
    // Return null if there's no active dispatch or if request fails (e.g. 404)
    return null;
  }
}, retry: (retryCount, error) => null);

/// Provider that watches currentDispatchProvider and shows the OfferPingBottomSheet if the dispatch is PENDING and has not expired.
final currentDispatchListenerProvider = Provider.autoDispose<void>((ref) {
  ref.listen<AsyncValue<Dispatch?>>(currentDispatchProvider, (previous, next) {
    if (next.hasValue && next.value != null) {
      final dispatch = next.value!;
      final isPending = dispatch.status == null ||
          dispatch.status!.toUpperCase() == 'PENDING';
      final isNotExpired = dispatch.expiresAt == null ||
          dispatch.expiresAt!.isAfter(DateTime.now());
      debugLog(dispatch);
      if (isPending && isNotExpired && dispatch.taskId != null && dispatch.taskId!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OfferPingBottomSheet.show(
            dispatch.taskId!,
            expiresAt: dispatch.expiresAt,
          );
        });
      }
    }
  }, fireImmediately: true);
});

/// Notifier to manage paginated list of user assignments.
class AssignmentsNotifier extends AsyncNotifier<List<Assignment>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  final String? status;
  final String? taskId;
  final String? sortBy;
  final bool? sortDesc;

  AssignmentsNotifier({
    this.status,
    this.taskId,
    this.sortBy,
    this.sortDesc,
  });

  bool get hasMore => _hasMore;
  int get currentPage => _page;
  int get perPage => _perPage;

  @override
  Future<List<Assignment>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPage(1);
  }

  Future<List<Assignment>> _fetchPage(int page) async {
    final client = ref.read(tasksClientProvider);
    final response = await client.getAssignments(
      page: page,
      perPage: _perPage,
      status: status,
      taskId: taskId,
      sortBy: sortBy ?? "assigned_at",
      sortDesc: sortDesc ?? true,
    );

    if (response.isError || response.data == null) {
      throw Exception(response.detail ?? 'Failed to fetch assignments');
    }

    final items = response.data!.items ?? [];
    if (items.length < _perPage) {
      _hasMore = false;
    }

    return items;
  }

  /// Refreshes the assignments list by re-initializing build().
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Loads the next page of assignments and appends them to current state.
  Future<void> loadMore() async {
    if (state.isLoading || state.hasError || !_hasMore) return;

    final currentItems = state.value ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      _page++;
      final nextItems = await _fetchPage(_page);
      return [...currentItems, ...nextItems];
    });
  }
}

/// Provider exposing paginated list of user assignments filtered by status.
final myAssignmentsProvider =
    AsyncNotifierProvider.family<
      AssignmentsNotifier,
      List<Assignment>,
      String?
    >((status) => AssignmentsNotifier(status: status));

/// Alias for [myAssignmentsProvider].
final assignmentsProvider = myAssignmentsProvider;


