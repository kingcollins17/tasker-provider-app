import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/designs/designs.dart';

/// Private reference to the active loading overlay entry.
OverlayEntry? _loadingEntry;

/// Extension on [BuildContext] to show and hide loading overlay.
extension LoadingContextExt on BuildContext {
  /// Shows a premium loading overlay.
  void showLoading([VoidCallback? onShown]) {
    if (_loadingEntry != null) {
      onShown?.call();
      return;
    }

    final isDark = Theme.of(this).brightness == Brightness.dark;

    _loadingEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Semi-transparent background
          ModalBarrier(
            dismissible: false,
            color: (isDark ? AppColors.background : Colors.black).withValues(
              alpha: 0.5,
            ),
          ),
          // Centered loader card
          Center(
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16.r,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: SpinKitFadingCircle(
                  color: AppColors.primary,
                  size: 50.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(this).insert(_loadingEntry!);
    onShown?.call();
  }

  /// Hides the active loading overlay.
  void hideLoading([VoidCallback? onHidden]) {
    if (_loadingEntry != null) {
      _loadingEntry!.remove();
      _loadingEntry = null;
    }
    onHidden?.call();
  }
}
