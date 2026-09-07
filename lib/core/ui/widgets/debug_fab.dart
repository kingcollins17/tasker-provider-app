import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../designs/designs.dart';
import 'debug_view_page.dart';

/// A small and subtle floating action button for opening the [DebugViewPage].
class DebugFab extends StatelessWidget {
  const DebugFab({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => DebugViewPage.show(context),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? AppColors.border.withValues(alpha: 0.6)
                  : Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.bug_report_rounded,
              size: 18.r,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
