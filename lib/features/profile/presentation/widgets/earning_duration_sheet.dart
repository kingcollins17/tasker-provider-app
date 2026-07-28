import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/providers/payments_provider.dart';
import '../../../../core/router/navigator_keys.dart';
import '../../../../core/ui/designs/designs.dart';

/// A compact bottom sheet that presents duration options for filtering provider earnings stats.
class EarningDurationSheet extends ConsumerWidget {
  const EarningDurationSheet({super.key});

  /// Shows the [EarningDurationSheet] bottom sheet using the root navigator context.
  static Future<EarningsDuration?> show([BuildContext? context]) {
    final ctx = context ?? NavigatorKeys.rootNavigatorKey.currentContext;
    if (ctx == null) return Future.value(null);

    return showModalBottomSheet<EarningsDuration>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EarningDurationSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedDuration = ref.watch(earningsDurationProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Earnings Period',
                    style: AppTextStyles.subtitle.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 22.r,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20.r,
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Duration Options List
              ...EarningsDuration.values.map((duration) {
                final isSelected = duration == selectedDuration;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(earningsDurationProvider.notifier)
                            .setDuration(duration);
                        Navigator.of(context).pop(duration);
                      },
                      borderRadius: AppDecorations.radiusMd,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.25,
                                ),
                          borderRadius: AppDecorations.radiusMd,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : colorScheme.outlineVariant.withValues(
                                    alpha: 0.2,
                                  ),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              duration.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? AppColors.primary
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.4,
                                    ),
                              size: 20.r,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
