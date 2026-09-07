import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/models.dart';
import '../../../../core/providers/payments_provider.dart';
import '../../../../core/ui/designs/designs.dart';
import '../../../../core/utils/extensions/num_ext.dart';
import 'earning_duration_sheet.dart';
import 'settle_debt_sheet.dart';

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
    final debtAsync = ref.watch(debtSummaryProvider);

    final String amountDisplay = selectedEarningsAsync.when(
      data: (earnings) {
        if (earnings.totalEarnings != null) {
          return earnings.totalEarnings!.toNaira(2);
        }
        return '₦__';
      },
      loading: () => '₦__',
      error: (e, st) => '₦__',
    );

    final double? percentageGrowth = selectedEarningsAsync.when(
      data: (earnings) => earnings.percentageGrowth,
      loading: () => null,
      error: (e, st) => null,
    );

    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final angle = _gradientController.value * 2 * math.pi;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16.r,
                offset: const Offset(0, 8),
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
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppDecorations.radiusSm,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ),
                      AppSpacing.wSm,
                      Text(
                        selectedDuration.label,
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16.r,
                      ),
                    ],
                  ),
                ),
              ),
              if (percentageGrowth != null) ...[
                Builder(
                  builder: (context) {
                    final isNegative = percentageGrowth < 0;
                    final badgeBgColor = isNegative
                        ? AppColors.error.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.15);
                    final badgeTextColor = isNegative
                        ? const Color(0xFFFF5252)
                        : Colors.white;

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: AppDecorations.radiusXl,
                        border: isNegative
                            ? Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isNegative
                                ? Icons.trending_down_rounded
                                : Icons.trending_up_rounded,
                            color: badgeTextColor,
                            size: 12.r,
                          ),
                          AppSpacing.wXs,
                          Text(
                            '${percentageGrowth >= 0 ? '+' : ''}${percentageGrowth % 1 == 0 ? percentageGrowth.toInt() : percentageGrowth.toStringAsFixed(1)}%',
                            style: AppTextStyles.label.copyWith(
                              color: badgeTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            amountDisplay,
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 24.sp,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  selectedDuration.cardSubtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11.sp,
                  ),
                ),
              ),
              _buildDebtBadge(context, debtAsync),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtBadge(BuildContext context, AsyncValue<Debt> debtAsync) {
    return debtAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (debt) {
        final totalDebtOwed = debt.totalDebtOwed ?? 0.0;
        if (totalDebtOwed <= 0) return const SizedBox.shrink();

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => SettleDebtSheet.show(context, debt),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: const Color(0xFFFF5252),
                    size: 12.r,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Debt: ${totalDebtOwed.toNaira(0)}',
                    style: AppTextStyles.label.copyWith(
                      color: const Color(0xFFFF5252),
                      fontWeight: FontWeight.bold,
                      fontSize: 10.5.sp,
                    ),
                  ),
                  if (totalDebtOwed > 100) ...[
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFFFF5252),
                      size: 12.r,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

