import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';

import '../../../core/ui/designs/designs.dart';

/// Private reference to the active loading overlay entry.
OverlayEntry? _loadingEntry;

/// Extension on [BuildContext] to show and hide loading overlay.
extension LoadingContextExt on BuildContext {
  /// Shows a premium loading overlay with an animated spinner card.
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

/// A premium loading overlay featuring glassmorphism backdrop, dual-ring animated spinner,
/// and brand-matching surface styling.
class _LoadingOverlay extends StatefulWidget {
  final String? message;

  const _LoadingOverlay({this.message});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    final scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: Stack(
        children: [
          // Dimmed backdrop with glassmorphic blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: ModalBarrier(
                dismissible: false,
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
          // Centered Loading Content (Floating without container background)
          Center(
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Dual Ring + Brand Glow Core
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _rotationController,
                        _pulseController,
                      ]),
                      builder: (context, child) {
                        final angle =
                            _rotationController.value * 2 * math.pi;
                        final pulse = _pulseController.value;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Radial ambient glow
                            Container(
                              width: 56.r,
                              height: 56.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25 + (pulse * 0.25),
                                    ),
                                    blurRadius: 20.r + (pulse * 10.r),
                                    spreadRadius: 3.r,
                                  ),
                                ],
                              ),
                            ),
                            // Dual Ring Custom Painter
                            CustomPaint(
                              size: Size(64.r, 64.r),
                              painter: _DualRingSpinnerPainter(
                                angle1: angle,
                                angle2: -angle * 1.4,
                                primaryColor: AppColors.primary,
                                accentColor: AppColors.secondaryLight,
                              ),
                            ),
                            // Center Icon Glow
                            Transform.scale(
                              scale: 0.9 + (pulse * 0.15),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedTask01,
                                color: AppColors.primaryLight,
                                size: 24.r,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    // Loading Message Text
                    Text(
                      widget.message ?? 'Please wait...',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        letterSpacing: 0.2,
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

/// Custom painter rendering sleek dual concentric rotating gradient arcs.
class _DualRingSpinnerPainter extends CustomPainter {
  final double angle1;
  final double angle2;
  final Color primaryColor;
  final Color accentColor;

  _DualRingSpinnerPainter({
    required this.angle1,
    required this.angle2,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 4;
    final innerRadius = outerRadius - 9;

    // Outer Gradient Arc
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final outerGradient = SweepGradient(
      colors: [
        primaryColor.withValues(alpha: 0.05),
        primaryColor.withValues(alpha: 0.4),
        primaryColor,
        accentColor,
      ],
      stops: const [0.0, 0.4, 0.8, 1.0],
      transform: GradientRotation(angle1),
    );

    outerPaint.shader = outerGradient.createShader(
      Rect.fromCircle(center: center, radius: outerRadius),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      0,
      math.pi * 1.4,
      false,
      outerPaint,
    );

    // Inner Counter Gradient Arc
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final innerGradient = SweepGradient(
      colors: [
        accentColor.withValues(alpha: 0.05),
        accentColor.withValues(alpha: 0.5),
        accentColor,
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(angle2),
    );

    innerPaint.shader = innerGradient.createShader(
      Rect.fromCircle(center: center, radius: innerRadius),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      0,
      math.pi * 1.1,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DualRingSpinnerPainter oldDelegate) {
    return oldDelegate.angle1 != angle1 ||
        oldDelegate.angle2 != angle2 ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}

