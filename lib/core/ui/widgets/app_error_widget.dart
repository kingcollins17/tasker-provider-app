import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/utils/extensions/error_ext.dart';
import '../designs/colors.dart';
import '../designs/text_styles.dart';

/// Defines the visual variation and size of [AppErrorWidget] based on UI context.
enum AppErrorSize {
  /// Standard full-screen / main section layout.
  large,

  /// Compact layout suitable for cards, modals, or smaller containers.
  compact,

  /// Small layout with minimal dimensions for tight list sections or nested components.
  small,

  /// Ultra-compact horizontal row layout (icon + text + action inline).
  inline,
}

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

  /// The size variation of the error widget. Defaults to [AppErrorSize.large].
  final AppErrorSize size;

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
    bool isCompact = false,
    AppErrorSize? size,
    this.padding,
    this.extraAction,
  }) : size = size ?? (isCompact ? AppErrorSize.compact : AppErrorSize.large);

  /// Convenient constructor for compact error presentation.
  const AppErrorWidget.compact({
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
    this.padding,
    this.extraAction,
  }) : size = AppErrorSize.compact;

  /// Convenient constructor for small error presentation (e.g. inside list views or section cards).
  const AppErrorWidget.small({
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
    this.padding,
    this.extraAction,
  }) : size = AppErrorSize.small;

  /// Convenient constructor for horizontal inline row error presentation.
  const AppErrorWidget.inline({
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
    this.padding,
    this.extraAction,
  }) : size = AppErrorSize.inline;

  /// Backwards compatibility getter for [isCompact].
  bool get isCompact => size == AppErrorSize.compact || size == AppErrorSize.small;

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

    if (size == AppErrorSize.inline) {
      return _buildInlineLayout(
        context: context,
        isDark: isDark,
        effectiveTitle: effectiveTitle,
        effectiveMessage: effectiveMessage,
        effectiveIcon: effectiveIcon,
        accentColor: accentColor,
        splashColor: splashColor,
        defaultButtonLabel: defaultButtonLabel,
      );
    }

    // Dimension definitions based on size variation
    final double iconContainerPadding;
    final double iconSize;
    final double titleFontSize;
    final double messageFontSize;
    final double spacingAfterIcon;
    final double spacingAfterTitle;
    final double spacingAfterMessage;
    final double buttonHeight;
    final double? buttonWidth;
    final double buttonFontSize;
    final double buttonIconSize;
    final double maxMessageWidth;
    final EdgeInsetsGeometry defaultPadding;

    switch (size) {
      case AppErrorSize.large:
        iconContainerPadding = 20.r;
        iconSize = 44.r;
        titleFontSize = 20.sp;
        messageFontSize = 13.sp;
        spacingAfterIcon = 20.h;
        spacingAfterTitle = 10.h;
        spacingAfterMessage = 24.h;
        buttonHeight = 44.h;
        buttonWidth = 200.w;
        buttonFontSize = 14.sp;
        buttonIconSize = 18.r;
        maxMessageWidth = 320.w;
        defaultPadding = EdgeInsets.symmetric(horizontal: 28.w, vertical: 36.h);
        break;

      case AppErrorSize.compact:
        iconContainerPadding = 14.r;
        iconSize = 28.r;
        titleFontSize = 15.sp;
        messageFontSize = 12.sp;
        spacingAfterIcon = 12.h;
        spacingAfterTitle = 6.h;
        spacingAfterMessage = 16.h;
        buttonHeight = 36.h;
        buttonWidth = 140.w;
        buttonFontSize = 12.sp;
        buttonIconSize = 16.r;
        maxMessageWidth = 260.w;
        defaultPadding = EdgeInsets.all(16.r);
        break;

      case AppErrorSize.small:
        iconContainerPadding = 10.r;
        iconSize = 22.r;
        titleFontSize = 14.sp;
        messageFontSize = 11.sp;
        spacingAfterIcon = 8.h;
        spacingAfterTitle = 4.h;
        spacingAfterMessage = 12.h;
        buttonHeight = 32.h;
        buttonWidth = 110.w;
        buttonFontSize = 11.sp;
        buttonIconSize = 14.r;
        maxMessageWidth = 220.w;
        defaultPadding = EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h);
        break;

      case AppErrorSize.inline:
        return const SizedBox.shrink();
    }

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
                padding: EdgeInsets.all(iconContainerPadding),
                decoration: BoxDecoration(
                  color: splashColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  effectiveIcon,
                  size: iconSize,
                  color: accentColor,
                ),
              ),

            SizedBox(height: spacingAfterIcon),

            // ─── ERROR TITLE ───
            Text(
              effectiveTitle,
              style: AppTextStyles.h2.copyWith(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: spacingAfterTitle),

            // ─── ERROR SUBTITLE / MESSAGE ───
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxMessageWidth),
              child: Text(
                effectiveMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: messageFontSize,
                  color: isDark ? AppColors.textSecondary : Colors.grey[600],
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // ─── ACTION BUTTON ───
            if (onRetry != null) ...[
              SizedBox(height: spacingAfterMessage),
              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: buttonIconSize),
                      SizedBox(width: 4.w),
                      Text(
                        defaultButtonLabel,
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: buttonFontSize,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (extraAction != null) ...[
              SizedBox(height: 8.h),
              extraAction!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineLayout({
    required BuildContext context,
    required bool isDark,
    required String effectiveTitle,
    required String effectiveMessage,
    required IconData effectiveIcon,
    required Color accentColor,
    required Color splashColor,
    required String defaultButtonLabel,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : const Color(0xFFFFF5F3),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: splashColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                effectiveIcon,
                size: 18.r,
                color: accentColor,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    effectiveTitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    effectiveMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.textSecondary : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(width: 8.w),
              InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 14.r, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        defaultButtonLabel,
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

