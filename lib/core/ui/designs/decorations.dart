import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

/// Design decoration templates to maintain a premium feel throughout the app.
class AppDecorations {
  AppDecorations._();

  // --- BORDER RADII ---

  /// Small Border Radius (8dp)
  static BorderRadius get radiusSm => BorderRadius.circular(8.r);

  /// Medium Border Radius (12dp)
  static BorderRadius get radiusMd => BorderRadius.circular(12.r);

  /// Large Border Radius (16dp)
  static BorderRadius get radiusLg => BorderRadius.circular(16.r);

  /// Extra Large Border Radius (24dp)
  static BorderRadius get radiusXl => BorderRadius.circular(24.r);

  // --- CARD & CONTAINER DECORATIONS ---

  /// Standard dark surface container decoration with subtle border
  static BoxDecoration get container => BoxDecoration(
    color: AppColors.surface,
    borderRadius: radiusMd,
    border: Border.all(color: AppColors.border, width: 1.r),
  );

  /// Elevated/Glow Container decoration for highlighting special features
  static BoxDecoration get containerElevated => BoxDecoration(
    color: AppColors.surface,
    borderRadius: radiusMd,
    border: Border.all(color: AppColors.border, width: 1.r),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.1),
        blurRadius: 16.r,
        offset: const Offset(0, 8),
      ),
    ],
  );

  /// Brand Gradient Container (utilizes Primary and Secondary Logo colors)
  static BoxDecoration get containerGradient => BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.primary, AppColors.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: radiusMd,
  );

  // --- INPUT FIELD STYLES ---

  /// Standard InputDecoration theme for text inputs
  static InputDecoration inputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: AppColors.border, width: 1.r),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: AppColors.border, width: 1.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: AppColors.accent, width: 1.5.r),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: AppColors.error, width: 1.r),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radiusMd,
        borderSide: BorderSide(color: AppColors.error, width: 1.5.r),
      ),
    );
  }
}
