import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Standard spacing and layout dimensions for Tasker.
/// Leverages flutter_screenutil to ensure proportional scaling across devices.
class AppSpacing {
  AppSpacing._();

  // --- RAW SPACING VALUES ---

  /// Extra Small spacing unit (4dp)
  static double get xs => 4.r;

  /// Small spacing unit (8dp)
  static double get sm => 8.r;

  /// Medium spacing unit (16dp)
  static double get md => 16.r;

  /// Large spacing unit (24dp)
  static double get lg => 24.r;

  /// Extra Large spacing unit (32dp)
  static double get xl => 32.r;

  /// Double Extra Large spacing unit (48dp)
  static double get xxl => 48.r;

  // --- HORIZONTAL SPACE (SizedBox) ---

  static Widget get wXs => SizedBox(width: xs);
  static Widget get wSm => SizedBox(width: sm);
  static Widget get wMd => SizedBox(width: md);
  static Widget get wLg => SizedBox(width: lg);
  static Widget get wXl => SizedBox(width: xl);

  // --- VERTICAL SPACE (SizedBox) ---

  static Widget get hXs => SizedBox(height: xs);
  static Widget get hSm => SizedBox(height: sm);
  static Widget get hMd => SizedBox(height: md);
  static Widget get hLg => SizedBox(height: lg);
  static Widget get hXl => SizedBox(height: xl);
  static Widget get hXxl => SizedBox(height: xxl);

  // --- PADDING & MARGIN EDGE INSETS ---

  /// Uniform padding on all sides
  static EdgeInsets get pAllXs => EdgeInsets.all(xs);
  static EdgeInsets get pAllSm => EdgeInsets.all(sm);
  static EdgeInsets get pAllMd => EdgeInsets.all(md);
  static EdgeInsets get pAllLg => EdgeInsets.all(lg);
  static EdgeInsets get pAllXl => EdgeInsets.all(xl);

  /// Symmetric horizontal padding
  static EdgeInsets get pHorsXs => EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets get pHorsSm => EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get pHorsMd => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get pHorsLg => EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get pHorsXl => EdgeInsets.symmetric(horizontal: xl);

  /// Symmetric vertical padding
  static EdgeInsets get pVertsXs => EdgeInsets.symmetric(vertical: xs);
  static EdgeInsets get pVertsSm => EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get pVertsMd => EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get pVertsLg => EdgeInsets.symmetric(vertical: lg);
  static EdgeInsets get pVertsXl => EdgeInsets.symmetric(vertical: xl);
}
