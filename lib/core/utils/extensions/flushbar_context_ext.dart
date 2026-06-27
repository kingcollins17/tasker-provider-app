import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/designs/designs.dart';

/// Extension on [BuildContext] to show highly customized Flushbars and Toasts.
extension FlushbarContextExt on BuildContext {
  /// Displays a generic message banner.
  void showMessage(String message, {String? title}) {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    Flushbar(
      titleText: title != null
          ? Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              ),
            )
          : null,
      messageText: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondary : const Color(0xFF334155),
        ),
      ),
      icon: Icon(
        Icons.chat_bubble_outline_rounded,
        color: AppColors.primary,
        size: 24.r,
      ),
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      borderColor: isDark ? AppColors.border : const Color(0xFFE2E8F0),
      borderWidth: 1.r,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.r),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 400),
    ).show(this);
  }

  /// Displays an error banner.
  void showError(String message, {String? title}) {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    Flushbar(
      titleText: title != null
          ? Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              ),
            )
          : null,
      messageText: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondary : const Color(0xFF334155),
        ),
      ),
      icon: Icon(
        Icons.error_outline_rounded,
        color: AppColors.error,
        size: 24.r,
      ),
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      borderColor: AppColors.error.withValues(alpha: 0.3),
      borderWidth: 1.r,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.r),
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 400),
    ).show(this);
  }

  /// Displays an informational banner.
  void showInfo(String message, {String? title}) {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    Flushbar(
      titleText: title != null
          ? Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              ),
            )
          : null,
      messageText: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textSecondary : const Color(0xFF334155),
        ),
      ),
      icon: Icon(
        Icons.info_outline_rounded,
        color: AppColors.primary,
        size: 24.r,
      ),
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      borderWidth: 1.r,
      borderRadius: BorderRadius.circular(12.r),
      margin: EdgeInsets.all(16.r),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 400),
    ).show(this);
  }

  /// Displays a simple bottom toast notification.
  void showToast(String message) {
    Flushbar(
      messageText: Center(
        child: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(24.r),
      margin: EdgeInsets.symmetric(horizontal: 48.w, vertical: 32.h),
      duration: const Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.BOTTOM,
      animationDuration: const Duration(milliseconds: 300),
    ).show(this);
  }
}
