import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/models/api/tasks/task.dart';
import 'package:tasker_app/core/providers/bid_providers.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/ui/widgets/confirmation_dialog.dart';

enum TaskOptionAction { bid, chat, cancelBid, report }

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

    final myBidAsync = ref.watch(myBidProvider(task.id ?? ''));
    final myBid = myBidAsync.value;

    final canBid = switch (task.status?.toLowerCase()) {
      'open' || 'bidding' => true,
      _ => false,
    };

    final isBidPending = switch (myBid?.status?.toLowerCase()) {
      'pending' => true,
      _ => false,
    };

    final showBidButton =
        canBid &&
        switch (myBid?.status?.toLowerCase()) {
          'cancelled' || 'rejected' || 'withdrawn' => false,
          _ => true,
        };

    final showCancelButton = isBidPending;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
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
          if (showBidButton)
            _OptionTile(
              icon: Icons.gavel_rounded,
              title: isBidPending ? 'Update Bid' : 'Send a Bid',
              onTap: () => Navigator.of(context).pop(TaskOptionAction.bid),
              isDark: isDark,
            ),
          _OptionTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Chat with Customer',
            onTap: () => Navigator.of(context).pop(TaskOptionAction.chat),
            isDark: isDark,
          ),
          if (showCancelButton)
            _OptionTile(
              icon: Icons.cancel_outlined,
              title: 'Cancel Bid',
              onTap: () async {
                final confirm = await ConfirmationDialog.show(
                  context,
                  title: 'Cancel Bid',
                  message:
                      'Are you sure you want to cancel your bid? This action cannot be undone.',
                  confirmText: 'Cancel Bid',
                  cancelText: 'Keep Bid',
                  isDestructive: true,
                  icon: Icons.warning_amber_rounded,
                );
                if (confirm && context.mounted) {
                  Navigator.of(context).pop(TaskOptionAction.cancelBid);
                }
              },
              isDark: isDark,
              isDestructive: true,
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
