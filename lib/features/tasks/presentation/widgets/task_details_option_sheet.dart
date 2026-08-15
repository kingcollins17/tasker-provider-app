import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/models/api/tasks/task.dart';
import 'package:tasker_app/core/providers/tasks_provider.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';
import 'pin_display_sheet.dart';
import 'pin_entry_sheet.dart';

enum TaskOptionAction { startTask, completeTask, getPin, call, report }

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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Task Options',
            style: AppTextStyles.h3.copyWith(
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 24.h),

          // If current user is assigned provider
          if (isAssigned) ...[
            if (isInProgress)
              _OptionTile(
                icon: Icons.check_circle_outline_rounded,
                title: 'Complete Task',
                onTap: () async {
                  try {
                    Navigator.of(context).pop(TaskOptionAction.completeTask);
                    final rootContext =
                        NavigatorKeys.rootNavigatorKey.currentContext;
                    if (rootContext == null) return;

                    await PinEntryAndPaymentModeSheet.show(
                      rootContext,
                      title: 'Enter Completion PIN',
                      subtitle:
                          'Please enter the 4-digit PIN provided by the customer and select the payment mode.',
                      confirmButtonText: 'Complete Task',
                      icon: Icons.check_circle_rounded,
                      showPaymentMode: true,
                      onConfirm: (ref, pin, isCash) async {
                        final paymentMode = isCash ? 'cash' : 'online';
                        final activeContext =
                            NavigatorKeys.rootNavigatorKey.currentContext;
                        if (activeContext != null) activeContext.showLoading();

                        bool success = false;
                        String? error;
                        try {
                          await ref
                              .read(taskManagementProvider.notifier)
                              .completeTask(
                                taskId,
                                pin: pin,
                                paymentMode: paymentMode,
                                onSuccess: () {
                                  success = true;
                                  ref.invalidate(taskDetailProvider(taskId));
                                  ref.invalidate(
                                    taskAssignmentProvider(taskId),
                                  );
                                },
                                onError: (errorMsg) {
                                  success = false;
                                  error = errorMsg;
                                },
                              );
                        } catch (e) {
                          error = e.toString();
                        } finally {
                          final ctx =
                              NavigatorKeys.rootNavigatorKey.currentContext;
                          ctx?.hideLoading();
                        }

                        if (!success && error != null) {
                          final ctx =
                              NavigatorKeys.rootNavigatorKey.currentContext;
                          ctx?.showError(error ?? 'Something went wrong');
                        } else if (success) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final ctx =
                                NavigatorKeys.rootNavigatorKey.currentContext;
                            ctx?.showMessage('Task completed successfully!');
                          });
                        }

                        return success;
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
                onTap: () async {
                  try {
                    Navigator.of(context).pop(TaskOptionAction.startTask);
                    final rootContext =
                        NavigatorKeys.rootNavigatorKey.currentContext;
                    if (rootContext == null) return;

                    await PinEntryAndPaymentModeSheet.show(
                      rootContext,
                      title: 'Enter Start PIN',
                      subtitle:
                          'Please enter the 4-digit PIN provided by the customer to start this task.',
                      confirmButtonText: 'Start Task',
                      icon: Icons.play_circle_fill_rounded,
                      showPaymentMode: false,
                      onConfirm: (ref, pin, isCash) async {
                        final activeContext =
                            NavigatorKeys.rootNavigatorKey.currentContext;
                        if (activeContext != null) activeContext.showLoading();

                        bool success = false;
                        String? error;
                        try {
                          await ref
                              .read(taskManagementProvider.notifier)
                              .startTask(
                                taskId,
                                pin: pin,
                                onSuccess: () {
                                  success = true;
                                  ref.invalidate(taskDetailProvider(taskId));
                                  ref.invalidate(
                                    taskAssignmentProvider(taskId),
                                  );
                                },
                                onError: (errorMsg) {
                                  success = false;
                                  error = errorMsg;
                                },
                              );
                        } catch (e) {
                          error = e.toString();
                        } finally {
                          final ctx =
                              NavigatorKeys.rootNavigatorKey.currentContext;
                          ctx?.hideLoading();
                        }

                        if (!success && error != null) {
                          final ctx =
                              NavigatorKeys.rootNavigatorKey.currentContext;
                          ctx?.showError(error ?? 'Something went wrong');
                        } else if (success) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final ctx =
                                NavigatorKeys.rootNavigatorKey.currentContext;
                            ctx?.showMessage('Task started successfully!');
                          });
                        }

                        return success;
                      },
                    );
                  } catch (e, st) {
                    debugLog('Error in startTask handler: $e\n$st');
                  }
                },
                isDark: isDark,
              ),
          ],

          // If taskAssignmentProvider has value
          if (assignment != null)
            _OptionTile(
              icon: Icons.pin_outlined,
              title: 'Get Identity PIN',
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

          // If current user is assigned provider, show Call option
          if (isAssigned)
            _OptionTile(
              icon: Icons.phone_outlined,
              title: 'Call Customer',
              onTap: () => Navigator.of(context).pop(TaskOptionAction.call),
              isDark: isDark,
            ),
          _OptionTile(
            icon: Icons.report_problem_outlined,
            title: 'Report Task',
            onTap: () => Navigator.of(context).pop(TaskOptionAction.report),
            isDark: isDark,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.title,
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
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.r),
            SizedBox(width: 16.w),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
