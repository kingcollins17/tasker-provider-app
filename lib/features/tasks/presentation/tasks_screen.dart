import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/app_error_widget.dart';
import '../../../core/ui/widgets/debug_fab.dart';
import '../../../core/utils/extensions/num_ext.dart';
import '../tasks_routes.dart';

/// Status Filter option model mapping to backend TaskAssignmentStatus values
enum AssignmentStatusFilter {
  all(label: 'All', value: null),
  assigned(label: 'Assigned', value: 'ASSIGNED'),
  inProgress(label: 'Active', value: 'IN_PROGRESS'),
  completed(label: 'Completed', value: 'COMPLETED'),
  cancelled(label: 'Cancelled', value: 'CANCELLED');

  final String label;
  final String? value;

  const AssignmentStatusFilter({required this.label, this.value});
}

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final filterState = ref.read(assignmentFilterProvider);
      final filterParam =
          filterState.statuses.isEmpty ? null : filterState.statuses;
      ref.read(myAssignmentsProvider(filterParam).notifier).loadMore();
    }
  }

  void _toggleFilter(AssignmentStatusFilter filter, Set<String> currentStatuses) {
    final notifier = ref.read(assignmentFilterProvider.notifier);
    final current = Set<String>.from(currentStatuses);
    if (filter == AssignmentStatusFilter.all) {
      notifier.setStatuses({});
    } else if (filter.value != null) {
      if (current.contains(filter.value)) {
        current.remove(filter.value);
      } else {
        current.add(filter.value!);
      }
      notifier.setStatuses(current);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filterState = ref.watch(assignmentFilterProvider);
    final filterParam =
        filterState.statuses.isEmpty ? null : filterState.statuses;
    final assignmentsAsync = ref.watch(myAssignmentsProvider(filterParam));
    final notifier = ref.read(myAssignmentsProvider(filterParam).notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: const DebugFab(),
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: context.canPop() ? const BackButton() : null,
        title: Text(
          'My Tasks',
          style: AppTextStyles.h3.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: filterState.hasActiveFilters
                      ? AppColors.primary
                      : (isDark ? AppColors.textPrimary : Colors.black87),
                  size: 22.r,
                ),
                onPressed: () => _FilterSheet.show(),
              ),
              if (filterState.hasActiveFilters)
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    width: 8.r,
                    height: 8.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Multi-Select Filter Chips Row ──
          Column(
            children: [
              SizedBox(
                height: 48.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: AssignmentStatusFilter.values.length,
                  itemBuilder: (context, index) {
                    final filter = AssignmentStatusFilter.values[index];
                    final isSelected = filter == AssignmentStatusFilter.all
                        ? filterState.statuses.isEmpty
                        : (filter.value != null &&
                            filterState.statuses.contains(filter.value));

                    return _StatusFilterChip(
                      filter: filter,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () =>
                          _toggleFilter(filter, filterState.statuses),
                    );
                  },
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? AppColors.border
                    : Colors.grey.withValues(alpha: 0.15),
              ),
            ],
          ),

          // ── Assignments List / States ──
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await notifier.refresh();
              },
              child: assignmentsAsync.when(
                loading: () => _ShimmerList(isDark: isDark, theme: theme),
                error: (error, st) {
                  debugLog(error);
                  debugLog(st.toString());
                  return _ErrorStateWidget(
                    error: error.toString(),
                    onRetry: () => notifier.refresh(),
                  );
                },
                data: (rawAssignments) {
                  var assignments = rawAssignments;

                  // Apply client-side filters if active
                  if (filterState.startDate != null) {
                    assignments = assignments.where((a) {
                      final d = a.assignedAt ?? a.task?.createdAt;
                      return d != null &&
                          (d.isAfter(filterState.startDate!) ||
                              d.isAtSameMomentAs(filterState.startDate!));
                    }).toList();
                  }

                  if (filterState.endDate != null) {
                    final endOfDay =
                        filterState.endDate!.add(const Duration(days: 1));
                    assignments = assignments.where((a) {
                      final d = a.assignedAt ?? a.task?.createdAt;
                      return d != null && d.isBefore(endOfDay);
                    }).toList();
                  }

                  if (filterState.minAmount != null) {
                    assignments = assignments.where((a) {
                      final price = a.acceptedPrice ??
                          a.task?.providerPayout ??
                          a.task?.customerTotalPrice ??
                          0.0;
                      return price >= filterState.minAmount!;
                    }).toList();
                  }

                  if (filterState.maxAmount != null) {
                    assignments = assignments.where((a) {
                      final price = a.acceptedPrice ??
                          a.task?.providerPayout ??
                          a.task?.customerTotalPrice ??
                          0.0;
                      return price <= filterState.maxAmount!;
                    }).toList();
                  }

                  if (assignments.isEmpty) {
                    return const _EmptyStateWidget();
                  }

                  final totalCount =
                      assignments.length + (notifier.hasMore ? 1 : 0);

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.only(bottom: 20.h),
                    itemCount: totalCount * 2 - 1,
                    itemBuilder: (context, index) {
                      if (index.isOdd) {
                        return Divider(
                          height: 1,
                          thickness: 1,
                          indent: 16.w,
                          endIndent: 16.w,
                          color: isDark
                              ? AppColors.border
                              : Colors.grey.withValues(alpha: 0.12),
                        );
                      }

                      final itemIndex = index ~/ 2;
                      if (itemIndex == assignments.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }

                      final assignment = assignments[itemIndex];
                      return _AssignmentTile(
                        assignment: assignment,
                        index: itemIndex,
                        isDark: isDark,
                        onTap: () {
                          final taskId =
                              assignment.taskId ?? assignment.task?.id;
                          if (taskId != null && taskId.isNotEmpty) {
                            context.pushNamed(
                              TasksRoutes.taskDetailRoute,
                              pathParameters: {'taskId': taskId},
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER SHEET BOTTOM SHEET WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  static Future<void> show([BuildContext? context]) {
    final targetContext =
        NavigatorKeys.rootNavigatorKey.currentContext ?? context;
    if (targetContext == null) return Future.value();
    return showModalBottomSheet(
      context: targetContext,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterSheet(),
    );
  }

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late Set<String> _statuses;
  DateTime? _startDate;
  DateTime? _endDate;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(assignmentFilterProvider);
    _statuses = Set<String>.from(filter.statuses);
    _startDate = filter.startDate;
    _endDate = filter.endDate;
    _minAmountController = TextEditingController(
      text:
          filter.minAmount != null ? filter.minAmount!.toStringAsFixed(0) : '',
    );
    _maxAmountController = TextEditingController(
      text:
          filter.maxAmount != null ? filter.maxAmount!.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeCount = _statuses.length +
        (_startDate != null ? 1 : 0) +
        (_endDate != null ? 1 : 0) +
        (_minAmountController.text.isNotEmpty ? 1 : 0) +
        (_maxAmountController.text.isNotEmpty ? 1 : 0);

    return Container(
      constraints: BoxConstraints(maxHeight: 0.82.sh),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.border : Colors.transparent,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12.h,
        left: 20.w,
        right: 20.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.border
                      : Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Filter Assignments',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (activeCount > 0) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '$activeCount',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _statuses.clear();
                      _startDate = null;
                      _endDate = null;
                      _minAmountController.clear();
                      _maxAmountController.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Reset',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // Status Section
            Text(
              'ASSIGNMENT STATUS',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
                letterSpacing: 0.6,
                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: AssignmentStatusFilter.values
                  .where((f) => f != AssignmentStatusFilter.all)
                  .map((filter) {
                final isSelected = filter.value != null &&
                    _statuses.contains(filter.value);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (filter.value != null) {
                        if (isSelected) {
                          _statuses.remove(filter.value!);
                        } else {
                          _statuses.add(filter.value!);
                        }
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.grey.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.border
                                : Colors.grey.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Text(
                      filter.label,
                      style: AppTextStyles.label.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.textPrimary
                                : Colors.black87),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 18.h),

            // Date Range Section
            Text(
              'DATE RANGE',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
                letterSpacing: 0.6,
                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: () => _selectDate(context, true),
                    onClear: _startDate != null
                        ? () => setState(() => _startDate = null)
                        : null,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _DateField(
                    label: 'End Date',
                    date: _endDate,
                    onTap: () => _selectDate(context, false),
                    onClear: _endDate != null
                        ? () => setState(() => _endDate = null)
                        : null,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // Amount Range Section
            Text(
              'PAYOUT AMOUNT (₦)',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
                letterSpacing: 0.6,
                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: 'Min Amount',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 4.w),
                        child: Text(
                          '₦',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.border : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.border : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp),
                    decoration: InputDecoration(
                      hintText: 'Max Amount',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 4.w),
                        child: Text(
                          '₦',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.border : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.border : Colors.grey[300]!,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  final minVal = double.tryParse(_minAmountController.text);
                  final maxVal = double.tryParse(_maxAmountController.text);

                  ref.read(assignmentFilterProvider.notifier).updateFilter(
                        AssignmentFilterState(
                          statuses: _statuses,
                          startDate: _startDate,
                          endDate: _endDate,
                          minAmount: minVal,
                          maxAmount: maxVal,
                        ),
                      );
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.check_rounded,
                  size: 18.r,
                  color: Colors.white,
                ),
                label: Text(
                  'Apply Filters',
                  style: AppTextStyles.buttonMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final bool isDark;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final text =
        date != null ? '${date!.day}/${date!.month}/${date!.year}' : label;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color:
              isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: date != null
                ? AppColors.primary
                : (isDark
                    ? AppColors.border
                    : Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16.r,
              color: date != null ? AppColors.primary : AppColors.textMuted,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: date != null
                      ? (isDark ? AppColors.textPrimary : Colors.black87)
                      : AppColors.textMuted,
                  fontWeight:
                      date != null ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close_rounded,
                  size: 14.r,
                  color: AppColors.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER CHIP WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _StatusFilterChip extends StatelessWidget {
  final AssignmentStatusFilter filter;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.filter,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = filter == AssignmentStatusFilter.all;

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.border
                    : Colors.grey.withValues(alpha: 0.2)),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected && !isAll) ...[
                    Icon(
                      Icons.check_rounded,
                      size: 14.r,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    filter.label,
                    style: AppTextStyles.label.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textPrimary : Colors.black87),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSIGNMENT TILE WIDGET (Mobile Card Layout)
// ─────────────────────────────────────────────────────────────────────────────

class _AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const _AssignmentTile({
    required this.assignment,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final task = assignment.task;
    final title = task?.title ?? 'Task Assignment';
    final price = assignment.acceptedPrice ??
        task?.providerPayout ??
        task?.customerTotalPrice ??
        0.0;
    final rawStatus = assignment.status ?? task?.status ?? 'ASSIGNED';
    final statusProps = _getStatusProps(rawStatus, isDark);
    final avatarProps = _getAvatarProps(title);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Category / Task Icon Avatar
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isDark
                    ? avatarProps.bgColor.withValues(alpha: 0.16)
                    : avatarProps.bgColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  avatarProps.icon,
                  size: 18.r,
                  color: avatarProps.bgColor,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Title & DateTime Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDate(assignment.assignedAt ?? task?.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Price & Status Badge Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  price.toNaira(2),
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                _StatusBadge(statusProps: statusProps),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _StatusProps _getStatusProps(String rawStatus, bool isDark) {
    final status = rawStatus.toUpperCase();
    switch (status) {
      case 'IN_PROGRESS':
      case 'STARTED':
      case 'ASSIGNED':
      case 'ACTIVE':
        return _StatusProps(
          label: 'Active',
          textColor: const Color(0xFF00B368),
          chipBgColor: isDark
              ? const Color(0xFF0A2B1D)
              : const Color(0xFFE6F9F0),
          iconCircleBgColor: const Color(0xFF00B368),
          icon: Icons.north_east_rounded,
        );
      case 'COMPLETED':
        return _StatusProps(
          label: 'Done',
          textColor: const Color(0xFF00B368),
          chipBgColor: isDark
              ? const Color(0xFF0A2B1D)
              : const Color(0xFFE6F9F0),
          iconCircleBgColor: const Color(0xFF00B368),
          icon: Icons.north_east_rounded,
        );
      case 'CANCELLED':
      case 'CANCELED':
      case 'FAILED':
        return _StatusProps(
          label: 'Cancel',
          textColor: const Color(0xFFE53935),
          chipBgColor: isDark
              ? const Color(0xFF331515)
              : const Color(0xFFFFEAEA),
          iconCircleBgColor: const Color(0xFFE53935),
          icon: Icons.south_east_rounded,
        );
      default:
        return _StatusProps(
          label: status.replaceAll('_', ' '),
          textColor: const Color(0xFFD97706),
          chipBgColor: isDark
              ? const Color(0xFF2E1F0A)
              : const Color(0xFFFFF7ED),
          iconCircleBgColor: const Color(0xFFD97706),
          icon: Icons.east_rounded,
        );
    }
  }

  _AvatarProps _getAvatarProps(String title) {
    final lower = title.toLowerCase().trim();
    if (lower.contains('carpet') || lower.contains('upholstery') || lower.contains('clean')) {
      return const _AvatarProps(
        bgColor: Color(0xFF627EEA),
        iconColor: Colors.white,
        icon: Icons.cleaning_services_rounded,
      );
    } else if (lower.contains('office') || lower.contains('commercial')) {
      return const _AvatarProps(
        bgColor: Color(0xFF8B5CF6),
        iconColor: Colors.white,
        icon: Icons.business_center_rounded,
      );
    } else if (lower.contains('home') || lower.contains('house') || lower.contains('standard')) {
      return const _AvatarProps(
        bgColor: Color(0xFF26A17B),
        iconColor: Colors.white,
        icon: Icons.home_repair_service_rounded,
      );
    } else if (lower.contains('plumb')) {
      return const _AvatarProps(
        bgColor: Color(0xFF0EA5E9),
        iconColor: Colors.white,
        icon: Icons.plumbing_rounded,
      );
    } else if (lower.contains('electric')) {
      return const _AvatarProps(
        bgColor: Color(0xFF007D5A),
        iconColor: Colors.white,
        icon: Icons.electrical_services_rounded,
      );
    } else if (lower.contains('handyman') || lower.contains('fix') || lower.contains('repair')) {
      return const _AvatarProps(
        bgColor: Color(0xFFF7931A),
        iconColor: Colors.white,
        icon: Icons.build_rounded,
      );
    }

    final palette = const [
      (Color(0xFF627EEA), Icons.cleaning_services_rounded),
      (Color(0xFF8B5CF6), Icons.business_center_rounded),
      (Color(0xFF26A17B), Icons.home_repair_service_rounded),
      (Color(0xFF007D5A), Icons.electrical_services_rounded),
      (Color(0xFF0EA5E9), Icons.plumbing_rounded),
      (Color(0xFFF7931A), Icons.build_rounded),
      (Color(0xFFF3BA2F), Icons.work_rounded),
    ];
    final selected = palette[lower.hashCode.abs() % palette.length];
    return _AvatarProps(
      bgColor: selected.$1,
      iconColor: Colors.white,
      icon: selected.$2,
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final local = dateTime.toLocal();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BADGE WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _StatusProps statusProps;

  const _StatusBadge({required this.statusProps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: statusProps.chipBgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14.r,
            height: 14.r,
            decoration: BoxDecoration(
              color: statusProps.iconCircleBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                statusProps.icon,
                size: 8.r,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            statusProps.label,
            style: AppTextStyles.label.copyWith(
              color: statusProps.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LIST SKELETON
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;

  const _ShimmerList({required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: 20.h),
        itemCount: 8 * 2 - 1,
        itemBuilder: (_, index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              thickness: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: isDark
                  ? AppColors.border
                  : Colors.grey.withValues(alpha: 0.12),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 14.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 70.w,
                        height: 10.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 60.w,
                      height: 14.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 50.w,
                      height: 18.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: SizedBox(
        height: 0.6.sh,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    size: 48.r,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Assignments Found',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'When tasks are assigned to you, they will appear here.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ERROR STATE WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorStateWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorStateWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: SizedBox(
        height: 0.6.sh,
        child: AppErrorWidget(
          error: error,
          onRetry: onRetry,
        ),
      ),
    );
  }
}

class _StatusProps {
  final String label;
  final Color textColor;
  final Color chipBgColor;
  final Color iconCircleBgColor;
  final IconData icon;

  const _StatusProps({
    required this.label,
    required this.textColor,
    required this.chipBgColor,
    required this.iconCircleBgColor,
    required this.icon,
  });
}

class _AvatarProps {
  final Color bgColor;
  final Color iconColor;
  final IconData icon;

  const _AvatarProps({
    required this.bgColor,
    required this.iconColor,
    required this.icon,
  });
}
