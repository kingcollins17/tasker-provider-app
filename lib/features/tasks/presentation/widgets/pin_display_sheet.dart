import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';

class PinDisplaySheet extends StatelessWidget {
  final String? pin;

  const PinDisplaySheet({super.key, this.pin});

  static Future<void> show(BuildContext context, {String? pin}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PinDisplaySheet(pin: pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayPin = (pin != null && pin!.isNotEmpty) ? pin! : '----';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 36.h),
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

          // Lock / PIN Icon Badge
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.pin_rounded,
                color: AppColors.primary,
                size: 32.r,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          Text(
            'Identity PIN',
            style: AppTextStyles.h2.copyWith(fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),

          Text(
            'Share this PIN with the customer to confirm your identity.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
              fontSize: 13.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 28.h),

          // Styled PIN Digits Container
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayPin,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8.w,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 28.h),

          // Copy PIN Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (pin != null && pin!.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: pin!));
                  context.showMessage('PIN copied to clipboard');
                }
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copy PIN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
