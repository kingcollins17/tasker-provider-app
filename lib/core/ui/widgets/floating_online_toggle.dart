import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../designs/designs.dart';

/// Compact and subtle floating online toggle button for provider availability.
class FloatingOnlineToggle extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;

  const FloatingOnlineToggle({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = isOnline ? AppColors.success : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(30.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surface.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: isOnline
                  ? AppColors.success.withValues(alpha: 0.4)
                  : (isDark
                      ? AppColors.border
                      : Colors.grey.withValues(alpha: 0.25)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isOnline
                    ? AppColors.success.withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: 14.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Status Dot LED
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.6),
                            blurRadius: 6.r,
                            spreadRadius: 1.r,
                          ),
                        ]
                      : null,
                ),
              ),
              SizedBox(width: 8.w),

              // Concise Status Labels
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: isOnline
                          ? AppColors.success
                          : (isDark ? AppColors.textPrimary : Colors.black87),
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    isOnline ? "• Active" : "• Tap to work",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 12.w),

              // Action Switch Capsule
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                  border: isOnline
                      ? Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  isOnline ? "Go Offline" : "Go Online",
                  style: AppTextStyles.label.copyWith(
                    color: isOnline ? AppColors.error : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
