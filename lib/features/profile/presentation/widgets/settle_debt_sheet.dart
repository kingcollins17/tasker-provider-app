import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/payments_provider.dart';
import '../../../../core/router/navigator_keys.dart';
import '../../../../core/ui/designs/designs.dart';
import '../../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../../core/utils/extensions/num_ext.dart';

/// A compact bottom sheet for users to view and settle their outstanding commission debt.
class SettleDebtSheet extends ConsumerWidget {
  final Debt debt;

  const SettleDebtSheet({
    super.key,
    required this.debt,
  });

  /// Shows the [SettleDebtSheet] modal bottom sheet using root navigator.
  static Future<void> show([BuildContext? context, Debt? debt]) async {
    final ctx = context ?? NavigatorKeys.rootNavigatorKey.currentContext;
    if (ctx == null || debt == null) return;

    await showModalBottomSheet<void>(
      context: ctx,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettleDebtSheet(debt: debt),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final totalDebt = debt.totalDebtOwed ?? 0.0;
    final maxThreshold = ref.watch(maxDebtThresholdProvider);
    final isOverThreshold = totalDebt >= maxThreshold;
    final progress = (totalDebt / maxThreshold).clamp(0.0, 1.0);
    final formattedThreshold = maxThreshold.toNaira(0);

    // Dynamic UI visual distinctions for debt health status (without explicit text labels)
    final Color statusColor = totalDebt < (maxThreshold * 0.5)
        ? AppColors.success
        : totalDebt <= (maxThreshold * 0.9)
            ? AppColors.warning
            : AppColors.error;

    final IconData statusIcon = totalDebt < (maxThreshold * 0.5)
        ? Icons.shield_outlined
        : isOverThreshold
            ? Icons.warning_amber_rounded
            : Icons.info_outline_rounded;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                children: [
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: statusColor,
                      size: 18.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Settle Debt',
                      style: AppTextStyles.h3.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20.r,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Debt Health & Balance Card
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                      : const Color(0xFFF8FAFC),
                  borderRadius: AppDecorations.radiusMd,
                  border: Border.all(
                    color: isOverThreshold
                        ? AppColors.error.withValues(alpha: 0.5)
                        : isDark
                            ? colorScheme.outlineVariant.withValues(alpha: 0.2)
                            : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Total Balance Owed',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          totalDebt.toNaira(2),
                          style: AppTextStyles.h2.copyWith(
                            color: isOverThreshold
                                ? AppColors.error
                                : colorScheme.onSurface,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Visual Progress Bar towards threshold limit
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6.h,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    SizedBox(height: 6.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₦0',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10.5.sp,
                          ),
                        ),
                        Text(
                          'Threshold: $formattedThreshold',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isOverThreshold ? AppColors.error : AppColors.textMuted,
                            fontWeight: isOverThreshold ? FontWeight.bold : FontWeight.w500,
                            fontSize: 10.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // Threshold Rule Notice
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: AppDecorations.radiusSm,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 16.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        isOverThreshold
                            ? 'Your debt has reached the $formattedThreshold threshold. Settle immediately to restore offer dispatch and avoid account deactivation.'
                            : 'Reaching the $formattedThreshold debt threshold will pause incoming offers until settled.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondary : colorScheme.onSurface,
                          fontSize: 11.5.sp,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Action Button
              SizedBox(
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    context.showInfo(
                      'Debt settlement request submitted. Invalidating debt summary...',
                    );
                    ref.invalidate(debtSummaryProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverThreshold ? AppColors.error : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDecorations.radiusLg,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Settle Debt (${totalDebt.toNaira(2)})',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


