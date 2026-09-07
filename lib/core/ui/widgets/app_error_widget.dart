import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/utils/extensions/error_ext.dart';
import '../designs/colors.dart';
import '../designs/text_styles.dart';

/// A highly customizable and reusable error widget that displays a user-friendly error UI.
/// Following modern UI design guidelines with soft icon splash backgrounds, legibility, and custom actions.
class AppErrorWidget extends StatelessWidget {
  /// The raw error object, exception, or string. Will be automatically parsed using [ErrorExt].
  final Object? error;

  /// Optional override for the error title. If null, automatically inferred from [error].
  final String? title;

  /// Optional override for detailed error message. If null, automatically inferred from [error].
  final String? message;

  /// The callback when the retry / action button is tapped.
  /// If null, the button will not be displayed.
  final VoidCallback? onRetry;

  /// Custom text for the button. Defaults to 'Try Again' or 'Ok' based on error context.
  final String? retryText;

  /// Custom icon for the error widget. If null, automatically inferred from [error].
  final IconData? icon;

  /// Custom icon color. Defaults to warm coral accent color.
  final Color? iconColor;

  /// Custom background splash color for the icon container.
  final Color? iconBackgroundColor;

  /// Custom illustration or image widget to display instead of an icon.
  final Widget? customIllustration;

  /// Whether to render in a compact layout (suitable for embedding inside small cards/containers).
  final bool isCompact;

  /// Custom padding around the error widget.
  final EdgeInsetsGeometry? padding;

  /// Optional extra action widget placed below the primary button.
  final Widget? extraAction;

  const AppErrorWidget({
    super.key,
    this.error,
    this.title,
    this.message,
    this.onRetry,
    this.retryText,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.customIllustration,
    this.isCompact = false,
    this.padding,
    this.extraAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Parse the error object or message into a user-friendly ParsedError
    final sourceObject = error ?? message ?? 'An unexpected error occurred.';
    final parsed = sourceObject.toParsedError();

    final effectiveTitle = title ?? (error != null || message == null ? parsed.title : 'Oops! Something went wrong');
    final effectiveMessage = message ?? parsed.message;
    final effectiveIcon = icon ?? parsed.icon;

    // Brand accent coral/orange color matching UI inspo
    final accentColor = iconColor ?? const Color(0xFFFF5436);
    final splashColor = iconBackgroundColor ??
        (isDark ? const Color(0xFF2C1E1B) : const Color(0xFFFFF0EC));

    final isSessionExpired = effectiveTitle.toLowerCase().contains('session');
    final defaultButtonLabel = retryText ?? (isSessionExpired ? 'Ok' : 'Try Again');

    final defaultPadding = isCompact
        ? EdgeInsets.all(16.r)
        : EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h);

    return Center(
      child: Padding(
        padding: padding ?? defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── ICON / ILLUSTRATION SPLASH ───
            if (customIllustration != null)
              customIllustration!
            else
              Container(
                padding: EdgeInsets.all(isCompact ? 14.r : 20.r),
                decoration: BoxDecoration(
                  color: splashColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  effectiveIcon,
                  size: isCompact ? 28.r : 44.r,
                  color: accentColor,
                ),
              ),

            SizedBox(height: isCompact ? 12.h : 20.h),

            // ─── ERROR TITLE ───
            Text(
              effectiveTitle,
              style: AppTextStyles.h2.copyWith(
                fontSize: isCompact ? 15.sp : 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isCompact ? 6.h : 10.h),

            // ─── ERROR SUBTITLE / MESSAGE ───
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isCompact ? 260.w : 320.w),
              child: Text(
                effectiveMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: isCompact ? 12.sp : 13.sp,
                  color: isDark ? AppColors.textSecondary : Colors.grey[600],
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // ─── ACTION BUTTON ───
            if (onRetry != null) ...[
              SizedBox(height: isCompact ? 16.h : 24.h),
              SizedBox(
                width: isCompact ? 140.w : 200.w,
                height: isCompact ? 36.h : 44.h,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  child: Text(
                    defaultButtonLabel,
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 12.sp : 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],

            if (extraAction != null) ...[
              SizedBox(height: 12.h),
              extraAction!,
            ],
          ],
        ),
      ),
    );
  }
}
