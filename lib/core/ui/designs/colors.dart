import 'package:flutter/material.dart';

/// Defines the core color palette for the Tasker application.
/// Colors are extracted from the application logo ([appLogo.png])
/// to maintain brand consistency.
class AppColors {
  AppColors._();

  // --- BRAND COLORS (Extracted from appLogo.png / Styled to match authUI.png) ---

  /// Primary Brand Color: Indigo (RGB: 99, 102, 241)
  static const Color primary = Color(0xFF6366F1);

  /// Light variation of Primary Brand Color
  static const Color primaryLight = Color(0xFF818CF8);

  /// Dark variation of Primary Brand Color
  static const Color primaryDark = Color(0xFF4F46E5);

  /// Secondary Brand Color: Slate/Indigo
  static const Color secondary = Color(0xFF4F46E5);

  /// Light variation of Secondary Brand Color
  static const Color secondaryLight = Color(0xFF818CF8);

  /// Dark variation of Secondary Brand Color
  static const Color secondaryDark = Color(0xFF3730A3);

  /// Accent Brand Color: Indigo
  static const Color accent = Color(0xFF6366F1);

  /// Light Accent Color
  static const Color accentLight = Color(0xFF818CF8);

  /// Deep Navy shade from the logo
  static const Color navy = Color(0xFF1E1B4B);

  // --- NEUTRAL SYSTEM COLORS (Premium Dark Slate Theme) ---

  /// Main background color for the application
  static const Color background = Color(0xFF0F172A);

  /// Card, sheet, and surface container background color
  static const Color surface = Color(0xFF1E293B);

  /// Divider and border outline color
  static const Color border = Color(0xFF334155);

  // --- TEXT COLORS ---

  /// Highlight/Title text color (Slate 50)
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Body/Secondary text color (Slate 300)
  static const Color textSecondary = Color(0xFFCBD5E1);

  /// Captions, hints, and muted text (Slate 500)
  static const Color textMuted = Color(0xFF64748B);

  // --- UTILITY/STATUS COLORS ---

  /// Error color for alerts and destructive actions
  static const Color error = Color(0xFFEF4444);

  /// Success color for positive confirmations
  static const Color success = Color(0xFF10B981);

  /// Warning color for cautious highlights
  static const Color warning = Color(0xFFF59E0B);
}
