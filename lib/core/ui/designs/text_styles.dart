import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Comprehensive text styles for Tasker using DM Sans font.
/// Integrated with ScreenUtil for responsive scaling.
class AppTextStyles {
  AppTextStyles._();

  // --- HEADINGS ---

  /// Hero Heading 1 (e.g., Intro/Large titles)
  static TextStyle get h1 => GoogleFonts.dmSans(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  /// Heading 2 (e.g., Section Headers)
  static TextStyle get h2 => GoogleFonts.dmSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  /// Heading 3 (e.g., Card/Sub-section Headers)
  static TextStyle get h3 => GoogleFonts.dmSans(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// Subtitle (e.g., Section Descriptors/Feature subheaders)
  static TextStyle get subtitle => GoogleFonts.dmSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // --- BODY TEXT ---

  /// Large Body Text
  static TextStyle get bodyLarge => GoogleFonts.dmSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// Standard/Medium Body Text
  static TextStyle get bodyMedium => GoogleFonts.dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  /// Small body/details text
  static TextStyle get bodySmall => GoogleFonts.dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // --- BUTTONS & ACTIONS ---

  /// Large Button Text
  static TextStyle get buttonLarge => GoogleFonts.dmSans(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  /// Medium Button Text
  static TextStyle get buttonMedium => GoogleFonts.dmSans(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  // --- LABELS & CAPTIONS ---

  /// All-caps small uppercase labels
  static TextStyle get labelUppercase => GoogleFonts.dmSans(
    fontSize: 11.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  /// Standard label/caption text
  static TextStyle get label => GoogleFonts.dmSans(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );
}
