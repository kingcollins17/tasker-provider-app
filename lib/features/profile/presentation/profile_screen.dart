import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

import 'package:tasker_app/core/router/navigator_keys.dart';

import '../../../core/ui/designs/designs.dart';
import '../../../core/providers/providers.dart';
import '../../../features/kyc/kyc_routes.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import '../../../core/ui/widgets/confirmation_dialog.dart';
import '../../../core/ui/widgets/debug_view_page.dart';
import '../../../core/ui/pages/verify_otp_page.dart';
import '../../../core/models/models.dart';
import '../profile_routes.dart';
import 'widgets/phone_number_sheet.dart';
import 'widgets/profile_header.dart';
import 'widgets/stats_dashboard.dart';
import 'widgets/earnings_card.dart';
import 'widgets/option_tile.dart';
import 'widgets/kyc_badge.dart';
import '../../../core/ui/widgets/current_location.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userAsync = ref.watch(userProvider);
     ref.watch(currentDispatchListenerProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(userProvider);
            ref.invalidate(userServicesProvider);
            ref.invalidate(kycStatusProvider);
            ref.invalidate(selectedEarningsProvider);
            try {
              await Future.wait([
                ref.read(userProvider.future),
                ref.read(selectedEarningsProvider.future),
              ]);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top Bar ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Profile',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const CurrentLocation(),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // ── Hero Earnings Card ──────────────────────────
                  const EarningsCard(),
                  SizedBox(height: 24.h),

                  // ── Profile Header ──────────────────────────────
                  _buildProfileSection(userAsync, isDark),
                  SizedBox(height: 20.h),

                  // ── My Services ──────────────────────────────────
                  const _ServicesSection(),
                  SizedBox(height: 20.h),

                  // ── Stats Dashboard ─────────────────────────────
                  const _SectionLabel(label: 'DASHBOARD'),
                  AppSpacing.hSm,
                  const StatsDashboard(),
                  SizedBox(height: 20.h),

                  // ── Account & Preferences ───────────────────────
                  const _SectionLabel(label: 'ACCOUNT & PREFERENCES'),
                  AppSpacing.hSm,
                  const _PreferencesSection(),
                  SizedBox(height: 24.h),
                ],
              ),
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
          dutyStatus: user.providerProfile?.dutyStatus,
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ── My Services Section ─────────────────────────────────────────────

class _ServicesSection extends ConsumerWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userServicesAsync = ref.watch(userServicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header row: label + count badge + edit icon ──
        Row(
          children: [
            const _SectionLabel(label: 'MY SERVICES'),
            SizedBox(width: 8.w),
            // Service count badge
            userServicesAsync.maybeWhen(
              data: (services) => services.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${services.length}',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            const Spacer(),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.pushNamed(ProfileRoutes.editServicesRoute),
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 14.r,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Edit',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        // ── Service chips / states ──
        userServicesAsync.when(
          loading: () {
            final baseColor = isDark
                ? theme.colorScheme.surface
                : Colors.grey[200]!;
            final highlightColor = isDark
                ? AppColors.border
                : Colors.grey[100]!;

            return Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: SizedBox(
                height: 30.h,
                child: Row(
                  children: [
                    Container(
                      width: 90.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 110.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 80.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (err, _) => GestureDetector(
            onTap: () => ref.invalidate(userServicesProvider),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 14.r,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Failed to load',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '· Tap to retry',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          data: (services) {
            if (services.isEmpty) {
              return GestureDetector(
                onTap: () => context.pushNamed(ProfileRoutes.editServicesRoute),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.colorScheme.surface
                        : AppColors.warning.withValues(alpha: 0.06),
                    borderRadius: AppDecorations.radiusMd,
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.warning,
                        size: 16.r,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add services to start receiving tasks',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ── Horizontal scrollable pill chips ──
            return SizedBox(
              height: 30.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: services.length,
                separatorBuilder: (_, _) => SizedBox(width: 6.w),
                itemBuilder: (context, index) {
                  final s = services[index];
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Text(
                        s.name ?? 'Service',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Preferences Section ─────────────────────────────────────────────

class _PreferencesSection extends ConsumerWidget {
  const _PreferencesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycStatusAsync = ref.watch(kycStatusProvider);
    final userServicesAsync = ref.watch(userServicesProvider);
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    return Column(
      children: [
        // My Services Option Tile
        OptionTile(
          icon: Icons.miscellaneous_services_rounded,
          iconColor: AppColors.primary,
          title: 'My Services',
          subtitle: userServicesAsync.maybeWhen(
            data: (services) => services.isEmpty
                ? 'No services configured'
                : '${services.length} active service${services.length == 1 ? '' : 's'}',
            orElse: () => 'Manage the services you offer',
          ),
          onTap: () => context.pushNamed(ProfileRoutes.editServicesRoute),
        ),
        AppSpacing.hSm,

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
                activeTrackColor: AppColors.primary,
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

        // Payouts
        OptionTile(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.success,
          title: 'Payouts',
          subtitle: 'View your earnings history',
          onTap: () => context.pushNamed(ProfileRoutes.payoutsRoute),
        ),
        AppSpacing.hSm,

        // Update Payout Information
        OptionTile(
          icon: Icons.credit_card_outlined,
          iconColor: AppColors.primary,
          title: 'Payout Information',
          subtitle: 'Manage bank & payment details',
          onTap: () {
            if (user != null && user.paymentAccount != null) {
              context.pushNamed(ProfileRoutes.viewPayoutAccountRoute);
            } else {
              context.pushNamed(ProfileRoutes.updatePayoutAccountRoute);
            }
          },
        ),
        AppSpacing.hSm,

        /* 
        // Working Availability
        OptionTile(
          icon: Icons.access_time_rounded,
          iconColor: AppColors.secondary,
          title: 'Working Availability',
          subtitle: 'Set weekly working days & hours',
          onTap: () => context.pushNamed(ProfileRoutes.updateAvailabilityRoute),
        ),
        AppSpacing.hSm,
        */

        // Customer Support
        OptionTile(
          icon: Icons.support_agent_rounded,
          iconColor: AppColors.primaryLight,
          title: 'Customer Support',
          subtitle: 'Get help with your account',
          onTap: () =>
              context.showToast('Customer Support feature coming soon!'),
        ),
        AppSpacing.hSm,

        // Debug Logs Console (Debug Mode Only)
        // if (kDebugMode) ...[
          OptionTile(
            icon: Icons.bug_report_outlined,
            iconColor: AppColors.warning,
            title: 'Debug Console',
            subtitle: 'View console logs & network output',
            onTap: () => DebugViewPage.show(),
          ),
          AppSpacing.hSm,
        // ],
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
