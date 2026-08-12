import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Comprehensive text styles for Tasker using Poppins font.
/// Integrated with ScreenUtil for responsive scaling and fallback fonts for currency symbols (e.g. ₦).
class AppTextStyles {
  AppTextStyles._();

  static const List<String> _fallbackFonts = ['Roboto', 'Arial', 'sans-serif'];

  // --- HEADINGS ---

  /// Hero Heading 1 (e.g., Intro/Large titles)
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    height: 1.2,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  /// Heading 2 (e.g., Section Headers)
  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    height: 1.25,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  /// Heading 3 (e.g., Card/Sub-section Headers)
  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  /// Subtitle (e.g., Section Descriptors/Feature subheaders)
  static TextStyle get subtitle => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  // --- BODY TEXT ---

  /// Large Body Text
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    height: 1.5,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  /// Standard/Medium Body Text
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    height: 1.5,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  /// Small body/details text
  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    height: 1.4,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  // --- BUTTONS & ACTIONS ---

  /// Large Button Text
  static TextStyle get buttonLarge => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  /// Medium Button Text
  static TextStyle get buttonMedium => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  // --- LABELS & CAPTIONS ---

  /// All-caps small uppercase labels
  static TextStyle get labelUppercase => GoogleFonts.poppins(
    fontSize: 11.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  ).copyWith(fontFamilyFallback: _fallbackFonts);

  /// Standard label/caption text
  static TextStyle get label => GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  ).copyWith(fontFamilyFallback: _fallbackFonts);
}
