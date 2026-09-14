import 'dart:math' as math;
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

/// A modern, refined loading overlay featuring a glassmorphic floating card,
/// smooth spring entrance animation, and custom brand gradient spinner.
class _LoadingOverlay extends StatefulWidget {
  final String? message;

  const _LoadingOverlay({this.message});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasMessage = widget.message != null && widget.message!.trim().isNotEmpty;

    final fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    final scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: Stack(
        children: [
          // Subtle ambient dimmed backdrop with minimal blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: ModalBarrier(
                dismissible: false,
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.12),
              ),
            ),
          ),
          // Centered elevated floating glass card
          Center(
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: hasMessage
                      ? EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h)
                      : EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surface.withValues(alpha: 0.90)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(hasMessage ? 20.r : 16.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : AppColors.primary.withValues(alpha: 0.18),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.22 : 0.10,
                        ),
                        blurRadius: 20.r,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.35 : 0.05,
                        ),
                        blurRadius: 10.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Custom brand spinner widget
                      SizedBox(
                        width: 26.r,
                        height: 26.r,
                        child: AnimatedBuilder(
                          animation: _spinController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _BrandSpinnerPainter(
                                progress: _spinController.value,
                                isDark: isDark,
                              ),
                            );
                          },
                        ),
                      ),
                      if (hasMessage) ...[
                        SizedBox(width: 12.w),
                        Text(
                          widget.message!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimary
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5.sp,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for a sleek brand dual-ring gradient spinner.
class _BrandSpinnerPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _BrandSpinnerPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 3.r) / 2;

    // 1. Muted track background ring
    final trackPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4.r;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Rotating active gradient sweep arc
    final startAngle = progress * 2 * math.pi;
    final sweepAngle = 1.35 * math.pi;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6.r
      ..shader = SweepGradient(
        colors: const [
          AppColors.primaryLight,
          AppColors.primary,
          Colors.transparent,
        ],
        stops: const [0.0, 0.75, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // 3. Central subtle pulsing core dot
    final pulseOpacity = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: pulseOpacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.0.r, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _BrandSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

