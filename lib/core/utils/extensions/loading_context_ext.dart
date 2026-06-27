import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/designs/designs.dart';

/// Private reference to the active loading overlay entry.
OverlayEntry? _loadingEntry;

/// Extension on [BuildContext] to show and hide loading overlay.
extension LoadingContextExt on BuildContext {
  /// Shows a premium loading overlay with animated spinner.
  void showLoading([VoidCallback? onShown]) {
    if (_loadingEntry != null) {
      onShown?.call();
      return;
    }

    _loadingEntry = OverlayEntry(
      builder: (context) => const _LoadingOverlay(),
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

/// A premium loading overlay with animated concentric arcs and a pulsing glow.
class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // Outer arc rotation
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Pulsing glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Fade-in entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
      child: Stack(
        children: [
          // Dimmed backdrop
          ModalBarrier(
            dismissible: false,
            color: AppColors.background.withValues(alpha: 0.6),
          ),
          // Spinner
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_spinController, _pulseController]),
              builder: (context, child) {
                final pulseValue = _pulseController.value;
                return CustomPaint(
                  size: Size(64.r, 64.r),
                  painter: _ArcSpinnerPainter(
                    rotation: _spinController.value * 2 * math.pi,
                    pulseValue: pulseValue,
                    primaryColor: AppColors.primary,
                    accentColor: AppColors.primaryLight,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that draws two concentric rotating arcs with a pulsing glow.
class _ArcSpinnerPainter extends CustomPainter {
  final double rotation;
  final double pulseValue;
  final Color primaryColor;
  final Color accentColor;

  _ArcSpinnerPainter({
    required this.rotation,
    required this.pulseValue,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.62;

    // Pulsing glow behind the arcs
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.10 + 0.12 * pulseValue)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18 + 8 * pulseValue);
    canvas.drawCircle(center, outerRadius * 0.7, glowPaint);

    // Outer arc
    final outerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius - 2),
      0,
      math.pi * 1.2,
      false,
      outerPaint,
    );
    canvas.restore();

    // Inner arc (counter-rotation, accent color)
    final innerPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotation * 1.4);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      math.pi * 0.3,
      math.pi * 0.9,
      false,
      innerPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArcSpinnerPainter oldDelegate) =>
      rotation != oldDelegate.rotation || pulseValue != oldDelegate.pulseValue;
}
