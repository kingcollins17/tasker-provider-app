import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';

import '../../../core/ui/designs/designs.dart';

/// Private reference to the active loading overlay entry.
OverlayEntry? _loadingEntry;

/// Extension on [BuildContext] to show and hide loading overlay.
extension LoadingContextExt on BuildContext {
  /// Shows a subtle, clean loading overlay.
  void showLoading([VoidCallback? onShown, String? message]) {
    if (_loadingEntry != null) {
      onShown?.call();
      return;
    }

    _loadingEntry = OverlayEntry(
      builder: (context) => _LoadingOverlay(message: message),
    );

    final overlayState =
        Overlay.maybeOf(this, rootOverlay: true) ??
        NavigatorKeys.rootNavigatorKey.currentState?.overlay;

    if (overlayState != null) {
      overlayState.insert(_loadingEntry!);
      onShown?.call();
    }
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

/// A subtle, non-intrusive loading overlay with a compact floating card and smooth spinner.
class _LoadingOverlay extends StatefulWidget {
  final String? message;

  const _LoadingOverlay({this.message});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: Stack(
        children: [
          // Soft dimmed backdrop with subtle blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
              child: ModalBarrier(
                dismissible: false,
                color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.18),
              ),
            ),
          ),
          // Centered compact floating card
          Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surface.withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isDark
                        ? AppColors.border
                        : Colors.black.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 16.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      widget.message ?? 'Loading...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textPrimary : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
