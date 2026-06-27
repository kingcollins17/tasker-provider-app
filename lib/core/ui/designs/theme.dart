import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'decorations.dart';
import 'text_styles.dart';

/// Aggregated application themes (Light and Dark) that implement
/// the extracted brand colors, typography (DM Sans), and custom layout styling.
class AppTheme {
  AppTheme._();

  // --- LIGHT THEME DATA ---

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.textPrimary, // Slate 50
      // Text Theme with DM Sans
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        titleLarge: AppTextStyles.h2.copyWith(
          color: AppColors.background, // Slate 900
        ),
        titleMedium: AppTextStyles.h3.copyWith(
          color: AppColors.surface, // Slate 800
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.border, // Slate 700
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF475569), // Slate 600
        ),
        labelLarge: AppTextStyles.label.copyWith(
          color: AppColors.textMuted, // Slate 500
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
          borderRadius: AppDecorations.radiusMd,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: AppDecorations.radiusMd,
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDecorations.radiusMd,
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDecorations.radiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
    );
  }

  // --- DARK THEME DATA ---

  /// Dark Theme Configuration (Premium Slate Blue Style)
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // Text Theme with DM Sans
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        titleLarge: AppTextStyles.h2,
        titleMedium: AppTextStyles.h3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.label.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: AppDecorations.radiusMd,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppDecorations.radiusMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDecorations.radiusMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDecorations.radiusMd,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
}
