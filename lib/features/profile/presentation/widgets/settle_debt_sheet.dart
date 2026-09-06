import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/payments_provider.dart';
import '../../../../core/router/navigator_keys.dart';
import '../../../../core/ui/designs/designs.dart';
import '../../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../../core/utils/extensions/num_ext.dart';

/// A bottom sheet for users to view and settle their outstanding commission debt.
class SettleDebtSheet extends ConsumerWidget {
  final Debt debt;

  const SettleDebtSheet({
    super.key,
    required this.debt,
  });

  /// Shows the [SettleDebtSheet] modal bottom sheet.
  static Future<void> show([BuildContext? context, Debt? debt]) async {
    final ctx = context ?? NavigatorKeys.rootNavigatorKey.currentContext;
    if (ctx == null || debt == null) return;

    await showModalBottomSheet<void>(
      context: ctx,
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
    final pendingCount = debt.pendingDebtsCount ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.error,
                          size: 20.r,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Settle Commission Debt',
                        style: AppTextStyles.h3.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
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
              SizedBox(height: 20.h),

              // Summary Banner Card
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppDecorations.radiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16.r,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL DEBT OWED',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      totalDebt.toNaira(2),
                      style: AppTextStyles.h1.copyWith(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '$pendingCount pending debt transaction${pendingCount == 1 ? '' : 's'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Information Notice
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                      : AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: AppDecorations.radiusMd,
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.warning,
                      size: 20.r,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Outstanding commission debt is accumulated from cash jobs or platform service fees. Settling your balance keeps your account in active status.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Settle Debt Action Button
              SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.showInfo(
                      'Debt settlement request submitted. Invalidating debt summary...',
                    );
                    ref.invalidate(debtSummaryProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppDecorations.radiusLg,
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Settle Debt (${totalDebt.toNaira(2)})',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
