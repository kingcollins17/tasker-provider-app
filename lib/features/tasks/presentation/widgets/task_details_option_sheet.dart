import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tasker_app/core/models/api/tasks/task.dart';
import 'package:tasker_app/core/providers/tasks_provider.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/ui/widgets/adjust_task_price_sheet.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';
import 'package:tasker_app/features/tasks/tasks_routes.dart';
import 'pin_display_sheet.dart';

enum TaskOptionAction { startTask, completeTask, getPin, call, report, adjustPrice }

class TaskDetailsOptionSheet extends ConsumerWidget {
  final Task task;

  const TaskDetailsOptionSheet({super.key, required this.task});

  static Future<TaskOptionAction?> show(
    BuildContext context, {
    required Task task,
  }) {
    return showModalBottomSheet<TaskOptionAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TaskDetailsOptionSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final taskId = task.id ?? '';
    final isAssignedAsync = ref.watch(isUserAssignedToTaskProvider(taskId));
    final isAssigned = isAssignedAsync.value ?? false;

    final assignmentAsync = ref.watch(taskAssignmentProvider(taskId));
    final assignment = assignmentAsync.value;

    final isInProgress = task.status?.toLowerCase() == 'in_progress';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.border : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Sheet Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Options',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimary
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Manage actions for this task',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18.r,
                        color: isDark
                            ? AppColors.textSecondary
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Options List
              if (isAssigned) ...[
                if (isInProgress)
                  _OptionTile(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Complete Task',
                    subtitle: 'Mark task as finished & enter completion PIN',
                    onTap: () async {
                      try {
                        Navigator.of(context).pop(TaskOptionAction.completeTask);
                        final rootContext =
                            NavigatorKeys.rootNavigatorKey.currentContext;
                        if (rootContext == null) return;

                        await rootContext.pushNamed(
                          TasksRoutes.pinEntryRoute,
                          pathParameters: {'taskId': taskId},
                          queryParameters: {
                            'mode': 'completePin',
                            'isInitialCash': 'true',
                          },
                        );
                      } catch (e, st) {
                        debugLog('Error in completeTask handler: $e\n$st');
                      }
                    },
                    isDark: isDark,
                  )
                else
                  _OptionTile(
                    icon: Icons.play_circle_outline_rounded,
                    title: 'Start Task',
                    subtitle: 'Begin task execution & enter start PIN',
                    onTap: () async {
                      try {
                        Navigator.of(context).pop(TaskOptionAction.startTask);
                        final rootContext =
                            NavigatorKeys.rootNavigatorKey.currentContext;
                        if (rootContext == null) return;

                        await rootContext.pushNamed(
                          TasksRoutes.pinEntryRoute,
                          pathParameters: {'taskId': taskId},
                          queryParameters: {
                            'mode': 'startPin',
                            'isInitialCash': 'true',
                          },
                        );
                      } catch (e, st) {
                        debugLog('Error in startTask handler: $e\n$st');
                      }
                    },
                    isDark: isDark,
                  ),

                _OptionTile(
                  icon: Icons.tune_rounded,
                  title: 'Request Price Adjustment',
                  subtitle: 'Propose a price change or additional charge',
                  onTap: () {
                    Navigator.of(context).pop(TaskOptionAction.adjustPrice);
                    AdjustTaskPriceSheet.show(taskId: taskId);
                  },
                  isDark: isDark,
                ),
              ],

              if (assignment != null)
                _OptionTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Get Identity PIN',
                  subtitle: 'View verification PIN for customer check',
                  onTap: () {
                    Navigator.of(context).pop(TaskOptionAction.getPin);
                    final rootContext =
                        NavigatorKeys.rootNavigatorKey.currentContext;
                    if (rootContext != null) {
                      PinDisplaySheet.show(rootContext, pin: assignment.pin);
                    }
                  },
                  isDark: isDark,
                ),

              if (isAssigned)
                _OptionTile(
                  icon: Icons.phone_outlined,
                  title: 'Call Customer',
                  subtitle: 'Connect directly via phone call',
                  onTap: () => Navigator.of(context).pop(TaskOptionAction.call),
                  isDark: isDark,
                ),

              _OptionTile(
                icon: Icons.report_problem_outlined,
                title: 'Report Task',
                subtitle: 'Flag issues, safety concerns or cancellation',
                onTap: () => Navigator.of(context).pop(TaskOptionAction.report),
                isDark: isDark,
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.textPrimary : const Color(0xFF0F172A));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 22.r,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDestructive
                            ? AppColors.error.withValues(alpha: 0.8)
                            : (isDark
                                ? AppColors.textMuted
                                : Colors.grey.shade600),
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.6)
                  : (isDark
                      ? AppColors.textMuted.withValues(alpha: 0.6)
                      : Colors.grey.shade400),
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}
