import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/ui/designs/designs.dart';

/// A dashboard-style stats grid showing key platform metrics.
///
/// Displays the remaining stats (Total Tasks, Avg Rating, Credibility)
/// in a grid layout.
class StatsDashboard extends StatelessWidget {
  const StatsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = [
      _StatItem(
        icon: Icons.task_alt_rounded,
        color: AppColors.primaryLight,
        value: '148',
        label: 'Total Tasks',
      ),
      _StatItem(
        icon: Icons.star_rounded,
        color: AppColors.warning,
        value: '4.9',
        label: 'Avg Rating',
      ),
      _StatItem(
        icon: Icons.shield_outlined,
        color: AppColors.primary,
        value: '98%',
        label: 'Credibility',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.85,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _StatCard(stat: stat, isDark: isDark);
      },
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat, required this.isDark});

  final _StatItem stat;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.grey.shade50,
        borderRadius: AppDecorations.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: stat.color, size: 20.r),
          ),
          SizedBox(height: 12.h),

          // Value
          Text(
            stat.value,
            style: AppTextStyles.h3.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : AppColors.background,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),

          // Label
          Text(
            stat.label,
            style: AppTextStyles.label.copyWith(
              fontSize: 11.sp,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
