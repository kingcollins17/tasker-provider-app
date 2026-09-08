import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/app_startup_binding.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';
import 'package:tasker_app/core/utils/retry_util.dart';
import 'package:tasker_app/features/tasks/presentation/widgets/offer_ping_bottom_sheet.dart';

import '../utils/app_exception_handler.dart';
import '../utils/extensions/error_ext.dart';
import '../models/models.dart';
import '../api/tasks_client.dart';
import 'location_provider.dart';
import 'user_provider.dart';


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
}, retry: retryFunc(3));

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
        
        appQueue.add(() async {
          await OfferPingBottomSheet.show(
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

  final Set<String>? status;
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

    List<String>? statusParam;
    if (status != null && status!.isNotEmpty) {
      statusParam = status!.toList();
    }

    final response = await client.getAssignments(
      page: page,
      perPage: _perPage,
      status: statusParam,
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

    state = await AsyncValue.guard(() async {
      _page++;
      final nextItems = await _fetchPage(_page);
      return [...currentItems, ...nextItems];
    });
  }
}

/// Provider exposing paginated list of user assignments filtered by status set.
final myAssignmentsProvider =
    AsyncNotifierProvider.family<
      AssignmentsNotifier,
      List<Assignment>,
      Set<String>?
    >((status) => AssignmentsNotifier(status: status));

/// Alias for [myAssignmentsProvider].
final assignmentsProvider = myAssignmentsProvider;

/// Filter state for tasks/assignments list filtering
class AssignmentFilterState {
  final Set<String> statuses;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String sortBy;
  final bool sortDesc;

  const AssignmentFilterState({
    this.statuses = const {},
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.sortBy = 'assigned_at',
    this.sortDesc = true,
  });

  AssignmentFilterState copyWith({
    Set<String>? statuses,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? sortBy,
    bool? sortDesc,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return AssignmentFilterState(
      statuses: statuses ?? this.statuses,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      sortBy: sortBy ?? this.sortBy,
      sortDesc: sortDesc ?? this.sortDesc,
    );
  }

  bool get hasActiveFilters =>
      statuses.isNotEmpty ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null;
}

class AssignmentFilterNotifier extends Notifier<AssignmentFilterState> {
  @override
  AssignmentFilterState build() => const AssignmentFilterState();

  void updateFilter(AssignmentFilterState newFilter) {
    state = newFilter;
  }

  void toggleStatus(String status) {
    final current = Set<String>.from(state.statuses);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    state = state.copyWith(statuses: current);
  }

  void setStatuses(Set<String> statuses) {
    state = state.copyWith(statuses: statuses);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearStartDate: start == null,
      clearEndDate: end == null,
    );
  }

  void setAmountRange(double? min, double? max) {
    state = state.copyWith(
      minAmount: min,
      maxAmount: max,
      clearMinAmount: min == null,
      clearMaxAmount: max == null,
    );
  }

  void reset() {
    state = const AssignmentFilterState();
  }
}

final assignmentFilterProvider =
    NotifierProvider<AssignmentFilterNotifier, AssignmentFilterState>(
      AssignmentFilterNotifier.new,
    );




