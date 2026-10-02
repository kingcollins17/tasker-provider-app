import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/ui/designs/designs.dart';
import '../profile_routes.dart';

class ViewPayoutAccountScreen extends ConsumerWidget {
  const ViewPayoutAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Payout Information', style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
        centerTitle: true,
        actions: [
         
          SizedBox(width: 8.w),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          final account = user.paymentAccount;
          if (account == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64.r,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No Payout Account Found',
                      style: AppTextStyles.h3,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add your bank details to receive task earnings directly.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .pushNamed(ProfileRoutes.updatePayoutAccountRoute);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Payout Account'),
                    ),
                  ],
                ),
              ),
            );
          }

          final bankName =
              account.accountMetadata?['bank_name'] ?? 'Unknown Bank';
          final accountNumber =
              account.accountMetadata?['account_number'] ?? '••••••••••';
          final accountName = account.accountName ?? 'Unknown Name';

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Text(
                  'Earnings Account',
                  style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Your payouts are processed and sent to this bank account upon task completion.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color:
                        isDark ? AppColors.textMuted : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Compact Gradient Bank Card UI
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    borderRadius: AppDecorations.radiusLg,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF007D5A),
                        Color(0xFF0F766E),
                        Color(0xFF004D38),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007D5A).withValues(alpha: 0.25),
                        blurRadius: 16.r,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: AppDecorations.radiusSm,
                                ),
                                child: Icon(
                                  Icons.account_balance_rounded,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                bankName,
                                style: AppTextStyles.subtitle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 12.r,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'VERIFIED',
                                  style: AppTextStyles.labelUppercase.copyWith(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Account Number Text
                      Text(
                        _formatAccountNumber(accountNumber),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Account Holder Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ACCOUNT HOLDER',
                                style: AppTextStyles.labelUppercase.copyWith(
                                  color: Colors.white70,
                                  fontSize: 9.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                accountName.toUpperCase(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              context.pushNamed(
                                ProfileRoutes.updatePayoutAccountRoute,
                              );
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.r,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 13.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Edit',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(isDark),
        error: (err, stack) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Text(
              'Failed to load payout account.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surface : Colors.grey.shade300,
        highlightColor: isDark ? AppColors.border : Colors.grey.shade100,
        child: Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDecorations.radiusLg,
          ),
        ),
      ),
    );
  }

  String _formatAccountNumber(String rawNumber) {
    if (rawNumber.length == 10) {
      return '${rawNumber.substring(0, 3)}  ${rawNumber.substring(3, 7)}  ${rawNumber.substring(7)}';
    }
    return rawNumber;
  }
}

