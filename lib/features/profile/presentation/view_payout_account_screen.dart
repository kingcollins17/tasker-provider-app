import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/primary_button.dart';
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
        title: Text('Payout Information', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: userAsync.when(
        data: (user) {
          final account = user.paymentAccount;
          if (account == null) {
            return Center(
              child: Text(
                'No payout account found.',
                style: AppTextStyles.bodyLarge,
              ),
            );
          }

          final bankName =
              account.accountMetadata?['bank_name'] ?? 'Unknown Bank';
          final accountNumber =
              account.accountMetadata?['account_number'] ?? '••••••••••';
          final accountName = account.accountName ?? 'Unknown Name';

          return Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Earnings Account', style: AppTextStyles.h3),
                SizedBox(height: 8.h),
                Text(
                  'This is where we will send your earnings when you complete a task.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 32.h),

                // Credit Card UI
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
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
                          Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 32.r,
                          ),
                          SizedBox(width: 16.w),
                          Flexible(
                            child: Text(
                              bankName,
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                                fontSize: 20.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 48.h),
                      Text(
                        accountNumber,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'ACCOUNT NAME',
                        style: AppTextStyles.labelUppercase.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        accountName.toUpperCase(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Failed to load payout account.',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: PrimaryButton(
            text: 'Edit Payout Account',
            onPressed: () {
              context.pushNamed(ProfileRoutes.updatePayoutAccountRoute);
            },
          ),
        ),
      ),
    );
  }
}
