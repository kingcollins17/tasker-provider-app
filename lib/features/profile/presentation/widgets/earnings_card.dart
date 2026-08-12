import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/providers/payments_provider.dart';
import '../../../../core/ui/designs/designs.dart';
import '../../../../core/utils/extensions/num_ext.dart';
import 'earning_duration_sheet.dart';

/// EARNINGS CARD (Animated gradient + glassmorphism)
class EarningsCard extends ConsumerStatefulWidget {
  const EarningsCard({super.key});

  @override
  ConsumerState<EarningsCard> createState() => _EarningsCardState();
}

class _EarningsCardState extends ConsumerState<EarningsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDuration = ref.watch(earningsDurationProvider);
    final selectedEarningsAsync = ref.watch(selectedEarningsProvider);

    final String amountDisplay = selectedEarningsAsync.when(
      data: (earnings) {
        if (earnings.totalEarnings != null) {
          return earnings.totalEarnings!.toNaira(2);
        }
        return 0.toNaira(2);
      },
      loading: () => 0.toNaira(2),
      error: (e, st) => 0.toNaira(2),
    );

    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final angle = _gradientController.value * 2 * math.pi;
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: AppDecorations.radiusLg,
            gradient: LinearGradient(
              colors: const [
                AppColors.primary,
                AppColors.primaryDark,
                AppColors.secondary,
                AppColors.primary,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
              begin: Alignment(math.cos(angle), math.sin(angle)),
              end: Alignment(-math.cos(angle), -math.sin(angle)),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24.r,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => EarningDurationSheet.show(),
                borderRadius: AppDecorations.radiusSm,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppDecorations.radiusSm,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 20.r,
                        ),
                      ),
                      AppSpacing.wSm,
                      Text(
                        selectedDuration.label,
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppDecorations.radiusXl,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 14.r,
                    ),
                    AppSpacing.wXs,
                    Text(
                      "+12%",
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            amountDisplay,
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 32.sp,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            selectedDuration.cardSubtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
