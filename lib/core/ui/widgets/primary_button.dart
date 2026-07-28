import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../designs/colors.dart';
import '../designs/text_styles.dart';

/// A custom, premium primary button for Tasker.
/// Follows the brand colors, design tokens, and supports loading/disabled states.
class PrimaryButton extends StatelessWidget {
  /// The label to display on the button.
  final String text;

  /// The callback when the button is tapped. If null, the button is disabled.
  final VoidCallback? onPressed;

  /// If true, displays a loading spinner instead of the text/icon.
  final bool isLoading;

  /// If true, stretches the button to the full available width.
  final bool isFullWidth;

  /// Optional icon to display before the text.
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.r,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12.w),
        ] else if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 20.r),
          SizedBox(width: 8.w),
        ],
        Text(
          text,
          style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
        ),
      ],
    );

    final elevatedButton = ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white70,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: buttonContent,
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: elevatedButton)
        : elevatedButton;
  }
}
