import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/utils/extensions/num_ext.dart';
import '../tasks_routes.dart';

/// Status Filter option model
enum AssignmentStatusFilter {
  all(label: 'All', value: null),
  assigned(label: 'Assigned', value: 'assigned'),
  inProgress(label: 'Active', value: 'in_progress'),
  completed(label: 'Completed', value: 'completed'),
  cancelled(label: 'Cancelled', value: 'cancelled');

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
  AssignmentStatusFilter _selectedFilter = AssignmentStatusFilter.all;
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
      ref
          .read(myAssignmentsProvider(_selectedFilter.value).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final assignmentsAsync =
        ref.watch(myAssignmentsProvider(_selectedFilter.value));
    final notifier =
        ref.read(myAssignmentsProvider(_selectedFilter.value).notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'My Assignments',
          style: AppTextStyles.h2.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Filter Chips Row ──
          SizedBox(
            height: 42.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: AssignmentStatusFilter.values.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final filter = AssignmentStatusFilter.values[index];
                final isSelected = filter == _selectedFilter;

                return ChoiceChip(
                  label: Text(
                    filter.label,
                    style: AppTextStyles.label.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.textSecondary
                              : AppColors.textMuted),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13.sp,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark
                      ? theme.colorScheme.surface
                      : AppColors.primary.withValues(alpha: 0.08),
                  showCheckmark: false,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.border
                              : Colors.transparent),
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected && filter != _selectedFilter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(height: 12.h),

          // ── Assignments List / States ──
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await notifier.refresh();
              },
              child: assignmentsAsync.when(
                loading: () => _buildShimmerList(isDark, theme),
                error: (error, st) {
                  debugLog(error);
                  debugLog(st.toString());
                  return _buildErrorWidget(
                  context,
                  error.toString(),
                  () => notifier.refresh(),
                );
                },
                data: (assignments) {
                  if (assignments.isEmpty) {
                    return _buildEmptyWidget(context);
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    itemCount: assignments.length + (notifier.hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index == assignments.length) {
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

                      final assignment = assignments[index];
                      return _buildAssignmentCard(
                          context, assignment, isDark, theme);
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

  Widget _buildAssignmentCard(
    BuildContext context,
    Assignment assignment,
    bool isDark,
    ThemeData theme,
  ) {
    final task = assignment.task;
    final title = task?.title ?? 'Assignment';
    final description = task?.description ?? '';
    final price = assignment.acceptedPrice ??
        task?.providerPayout ??
        task?.customerTotalPrice ??
        0.0;
    final rawStatus = assignment.status ?? task?.status ?? 'ASSIGNED';
    final (statusLabel, statusColor, statusBgColor) = _getStatusProps(rawStatus);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: AppDecorations.radiusLg,
        border: Border.all(
          color:
              isDark ? AppColors.border : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final taskId = assignment.taskId ?? task?.id;
            if (taskId != null && taskId.isNotEmpty) {
              context.pushNamed(
                TasksRoutes.taskDetailRoute,
                pathParameters: {'taskId': taskId},
              );
            }
          },
          borderRadius: AppDecorations.radiusLg,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Status Chip + Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            statusLabel,
                            style: AppTextStyles.label.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      price.toNaira(2),
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Title
                Text(
                  title,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                SizedBox(height: 12.h),
                Divider(
                  color: isDark
                      ? AppColors.border
                      : Colors.grey.withValues(alpha: 0.15),
                  height: 1,
                ),
                SizedBox(height: 10.h),

                // Footer: Assigned Date & Chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14.r,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          _formatDate(
                              assignment.assignedAt ?? task?.createdAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18.r,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (String label, Color textColor, Color bgColor) _getStatusProps(
      String rawStatus) {
    final status = rawStatus.toUpperCase();
    switch (status) {
      case 'IN_PROGRESS':
      case 'STARTED':
      case 'ASSIGNED':
      case 'ACTIVE':
        return (
          'Active',
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.12),
        );
      case 'COMPLETED':
        return (
          'Completed',
          AppColors.success,
          AppColors.success.withValues(alpha: 0.12),
        );
      case 'CANCELLED':
      case 'CANCELED':
      case 'FAILED':
        return (
          'Cancelled',
          AppColors.error,
          AppColors.error.withValues(alpha: 0.12),
        );
      default:
        return (
          status.replaceAll('_', ' '),
          AppColors.warning,
          AppColors.warning.withValues(alpha: 0.12),
        );
    }
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

  Widget _buildShimmerList(bool isDark, ThemeData theme) {
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (_, index) => Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDecorations.radiusLg,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
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
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.r,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to Load Assignments',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13.sp,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDecorations.radiusMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
