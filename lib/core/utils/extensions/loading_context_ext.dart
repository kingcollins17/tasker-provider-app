import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';

import '../../../core/ui/designs/designs.dart';

/// Private reference to the active loading overlay entry.
OverlayEntry? _loadingEntry;

/// Extension on [BuildContext] to show and hide loading overlay.
extension LoadingContextExt on BuildContext {
  /// Shows a clean loading overlay featuring a flutter_spinkit spinner.
  void showLoading([VoidCallback? onShown, String? message]) {
    if (_loadingEntry != null) {
      onShown?.call();
      return;
    }

    _loadingEntry = OverlayEntry(
      builder: (context) => const _LoadingOverlay(),
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

/// A simple loading overlay with a modal barrier backdrop and a flutter_spinkit loading indicator.
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Dimmed backdrop without blur
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
        // Centered simple loading spinner with no container background
        Center(
          child: Material(
            color: Colors.transparent,
            child: SpinKitThreeBounce(
              color: AppColors.primary,
              size: 36.r,
            ),
          ),
        ),
      ],
    );
  }
}



