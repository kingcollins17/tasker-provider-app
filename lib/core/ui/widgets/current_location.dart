import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/providers/providers.dart';
import 'package:tasker_app/core/ui/designs/designs.dart';

class CurrentLocation extends ConsumerWidget {
  const CurrentLocation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final addressAsync = ref.watch(userAddressProvider);

    return addressAsync.when(
      loading: () => Shimmer.fromColors(
        baseColor: isDark ? AppColors.surface : Colors.grey[200]!,
        highlightColor: isDark ? AppColors.border : Colors.grey[100]!,
        child: Container(
          width: 100.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
      error: (err, _) => GestureDetector(
        onTap: () => ref.invalidate(userAddressProvider),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              color: AppColors.error,
              size: 14.r,
            ),
            SizedBox(width: 4.w),
            Text(
              'Retry location',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
      data: (address) {
        final city = address.locality;
        final state = address.administrativeArea;
        final hasLoc = city != null || state != null;
        final text = hasLoc
            ? '${city ?? ''}${city != null && state != null ? ', ' : ''}${state ?? ''}'
            : 'Location unavailable';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              color: hasLoc ? AppColors.primaryLight : AppColors.textMuted,
              size: 14.r,
            ),
            SizedBox(width: 4.w),
            Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: hasLoc ? null : AppColors.textMuted,
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
