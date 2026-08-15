import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';

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

    _loadingEntry = OverlayEntry(builder: (context) => const _LoadingOverlay());

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

/// A premium loading overlay with animated concentric arcs and a pulsing glow.
class _LoadingOverlay extends StatefulWidget {
  const _LoadingOverlay();

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
      child: Stack(
        children: [
          // Dimmed backdrop
          ModalBarrier(
            dismissible: false,
            color: Colors.black54.withValues(alpha: 0.2),
          ),
          // Spinner
          const Center(
            child: SpinKitThreeBounce(color: AppColors.primary, size: 32),
          ),
        ],
      ),
    );
  }
}
