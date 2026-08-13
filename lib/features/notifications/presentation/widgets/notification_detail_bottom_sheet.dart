import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/api/notifications/notification_item.dart';
import '../../../../core/ui/designs/designs.dart';

class NotificationDetailBottomSheet extends StatelessWidget {
  final NotificationItem item;

  const NotificationDetailBottomSheet({super.key, required this.item});

  static Future<void> show(
    BuildContext context, {
    required NotificationItem item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationDetailBottomSheet(item: item),
    );
  }

  IconData _getIcon(String? title) {
    final t = title?.toLowerCase() ?? '';
    if (t.contains('prescription') || t.contains('medical')) {
      return Icons.medical_information_outlined;
    } else if (t.contains('priority') || t.contains('urgent')) {
      return Icons.flag_outlined;
    } else if (t.contains('payment') ||
        t.contains('invoice') ||
        t.contains('earnings')) {
      return Icons.payment_outlined;
    } else if (t.contains('welcome') ||
        t.contains('profile') ||
        t.contains('account')) {
      return Icons.person_outline_rounded;
    } else if (t.contains('otp') ||
        t.contains('verification') ||
        t.contains('password')) {
      return Icons.lock_outline_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color _getIconColor(String? title) {
    final t = title?.toLowerCase() ?? '';
    if (t.contains('prescription') || t.contains('medical')) {
      return AppColors.success;
    } else if (t.contains('priority') || t.contains('urgent')) {
      return AppColors.error;
    } else if (t.contains('payment') ||
        t.contains('invoice') ||
        t.contains('earnings')) {
      return AppColors.primaryLight;
    } else if (t.contains('welcome')) {
      return Colors.blue;
    }
    return AppColors.primary;
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy • h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final iconData = _getIcon(item.title);
    final iconColor = _getIconColor(item.title);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.border : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Top row with icon & close button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor, size: 24.r),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type?.toUpperCase() ?? 'NOTIFICATION',
                          style: AppTextStyles.labelUppercase.copyWith(
                            color: iconColor,
                            letterSpacing: 1.2,
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        if (item.createdAt != null)
                          Text(
                            _formatDateTime(item.createdAt!),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textMuted
                                  : Colors.black54,
                              fontSize: 11.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 22.r,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Title
              Text(
                item.title ?? 'Notification',
                style: AppTextStyles.h3.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 12.h),

              // Notification Body Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.background.withValues(alpha: 0.5)
                      : Colors.grey.shade100,
                  borderRadius: AppDecorations.radiusMd,
                  border: Border.all(
                    color: isDark ? AppColors.border : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  item.body ?? 'No message body available.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.9),
                    height: 1.5,
                    fontSize: 14.sp,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Close / Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDecorations.radiusLg,
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
