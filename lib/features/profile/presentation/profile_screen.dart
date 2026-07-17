import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';

import '../../../core/ui/designs/designs.dart';
import '../../../core/providers/providers.dart';
import '../../../features/kyc/kyc_routes.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import '../../../core/ui/widgets/confirmation_dialog.dart';
import '../../../core/ui/pages/verify_otp_page.dart';
import '../../../core/models/api/users/users.dart';
import '../profile_routes.dart';
import 'widgets/phone_number_sheet.dart';
import 'widgets/profile_header.dart';
import 'widgets/stats_dashboard.dart';
import 'widgets/earnings_card.dart';
import 'widgets/option_tile.dart';
import 'widgets/kyc_badge.dart';
import 'dart:async';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userAsync = ref.watch(userProvider);
    final addressAsync = ref.watch(userAddressProvider);
    final kycStatusAsync = ref.watch(kycStatusProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Top Bar ──────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_buildLocation(addressAsync, isDark, ref)],
                ),
                SizedBox(height: 16.h),

                // ── Hero Earnings Card ──────────────────────────
                const EarningsCard(),
                SizedBox(height: 24.h),

                // ── Profile Header ──────────────────────────────
                _buildProfileSection(userAsync, isDark),
                SizedBox(height: 20.h),

                // ── Stats Dashboard ─────────────────────────────
                _SectionLabel(label: 'DASHBOARD'),
                AppSpacing.hSm,
                const StatsDashboard(),
                SizedBox(height: 20.h),

                // ── Account & Preferences ───────────────────────
                _SectionLabel(label: 'ACCOUNT & PREFERENCES'),
                AppSpacing.hSm,
                _buildPreferences(
                  context,
                  ref,
                  isDark,
                  kycStatusAsync,
                  userAsync.value,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Profile Header Section ──────────────────────────────────────

  Widget _buildProfileSection(AsyncValue<User> userAsync, bool isDark) {
    return userAsync.maybeWhen(
      loading: () => ProfileHeader.shimmer(isDark),
      data: (user) {
        final firstName = user.providerProfile?.firstName ?? 'Tasker';
        final lastName = user.providerProfile?.lastName ?? 'User';
        return ProfileHeader(
          fullName: '$firstName $lastName',
          email: user.email ?? '',
          isActive: user.isActive ?? false,
          selfieUrl: user.providerProfile?.selfieUrl,
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildLocation(
    AsyncValue<Address> addressAsync,
    bool isDark,
    WidgetRef ref,
  ) {
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

  // ── Preferences List ────────────────────────────────────────────

  Widget _buildPreferences(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AsyncValue<KycStatus> kycStatusAsync,
    User? user,
  ) {
    return Column(
      children: [
        // Phone Verification — only if not yet verified
        if (user != null &&
            (!(user.phoneVerified ?? false) ||
                user.phoneNumber == null ||
                user.phoneNumber!.isEmpty)) ...[
          OptionTile(
            icon: Icons.phone_android_rounded,
            iconColor: AppColors.warning,
            title: 'Verify Phone Number',
            subtitle: 'Required for account security',
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Action Needed',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ),
            onTap: () => _handlePhoneVerification(context, ref, user),
          ),
          AppSpacing.hSm,
        ],

        // Email Verification — only if not yet verified
        if (user != null &&
            (!(user.emailVerified ?? false) &&
                user.email != null &&
                user.email!.isNotEmpty)) ...[
          OptionTile(
            icon: Icons.email_outlined,
            iconColor: AppColors.warning,
            title: 'Verify Email Address',
            subtitle: 'Required for account security',
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'Action Needed',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ),
            onTap: () => _handleEmailVerification(context, ref, user),
          ),
          AppSpacing.hSm,
        ],

        // Dark Mode Toggle
        Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeProvider);
            final isDarkMode = themeMode == ThemeMode.dark;
            return OptionTile(
              icon: isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              iconColor: AppColors.primaryLight,
              title: 'Dark Mode',
              subtitle: isDarkMode ? 'Currently on' : 'Currently off',
              trailing: Switch.adaptive(
                value: isDarkMode,
                activeThumbColor: AppColors.primary,
                onChanged: ref.read(themeProvider.notifier).toggleTheme,
              ),
            );
          },
        ),
        AppSpacing.hSm,

        // KYC Verification
        kycStatusAsync.maybeWhen(
          loading: () => Column(
            children: [
              OptionTile(
                icon: Icons.verified_user_outlined,
                iconColor: AppColors.primary,
                title: 'KYC Verification',
                subtitle: 'Loading status...',
                trailing: SizedBox(
                  width: 14.r,
                  height: 14.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.r,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppSpacing.hSm,
            ],
          ),
          data: (status) => Column(
            children: [
              OptionTile(
                icon: Icons.verified_user_outlined,
                iconColor: status == KycStatus.approved
                    ? AppColors.success
                    : AppColors.warning,
                title: 'KYC Verification',
                subtitle: status == KycStatus.approved
                    ? 'Identity verified'
                    : 'Complete your identity verification',
                trailing: KycBadge(status: status),
                onTap: () => context.pushNamed(KycRoutes.kycOnboardingRoute),
              ),
              AppSpacing.hSm,
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        ),

        // Update Profile
        OptionTile(
          icon: Icons.person_outline_rounded,
          iconColor: AppColors.primaryLight,
          title: 'Update Profile',
          subtitle: 'Edit your personal information',
          onTap: () => _handleUpdateProfile(context, ref, user),
        ),
        AppSpacing.hSm,

        // Notification Preferences
        OptionTile(
          icon: Icons.notifications_active_outlined,
          iconColor: AppColors.primary,
          title: 'Notification Preferences',
          subtitle: 'Manage SMS, Email and Push',
          onTap: () =>
              context.pushNamed(ProfileRoutes.notificationPreferencesRoute),
        ),
        AppSpacing.hSm,

        // Payouts
        OptionTile(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.success,
          title: 'Payouts',
          subtitle: 'View your earnings history',
          onTap: () =>
              context.showToast('Payouts history feature coming soon!'),
        ),
        AppSpacing.hSm,

        // Update Payout Information
        OptionTile(
          icon: Icons.credit_card_outlined,
          iconColor: AppColors.primary,
          title: 'Update Payout Information',
          subtitle: 'Manage bank & payment details',
          onTap: () => context.showToast(
            'Update Payout Information feature coming soon!',
          ),
        ),
        AppSpacing.hSm,

        // Customer Support
        OptionTile(
          icon: Icons.support_agent_rounded,
          iconColor: AppColors.primaryLight,
          title: 'Customer Support',
          subtitle: 'Get help with your account',
          onTap: () =>
              context.showToast('Customer Support feature coming soon!'),
        ),
        SizedBox(height: 16.h),

        // Logout — separated with extra space for visual distinction
        OptionTile(
          icon: Icons.logout_rounded,
          iconColor: AppColors.error,
          title: 'Log Out',
          titleColor: AppColors.error,
          showChevron: false,
          onTap: () => _showLogoutDialog(context, ref),
        ),
      ],
    );
  }

  // ── Actions ─────────────────────────────────────────────────────

  Future<void> _handleUpdateProfile(
    BuildContext context,
    WidgetRef ref,
    User? user,
  ) async {
    final result = await context.pushNamed<Map<String, dynamic>?>(
      ProfileRoutes.updateProfileRoute,
      queryParameters: {
        'firstName': user?.providerProfile?.firstName,
        'lastName': user?.providerProfile?.lastName,
        'phonenumber': user?.phoneNumber,
        'gender': user?.providerProfile?.gender,
      },
    );

    if (result != null && result['success'] == true && context.mounted) {
      context.showInfo('Profile updated successfully');

      final newPhone = result['newPhone'] as String?;
      if (newPhone != null && newPhone.isNotEmpty) {
        context.showLoading();
        ref
            .read(authProvider.notifier)
            .requestPhoneOtp(
              newPhone,
              onSuccess: () async {
                if (!context.mounted) return;
                context.hideLoading();

                final otpResult = await VerifyOTPPage.verify(
                  NavigatorKeys.rootNavigatorKey.currentContext!,
                  target: newPhone,
                  channel: 'sms',
                  verifier: (otp, target) {
                    final completer = Completer<bool>();
                    ref
                        .read(authProvider.notifier)
                        .verifyPhoneNumber(
                          target,
                          otp,
                          onSuccess: () => completer.complete(true),
                          onError: (err) {
                            if (context.mounted) context.showError(err);
                            completer.complete(false);
                          },
                        );
                    return completer.future;
                  },
                );

                if (otpResult != null &&
                    otpResult.isVerified &&
                    context.mounted) {
                  context.showInfo('Phone number verified successfully!');
                  ref.invalidate(userProvider);
                }
              },
              onError: (err) {
                if (!context.mounted) return;
                context.hideLoading();
                context.showError(err);
              },
            );
      }
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to log out of your account?',
      confirmText: 'Log Out',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );

    if (confirmed) {
      ref
          .read(authProvider.notifier)
          .logout(
            onSuccess: () {
              context.go('/login');
            },
          );
    }
  }

  Future<void> _handlePhoneVerification(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    String? phone = user.phoneNumber;

    if (phone == null || phone.isEmpty) {
      phone = await PhoneNumberSheet.collect(context);
      if (phone == null || phone.isEmpty) return;
    }

    if (!context.mounted) return;
    context.showLoading();

    ref
        .read(authProvider.notifier)
        .requestPhoneOtp(
          phone,
          onSuccess: () async {
            if (!context.mounted) return;
            context.hideLoading();

            final result = await VerifyOTPPage.verify(
              context,
              target: phone!,
              channel: 'phone',
              verifier: (otp, target) {
                final completer = Completer<bool>();
                ref
                    .read(authProvider.notifier)
                    .verifyPhoneNumber(
                      target,
                      otp,
                      onSuccess: () => completer.complete(true),
                      onError: (err) {
                        if (context.mounted) context.showError(err);
                        completer.complete(false);
                      },
                    );
                return completer.future;
              },
            );

            if (result != null && result.isVerified && context.mounted) {
              context.showInfo('Phone number verified successfully!');
              ref.invalidate(userProvider);
            }
          },
          onError: (err) {
            if (!context.mounted) return;
            context.hideLoading();
            context.showError(err);
          },
        );
  }

  Future<void> _handleEmailVerification(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    String? email = user.email;

    if (email == null || email.isEmpty) {
      return;
    }

    if (!context.mounted) return;
    context.showLoading();

    ref
        .read(authProvider.notifier)
        .requestEmailOtp(
          email,
          onSuccess: () async {
            if (!context.mounted) return;
            context.hideLoading();

            final result = await VerifyOTPPage.verify(
              context,
              target: email,
              channel: 'email',
              verifier: (otp, target) {
                final completer = Completer<bool>();
                ref
                    .read(authProvider.notifier)
                    .verifyEmail(
                      target,
                      otp,
                      onSuccess: () => completer.complete(true),
                      onError: (err) {
                        if (context.mounted) context.showError(err);
                        completer.complete(false);
                      },
                    );
                return completer.future;
              },
            );

            if (result != null && result.isVerified && context.mounted) {
              context.showInfo('Email address verified successfully!');
              ref.invalidate(userProvider);
            }
          },
          onError: (err) {
            if (!context.mounted) return;
            context.hideLoading();
            context.showError(err);
          },
        );
  }
}

// ── Section Label ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelUppercase.copyWith(
        color: AppColors.primaryLight,
        letterSpacing: 1.5,
      ),
    );
  }
}
