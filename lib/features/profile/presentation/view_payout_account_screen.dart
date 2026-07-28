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
        title: Text('Payout Information', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(ProfileRoutes.updatePayoutAccountRoute);
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedPencilEdit01,
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              size: 22.r,
            ),
            tooltip: 'Edit Payout Account',
          ),
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
                SizedBox(height: 20.h),

                // Premium Gradient Bank Card UI (Inspired by Monzo/Apple Card UI)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
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
                        color: const Color(0xFF007D5A).withValues(alpha: 0.35),
                        blurRadius: 20.r,
                        offset: const Offset(0, 10),
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
                                  size: 22.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
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
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: AppTextStyles.labelUppercase.copyWith(
                                color: Colors.white,
                                fontSize: 10.sp,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 36.h),

                      // Account Number Text
                      Text(
                        _formatAccountNumber(accountNumber),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Account Holder Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ACCOUNT HOLDER',
                                style: AppTextStyles.labelUppercase.copyWith(
                                  color: Colors.white70,
                                  fontSize: 9.sp,
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
                          Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 22.r,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Spacious & Structured Card Details Box (Inspiration Detail Container)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : Colors.white,
                    borderRadius: AppDecorations.radiusLg,
                    border: Border.all(
                      color: isDark
                          ? AppColors.border
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10.r,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Details',
                        style: AppTextStyles.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                          color: isDark
                              ? AppColors.textPrimary
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _DetailRow(
                        label: 'Bank Name',
                        value: bankName,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _DetailRow(
                        label: 'Account Name',
                        value: accountName,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _DetailRow(
                        label: 'Account Number',
                        value: accountNumber,
                        isDark: isDark,
                      ),
                      _buildDivider(isDark),
                      _DetailRow(
                        label: 'Payout Status',
                        value: 'Verified',
                        isBadge: true,
                        isDark: isDark,
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

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(
        height: 1.h,
        thickness: 1.h,
        color: isDark ? AppColors.border : const Color(0xFFF1F5F9),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surface : Colors.grey.shade300,
        highlightColor: isDark ? AppColors.border : Colors.grey.shade100,
        child: Column(
          children: [
            Container(
              height: 180.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.radiusLg,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.radiusLg,
              ),
            ),
          ],
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBadge;
  final bool isDark;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBadge = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textMuted : AppColors.textSecondary,
            fontSize: 13.sp,
          ),
        ),
        if (isBadge)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 14.r,
                ),
                SizedBox(width: 4.w),
                Text(
                  value,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
      ],
    );
  }
}
