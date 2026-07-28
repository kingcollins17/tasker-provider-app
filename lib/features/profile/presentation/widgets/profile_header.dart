import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/ui/designs/designs.dart';

/// Compact horizontal profile header with avatar, name, and email.
///
/// Features a clean, borderless design inspired by modern settings screens.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.email,
    required this.isActive,
    this.selfieUrl,
  });

  final String fullName;
  final String email;
  final bool isActive;
  final String? selfieUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppDecorations.radiusMd,
      ),
      child: Row(
        children: [
          // Avatar with active badge
          _buildAvatar(isDark),
          SizedBox(width: 16.w),

          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row with active badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        fullName,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Active',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),

                // Email
                Text(
                  email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Stack(
      children: [
        Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: ClipOval(
            child: selfieUrl != null && selfieUrl!.isNotEmpty
                ? Image.network(
                    selfieUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _defaultAvatar(),
                  )
                : _defaultAvatar(),
          ),
        ),
        // Online indicator dot
        if (isActive)
          Positioned(
            bottom: 2,
            right: 2,
            child: Builder(
              builder: (context) {
                return Container(
                  width: 12.r,
                  height: 12.r,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2.r,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Icon(Icons.person_rounded, color: AppColors.primary, size: 30.r);
  }

  /// Shimmer placeholder shown while user data is loading.
  static Widget shimmer(bool isDark) {
    return Builder(
      builder: (context) {
        final baseColor = Theme.of(context).colorScheme.surface;
        final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppDecorations.radiusMd,
            ),
          ),
        );
      },
    );
  }
}
