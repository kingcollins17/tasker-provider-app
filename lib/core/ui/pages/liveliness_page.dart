import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_liveness/flutter_face_liveness.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/extensions/flushbar_context_ext.dart';
import '../designs/designs.dart';

/// A full-screen page using [LivenessController] for KYC selfie verification.
///
/// Captures a photo from the camera on liveness success and returns it as a [File].
/// Use the static [check] method to push this page.
class LivelinessPage extends StatefulWidget {
  const LivelinessPage({super.key});

  /// Pushes the liveness check page and returns the captured selfie [File]
  /// on success, or `null` if cancelled/failed.
  static Future<File?> check(BuildContext context) async {
    return await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (context) => const LivelinessPage()),
    );
  }

  @override
  State<LivelinessPage> createState() => _LivelinessPageState();
}

class _LivelinessPageState extends State<LivelinessPage> {
  late final LivenessController _controller;
  bool _hasCompleted = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _controller = LivenessController(
      actions: [LivenessAction.turnLeft, LivenessAction.turnRight],
      config: LivenessConfig(
        enableAntiSpoof: true,
        enableVideoReplayDetection: true,
        randomizeActions: true,
        sessionTimeoutMs: 120000,
        themeMode: ThemeMode.dark,
      ),
      onSuccess: _onSuccess,
      onFailed: _onFailed,
    );
    _controller.addListener(_onControllerUpdate);
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
    } catch (e) {
      if (mounted) {
        context.showError('Failed to initialize camera: $e');
        Navigator.pop(context, null);
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _onSuccess(LivenessResult result) async {
    if (_hasCompleted || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      File? capturedFile;
      final cameraCtrl = _controller.cameraController;

      if (cameraCtrl != null && cameraCtrl.value.isInitialized) {
        final XFile xFile = await cameraCtrl.takePicture();
        capturedFile = File(xFile.path);
      }

      _hasCompleted = true;
      if (mounted) {
        Navigator.pop(context, capturedFile);
      }
    } catch (e) {
      // If capture fails, still pop with null rather than leaving user stuck
      _hasCompleted = true;
      if (mounted) {
        context.showError('Liveness passed but photo capture failed.');
        Navigator.pop(context, null);
      }
    }
  }

  void _onFailed(String reason) {
    if (_hasCompleted) return;
    _hasCompleted = true;
    if (mounted) {
      context.showError(reason);
      Navigator.pop(context, null);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  // --- Status helpers ---

  String get _statusText {
    switch (_controller.status) {
      case DetectionStatus.initializing:
        return 'Initializing camera…';
      case DetectionStatus.noFace:
        return 'Position your face in the frame';
      case DetectionStatus.multipleFaces:
        return 'Only one face allowed';
      case DetectionStatus.faceTooFar:
        return 'Move closer';
      case DetectionStatus.faceTooClose:
        return 'Move back a little';
      case DetectionStatus.faceNotCentered:
        return 'Centre your face';
      case DetectionStatus.lowLight:
        return 'Too dark — move to a brighter area';
      case DetectionStatus.overExposed:
        return 'Too bright — avoid direct light';
      case DetectionStatus.blurry:
        return 'Hold steady — image is blurry';
      case DetectionStatus.fakeDetected:
        return 'Spoof detected — use your real face';
      case DetectionStatus.ready:
        return 'Great! Now follow the instructions';
      case DetectionStatus.actionInProgress:
        return _actionInstructionText;
      case DetectionStatus.completed:
        return 'Capturing photo…';
      case DetectionStatus.failed:
        return 'Verification failed';
    }
  }

  String get _actionInstructionText {
    final action = _controller.currentAction;
    if (action == null) return 'Follow the instructions';
    switch (action) {
      case LivenessAction.blink:
        return 'Blink your eyes';
      case LivenessAction.turnLeft:
        return 'Turn your head left';
      case LivenessAction.turnRight:
        return 'Turn your head right';
      case LivenessAction.lookUp:
        return 'Look up';
      case LivenessAction.lookDown:
        return 'Look down';
      case LivenessAction.smile:
        return 'Smile!';
      case LivenessAction.openMouth:
        return 'Open your mouth';
    }
  }

  IconData get _statusIcon {
    switch (_controller.status) {
      case DetectionStatus.initializing:
        return Icons.hourglass_top_rounded;
      case DetectionStatus.noFace:
        return Icons.face_retouching_natural_rounded;
      case DetectionStatus.multipleFaces:
        return Icons.group_off_rounded;
      case DetectionStatus.faceTooFar:
        return Icons.zoom_in_rounded;
      case DetectionStatus.faceTooClose:
        return Icons.zoom_out_rounded;
      case DetectionStatus.faceNotCentered:
        return Icons.center_focus_strong_rounded;
      case DetectionStatus.lowLight:
        return Icons.light_mode_rounded;
      case DetectionStatus.overExposed:
        return Icons.wb_sunny_rounded;
      case DetectionStatus.blurry:
        return Icons.blur_on_rounded;
      case DetectionStatus.fakeDetected:
        return Icons.warning_rounded;
      case DetectionStatus.ready:
      case DetectionStatus.actionInProgress:
        return Icons.check_circle_outline_rounded;
      case DetectionStatus.completed:
        return Icons.camera_rounded;
      case DetectionStatus.failed:
        return Icons.error_outline_rounded;
    }
  }

  Color get _statusColor {
    switch (_controller.status) {
      case DetectionStatus.ready:
      case DetectionStatus.actionInProgress:
      case DetectionStatus.completed:
        return AppColors.success;
      case DetectionStatus.fakeDetected:
      case DetectionStatus.failed:
        return AppColors.error;
      case DetectionStatus.lowLight:
      case DetectionStatus.overExposed:
      case DetectionStatus.blurry:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = _controller.isInitialized;
    final cameraCtrl = _controller.cameraController;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (isInitialized &&
              cameraCtrl != null &&
              cameraCtrl.value.isInitialized)
            ClipRect(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: cameraCtrl.value.previewSize?.height ?? 1,
                    height: cameraCtrl.value.previewSize?.width ?? 1,
                    child: CameraPreview(cameraCtrl),
                  ),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // Darkened overlay with oval cutout
          if (isInitialized) _buildOvalOverlay(),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    _buildGlassButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context, null),
                    ),
                    const Spacer(),
                    Text(
                      'Selfie Verification',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontSize: 18.sp,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: 40.r), // Balance the close button
                  ],
                ),
              ),
            ),
          ),

          // Bottom panel
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomPanel()),

          // Capturing overlay
          if (_isCapturing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48.r,
                      height: 48.r,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Capturing selfie…',
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 22.r),
      ),
    );
  }

  Widget _buildOvalOverlay() {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _OvalCutoutPainter(borderColor: _statusColor),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress dots
              if (_controller.isInitialized) _buildProgressDots(),
              SizedBox(height: 16.h),

              // Status instruction
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: _statusColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_statusIcon, color: _statusColor, size: 22.r),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        _statusText,
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    final total =
        _controller.completedActions.length +
        _controller.remainingActions.length;
    final completed = _controller.completedActions.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isDone = index < completed;
        final isCurrent = index == completed;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isCurrent ? 28.w : 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.success
                : isCurrent
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(5.r),
            boxShadow: isDone || isCurrent
                ? [
                    BoxShadow(
                      color: (isDone ? AppColors.success : AppColors.primary)
                          .withValues(alpha: 0.4),
                      blurRadius: 6.r,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

/// Custom painter that draws a semi-transparent overlay with an oval cutout
/// for positioning the face.
class _OvalCutoutPainter extends CustomPainter {
  final Color borderColor;

  _OvalCutoutPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.38);
    final ovalWidth = size.width * 0.65;
    final ovalHeight = ovalWidth * 1.35;
    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // Dark overlay with oval hole
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // Oval border
    canvas.drawOval(
      ovalRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = borderColor.withValues(alpha: 0.7)
        ..strokeWidth = 3.0,
    );
  }

  @override
  bool shouldRepaint(_OvalCutoutPainter oldDelegate) =>
      borderColor != oldDelegate.borderColor;
}
