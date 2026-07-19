import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../designs/colors.dart';
import '../designs/text_styles.dart';
import 'primary_button.dart';

/// A customizable error widget to be shown whenever an error state is reached.
/// Displays an icon, title, message, and an optional retry button.
class AppErrorWidget extends StatelessWidget {
  /// The title of the error.
  final String title;

  /// The detailed error message.
  final String message;

  /// The callback when the retry button is tapped.
  /// If null, the retry button will not be displayed.
  final VoidCallback? onRetry;

  /// Custom text for the retry button. Defaults to 'Try Again'.
  final String retryText;

  /// Custom icon for the error widget. Defaults to [Icons.warning_amber_rounded].
  final IconData? icon;

  const AppErrorWidget({
    super.key,
    this.title = 'Oops! Something went wrong',
    required this.message,
    this.onRetry,
    this.retryText = 'Try Again',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.warning_amber_rounded,
                size: 48.r,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 24.h),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 32.h),
              PrimaryButton(
                text: retryText,
                onPressed: onRetry,
                isFullWidth: false,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
