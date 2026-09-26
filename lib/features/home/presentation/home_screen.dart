import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:tasker_app/core/models/models.dart';
import 'package:tasker_app/core/providers/providers.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';

import '../../../core/models/api/users/users.dart';
import '../../../core/ui/designs/colors.dart';
import '../../../core/ui/designs/text_styles.dart';
import '../../../core/ui/designs/decorations.dart';
import '../../../core/ui/designs/spacing.dart';
import '../../../core/ui/widgets/debug_fab.dart';
import '../../../core/ui/widgets/floating_online_toggle.dart';
import '../../notifications/presentation/widgets/notification_icon.dart';
import '../../profile/presentation/widgets/earnings_card.dart';
import '../../profile/profile_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import 'package:tasker_app/features/tasks/tasks_routes.dart';
import '../../../app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/onboard_services_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      userProvider,
      (previous, next) {
        if (next.hasError) {
          final es = next.error.toString().toLowerCase();
          if (es.contains('user not found') || es.contains('user data is null')) {
            ref.read(authProvider.notifier).logout(
              onSuccess: () {
                if (context.mounted) {
                  context.pushNamed(AppRoutes.loginRoute);
                }
              },
            );
          }
        }
      },
    );
    debugLog(ref.read(userProvider));
    ref.watch(syncUserLocationProvider);
    ref.watch(userAddressProvider);
    ref.watch(currentRegionProvider);

    ref.watch(deviceTrayNotificationProvider);
    ref.watch(offerPingListenerProvider);
    ref.watch(currentDispatchListenerProvider);
    ref.watch(pendingReviewPrompterProvider);

    final user = ref.watch(userProvider);
    ref.watch(syncUserLocationProvider);
    ref.watch(userAddressProvider);
    ref.watch(syncCloudMessagingTokenProvider);
    ref.watch(pendingProviderReviewsProvider);

    final firstName = user.value?.providerProfile?.firstName ?? '';
    final lastName = user.value?.providerProfile?.lastName ?? '';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: const DebugFab(),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(syncUserLocationProvider);
                ref.invalidate(userAddressProvider);
                ref.invalidate(currentRegionProvider);
                ref.invalidate(syncCloudMessagingTokenProvider);
                ref.invalidate(userProvider);
                ref.invalidate(isOnlineProvider);
                ref.invalidate(notificationsProvider);
                ref.invalidate(providerEarningsStatsProvider);
                ref.invalidate(selectedEarningsProvider);
                ref.invalidate(earningsDurationProvider);
                ref.invalidate(debtSummaryProvider);
                ref.invalidate(currentAssignmentProvider);
                ref.invalidate(kycStatusProvider);
                ref.invalidate(providerPayoutsProvider);
                ref.invalidate(currentDispatchProvider);
                ref.invalidate(interviewProvider);

                try {
                  await Future.wait([
                    ref.read(syncUserLocationProvider.future),
                    ref.read(userAddressProvider.future),
                    ref.read(currentRegionProvider.future),
                    ref.read(syncCloudMessagingTokenProvider.future),
                    ref.read(userProvider.future),
                    ref.read(isOnlineProvider.future),
                    ref.read(notificationsProvider.future),
                    ref.read(selectedEarningsProvider.future),
                    ref.read(debtSummaryProvider.future),
                    ref.read(currentAssignmentProvider.future),
                    ref.read(kycStatusProvider.future),
                    ref.read(providerPayoutsProvider(null).future),
                    ref.read(currentDispatchProvider.future),
                    ref.read(interviewProvider.future),
                  ]);
                } catch (_) {}
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // ─── APP BAR ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: SliverToBoxAdapter(
                      child: _HomeAppBar(fullname: '$firstName $lastName'),
                    ),
                  ),

                  SliverToBoxAdapter(child: AppSpacing.hLg),

                  // ─── EARNINGS CARD ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(child: EarningsCard()),
                  ),

                  SliverToBoxAdapter(child: AppSpacing.hLg),

                  // ─── ACCOUNT SETUP BANNER ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(
                      child: _AccountSetupSection(),
                    ),
                  ),

                  // ─── SERVICES ONBOARDING BANNER ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(
                      child: _OnboardServicesSection(),
                    ),
                  ),

                  // ─── ACCOUNT ISSUES ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(
                      child: _AccountIssuesSection(),
                    ),
                  ),

                  // ─── UPCOMING INTERVIEW ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(
                      child: _UpcomingInterviewSection(),
                    ),
                  ),

                  // ─── ACTIVE WORK ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(
                      child: _ActiveWorkSection(),
                    ),
                  ),

                  SliverToBoxAdapter(child: AppSpacing.hLg),

                  // ─── PAYOUTS OVERVIEW ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(
                      child: _PayoutsOverviewSection(),
                    ),
                  ),

                  // ─── PERFORMANCE SNAPSHOT ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(
                      child: _PerformanceSnapshotCard(),
                    ),
                  ),

                  SliverToBoxAdapter(child: AppSpacing.hLg),
                  // Bottom padding for the floating banner
                  SliverToBoxAdapter(child: SizedBox(height: 120.h)),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Consumer(
                  builder: (context, ref, child) {
                    return ref
                        .watch(isOnlineProvider)
                        .when(
                          data: (isOnline) => FloatingOnlineToggle(
                            isOnline: isOnline,
                            onToggle: () {
                              context.showLoading();
                              ref
                                  .read(userProvider.notifier)
                                  .updateOnlineStatus(
                                    isOnline: !isOnline,
                                    onSuccess: () {
                                      if (context.mounted) {
                                        context.hideLoading();
                                        context.showInfo(
                                          !isOnline
                                              ? 'You are now online'
                                              : 'You are now offline',
                                        );
                                      }
                                    },
                                    onError: (err) {
                                      if (context.mounted) {
                                        context.hideLoading();
                                        context.showError(err);
                                      }
                                    },
                                  );
                            },
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (e, st) => const SizedBox.shrink(),
                        );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _HomeAppBar extends ConsumerWidget {
  final String fullname;

  const _HomeAppBar({required this.fullname});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8.r,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    fullname.isNotEmpty ? fullname[0].toUpperCase() : '?',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Small green/grey dot for online status
              isOnlineAsync.when(
                data: (isOnline) {
                  return Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11.r,
                      height: 11.r,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.success
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2.r,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullname.isNotEmpty ? fullname : 'User',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Text(
                  _greeting,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _TopIconAction(
            icon: Icons.headset_mic_rounded,
            color: const Color(0xFFEC4899),
            onTap: () {},
          ),
          const NotificationIcon(),
        ],
      ),
    );
  }
}

class _TopIconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopIconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38.r,
        height: 38.r,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: color, size: 20.r),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER (with optional "See All")
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 14.sp)),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText!,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeaderShimmer extends StatelessWidget {
  final bool hasAction;
  final double? titleWidth;

  const _SectionHeaderShimmer({
    this.hasAction = false,
    this.titleWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: titleWidth ?? 100.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          if (hasAction)
            Container(
              width: 50.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPCOMING INTERVIEW SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingInterviewSection extends ConsumerWidget {
  const _UpcomingInterviewSection();

  Future<void> _launchMeeting(BuildContext context, String url) async {
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        context.showError('Could not open meeting link');
      }
    } catch (_) {
      if (context.mounted) {
        context.showError('Could not open meeting link');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interviewAsync = ref.watch(interviewProvider);

    return interviewAsync.when(
      data: (interview) {
        if (interview == null || interview.scheduledAt == null) {
          return const SizedBox.shrink();
        }

        final status = (interview.status ?? 'SCHEDULED').toUpperCase();
        if (status == 'PASSED' ||
            status == 'COMPLETED' ||
            status == 'CANCELLED' ||
            status == 'REJECTED') {
          return const SizedBox.shrink();
        }

        final formattedDate = DateFormat.yMMMd().add_jm().format(
          interview.scheduledAt!,
        );
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: "Upcoming Interview"),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppDecorations.radiusLg,
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.35 : 0.2,
                    ),
                    width: 1.2.r,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.15 : 0.06,
                      ),
                      blurRadius: 12.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42.r,
                          height: 42.r,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.video_camera_front_rounded,
                            color: AppColors.primary,
                            size: 22.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Verification Interview',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: isDark
                                            ? AppColors.textPrimary
                                            : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      status,
                                      style: AppTextStyles.label.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9.5.sp,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_available_rounded,
                                    color: AppColors.primaryLight,
                                    size: 14.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(
                                      formattedDate,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondary
                                            : const Color(0xFF334155),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11.5.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (interview.notes != null &&
                        interview.notes!.trim().isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      Text(
                        interview.notes!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11.5.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (interview.meetingLink != null &&
                        interview.meetingLink!.trim().isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _launchMeeting(
                            context,
                            interview.meetingLink!,
                          ),
                          icon: Icon(
                            Icons.video_call_rounded,
                            size: 18.r,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Join Interview Meeting',
                            style: AppTextStyles.buttonMedium.copyWith(
                              fontSize: 12.5.sp,
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: const _UpcomingInterviewSkeleton(),
      ),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _UpcomingInterviewSkeleton extends StatelessWidget {
  const _UpcomingInterviewSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeaderShimmer(titleWidth: 130),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppDecorations.radiusLg,
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 100.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE WORK SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveWorkSection extends ConsumerWidget {
  const _ActiveWorkSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentAsync = ref.watch(currentAssignmentProvider);

    return assignmentAsync.when(
      data: (assignment) {
        if (assignment == null) {
          return const _NoActiveWorkCard();
        }

        final title = assignment.task?.title ?? 'Active Task';

        String timeStr = 'In Progress';
        if (assignment.startedAt != null) {
          timeStr = 'Started ${DateFormat.jm().format(assignment.startedAt!)}';
        } else if (assignment.assignedAt != null) {
          timeStr =
              'Assigned ${DateFormat.yMMMd().format(assignment.assignedAt!)}';
        } else if (assignment.task?.scheduledStartAt != null) {
          timeStr = DateFormat.yMMMd().add_jm().format(
            assignment.task!.scheduledStartAt!,
          );
        }

        final rawPrice = assignment.acceptedPrice ??
            assignment.task?.providerPayout ??
            assignment.task?.customerTotalPrice;
        final priceStr = rawPrice?.toNaira(2);

        final statusStr = (assignment.status ?? 'assigned')
            .replaceAll('_', ' ')
            .toUpperCase();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: "Active Work", onAction: () {}),
            _ActiveWorkCard(
              title: title,
              time: timeStr,
              price: priceStr,
              status: statusStr,
              icon: Icons.work_history_rounded,
              color: AppColors.primary,
              onTap: () {
                if (assignment.taskId != null &&
                    assignment.taskId!.isNotEmpty) {
                  context.pushNamed(
                    TasksRoutes.taskDetailRoute,
                    pathParameters: {'taskId': assignment.taskId!},
                  );
                }
              },
            ),
          ],
        );
      },
      loading: () => const _ActiveWorkSkeleton(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _NoActiveWorkCard extends StatelessWidget {
  const _NoActiveWorkCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "Active Work", onAction: () {}),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppDecorations.radiusLg,
            border: Border.all(color: AppColors.border, width: 1.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_turned_in_outlined,
                  color: AppColors.primary,
                  size: 32.r,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "No Active Work",
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "You don't have any active assignment right now. Check available jobs to start earning!",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveWorkSkeleton extends StatelessWidget {
  const _ActiveWorkSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeaderShimmer(titleWidth: 90),
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppDecorations.radiusMd,
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 120.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 60.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            width: 100.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 50.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveWorkCard extends StatelessWidget {
  final String title;
  final String time;
  final String? price;
  final String? status;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActiveWorkCard({
    required this.title,
    required this.time,
    this.price,
    this.status,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDecorations.radiusMd,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(
            color: isDark
                ? AppColors.border
                : Colors.grey.withValues(alpha: 0.15),
            width: 1.r,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 20.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5.sp,
                            color: isDark
                                ? AppColors.textPrimary
                                : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status != null) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            status!,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5.sp,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: AppColors.textMuted,
                        size: 13.r,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          time,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11.5.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (price != null) ...[
                        SizedBox(width: 8.w),
                        Text(
                          price!,
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textMuted,
                        size: 12.r,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERFORMANCE SNAPSHOT
// ─────────────────────────────────────────────────────────────────────────────

class _PerformanceSnapshotCard extends ConsumerWidget {
  const _PerformanceSnapshotCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final earningsAsync = ref.watch(providerEarningsStatsProvider(null));

    if (userAsync.isLoading || earningsAsync.isLoading) {
      return const _PerformanceSnapshotShimmer();
    }

    final user = userAsync.value;
    final earnings = earningsAsync.value;

    final avgRatingNum = user?.stats?.averageRatings ?? user?.averageRatings;
    final avgRating = avgRatingNum != null
        ? avgRatingNum.toDouble().toStringAsFixed(1)
        : '0.0';

    final totalJobs = user?.stats?.totalTasksCompleted ??
        user?.providerProfile?.totalTasksCompleted ??
        0;

    final totalEarned = earnings?.totalEarnings ?? 0.0;
    final earnedStr = totalEarned >= 1000000
        ? '₦${(totalEarned / 1000000).toStringAsFixed(1)}M'
        : (totalEarned >= 1000
            ? '₦${(totalEarned / 1000).toStringAsFixed(totalEarned % 1000 == 0 ? 0 : 1)}k'
            : totalEarned.toNaira(0));

    final credibilityNum = user?.stats?.credibilityScore ?? user?.credibilityScore;
    final credibility = credibilityNum != null ? '${credibilityNum.toInt()}%' : '0%';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppDecorations.radiusLg,
        border: Border.all(
          color: isDark
              ? AppColors.border
              : Colors.grey.withValues(alpha: 0.15),
          width: 1.r,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance",
                style: AppTextStyles.h3.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _PerformanceStat(
                icon: Icons.star_rounded,
                value: avgRating,
                label: "Rating",
                color: const Color(0xFFF59E0B),
              ),
              _statDivider(isDark),
              _PerformanceStat(
                icon: Icons.work_rounded,
                value: "$totalJobs",
                label: "Jobs",
                color: const Color(0xFF3B82F6),
              ),
              _statDivider(isDark),
              _PerformanceStat(
                icon: Icons.payments_rounded,
                value: earnedStr,
                label: "Earned",
                color: const Color(0xFF10B981),
              ),
              _statDivider(isDark),
              _PerformanceStat(
                icon: Icons.check_circle_rounded,
                value: credibility,
                label: "Done",
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statDivider(bool isDark) {
    return Container(
      width: 1.r,
      height: 32.h,
      color: isDark ? AppColors.border : Colors.grey.withValues(alpha: 0.2),
    );
  }
}

class _PerformanceStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _PerformanceStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18.r),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 10.5.sp,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PerformanceSnapshotShimmer extends StatelessWidget {
  const _PerformanceSnapshotShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(color: AppColors.border, width: 1.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 90.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Container(
                  width: 65.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 36.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        width: 28.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// SERVICES ONBOARDING SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardServicesSection extends ConsumerWidget {
  const _OnboardServicesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasOnboardedAsync = ref.watch(onboardedServicesProvider);
    final hasOnboarded = hasOnboardedAsync.value ?? true;

    if (hasOnboarded) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed(AppRoutes.onboardCategoriesRoute),
          borderRadius: BorderRadius.circular(12.r),
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                width: 1.r,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_repair_service_rounded,
                    color: AppColors.primary,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Up Offered Services',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimary
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Select the services you offer to start receiving task requests.',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11.5.sp,
                          color: isDark
                              ? AppColors.textMuted
                              : const Color(0xFF64748B),
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.r,
                  color:
                      isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCOUNT SETUP BANNER SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _AccountSetupSection extends ConsumerWidget {
  const _AccountSetupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSelfieAsync = ref.watch(hasSelfieProvider);
    final kycDocAsync = ref.watch(getKycStatusProvider);
    final kycStatusAsync = ref.watch(kycStatusProvider);
    final guarantorAsync = ref.watch(guarantorProvider);
    final interviewAsync = ref.watch(interviewProvider);

    final hasError = hasSelfieAsync.hasError ||
        kycDocAsync.hasError ||
        kycStatusAsync.hasError ||
        guarantorAsync.hasError ||
        interviewAsync.hasError;

    if (hasError) {
      return const SizedBox.shrink();
    }

    final isLoading = hasSelfieAsync.isLoading ||
        kycDocAsync.isLoading ||
        kycStatusAsync.isLoading ||
        guarantorAsync.isLoading ||
        interviewAsync.isLoading;

    if (isLoading) {
      return _buildShimmer(context);
    }

    final hasSelfie = hasSelfieAsync.value ?? false;
    final kycDoc = kycDocAsync.value;
    final kycEnum = kycDoc?.verificationStatus ??
        (kycStatusAsync.value == KycStatus.approved
            ? VerificationStatus.passed
            : VerificationStatus.pending);
    final isDocApproved = kycEnum == VerificationStatus.passed;
    final guarantor = guarantorAsync.value;
    final isGuarantorPassed =
        guarantor?.verificationStatus == VerificationStatus.passed;
    final interview = interviewAsync.value;
    final rawInterviewStatus = interview?.status?.toUpperCase().trim();
    final isInterviewPassed =
        rawInterviewStatus == 'PASSED' || rawInterviewStatus == 'COMPLETED';

    int completedCount = 0;
    if (hasSelfie) completedCount++;
    if (isDocApproved) completedCount++;
    if (isGuarantorPassed) completedCount++;
    if (isInterviewPassed) completedCount++;

    if (completedCount >= 4) {
      return const SizedBox.shrink();
    }

    final double progress = completedCount / 4.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: GestureDetector(
        onTap: () => context.pushNamed(ProfileRoutes.onboardingStepsRoute),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      AppColors.primary.withValues(alpha: 0.25),
                      theme.colorScheme.surface,
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.primary.withValues(alpha: 0.03),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppDecorations.radiusLg,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25),
              width: 1.2.r,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.checklist_rtl_rounded,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Complete Account Setup',
                                style: AppTextStyles.h3.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '$completedCount/4 Done',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.5.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Complete 4 steps to become eligible for task offers.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textMuted,
                            fontSize: 11.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 6.h,
                          width: constraints.maxWidth,
                          color: isDark ? AppColors.border : Colors.grey[200]!,
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 6.h,
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 76.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDecorations.radiusLg,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCOUNT ISSUES SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _AccountIssuesSection extends ConsumerWidget {
  const _AccountIssuesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final kycStatusAsync = ref.watch(kycStatusProvider);

    if (userAsync.isLoading || kycStatusAsync.isLoading) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: const _AccountIssuesSkeleton(),
      );
    }

    final user = userAsync.value;
    final kycStatus = kycStatusAsync.value;

    final issues = <Widget>[];

    if (user != null) {
      if (!(user.phoneVerified ?? false) ||
          user.phoneNumber == null ||
          user.phoneNumber!.isEmpty) {
        issues.add(
          _AccountIssueCard(
            title: 'Verify Phone Number',
            description: 'Required to receive tasks and secure your account.',
            icon: Icons.phone_android_rounded,
            onTap: () {
              context.go('/profile');
            },
          ),
        );
      }

      if (!(user.emailVerified ?? false) &&
          user.email != null &&
          user.email!.isNotEmpty) {
        issues.add(
          _AccountIssueCard(
            title: 'Verify Email Address',
            description: 'Required for account recovery and notifications.',
            icon: Icons.email_outlined,
            onTap: () {
              context.go('/profile');
            },
          ),
        );
      }
    }

    if (user != null && kycStatus != null) {
      if (kycStatus == KycStatus.pending || kycStatus == KycStatus.rejected) {
        issues.add(
          _AccountIssueCard(
            title: kycStatus == KycStatus.rejected
                ? 'KYC Rejected'
                : 'Complete Identity Verification',
            description: kycStatus == KycStatus.rejected
                ? 'Your identity verification was rejected. Tap to retry.'
                : 'Verify your identity to start receiving tasks.',
            icon: Icons.verified_user_outlined,
            isError: kycStatus == KycStatus.rejected,
            onTap: () {
              context.go('/profile');
            },
          ),
        );
      }
    }

    if (issues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: "Account Issues"),
          ...issues,
        ],
      ),
    );
  }
}

class _AccountIssuesSkeleton extends StatelessWidget {
  const _AccountIssuesSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeaderShimmer(titleWidth: 100),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppDecorations.radiusMd,
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 110.w,
                        height: 11.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        width: 170.w,
                        height: 9.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountIssueCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isError;

  const _AccountIssueCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isError ? AppColors.error : AppColors.warning;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDecorations.radiusMd,
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(
            color: accentColor.withValues(alpha: isDark ? 0.25 : 0.18),
            width: 1.r,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isDark ? 0.14 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 15.r),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.textPrimary
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted.withValues(alpha: 0.5),
              size: 10.r,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAYOUTS OVERVIEW SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _PayoutsOverviewSection extends ConsumerWidget {
  const _PayoutsOverviewSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(providerPayoutsProvider(null));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return payoutsAsync.when(
      data: (payouts) {
        if (payouts.isEmpty) return const SizedBox.shrink();

        final hasMoreThanFour = payouts.length > 4;
        final displayList = payouts.take(4).toList();

                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: "Payouts",
                        actionText: hasMoreThanFour ? "See All" : null,
                        onAction: hasMoreThanFour
                            ? () => context.pushNamed(ProfileRoutes.payoutsRoute)
                            : null,
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: displayList.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: isDark
                              ? AppColors.border
                              : Colors.grey.withValues(alpha: 0.12),
                        ),
                        itemBuilder: (context, index) {
                          final payout = displayList[index];
                          final amount = payout.payoutAmount ?? 0.0;
                          final titleText = payout.task?.title ??
                              payout.description ??
                              'Payout #${payout.reference ?? payout.id?.substring(0, 6) ?? ''}';
                          final dateStr = payout.createdAt != null
                              ? DateFormat('dd MMM yyyy').format(payout.createdAt!)
                              : 'Recent';
                          final taskId = payout.taskId ?? payout.task?.id;
                          final statusLower = payout.status?.toLowerCase() ?? 'pending';

                          final (iconData, iconBgColor, iconColor, amountColor, statusText, statusColor) =
                              switch (statusLower) {
                            'completed' || 'paid' => (
                                Icons.arrow_downward_rounded,
                                AppColors.success.withValues(alpha: 0.15),
                                AppColors.success,
                                AppColors.success,
                                'PAID',
                                AppColors.success,
                              ),
                            'failed' => (
                                Icons.warning_amber_rounded,
                                AppColors.error.withValues(alpha: 0.15),
                                AppColors.error,
                                AppColors.error,
                                'FAILED',
                                AppColors.error,
                              ),
                            _ => (
                                Icons.access_time_rounded,
                                AppColors.warning.withValues(alpha: 0.15),
                                AppColors.warning,
                                AppColors.warning,
                                'PENDING',
                                AppColors.warning,
                              ),
                          };

                          return InkWell(
                            onTap: () {
                              if (taskId != null && taskId.isNotEmpty) {
                                context.pushNamed(
                                  TasksRoutes.taskDetailRoute,
                                  pathParameters: {'taskId': taskId},
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.h,
                                horizontal: 4.w,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: iconBgColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      iconData,
                                      color: iconColor,
                                      size: 18.r,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titleText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13.sp,
                                            color: isDark
                                                ? AppColors.textPrimary
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        Row(
                                          children: [
                                            Text(
                                              dateStr,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.textMuted,
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6.w,
                                                vertical: 1.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(
                                                  alpha: 0.12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                statusText,
                                                style: AppTextStyles.label
                                                    .copyWith(
                                                  color: statusColor,
                                                  fontSize: 9.5.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '+${amount.toNaira(2)}',
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                      color: amountColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
              loading: () => Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: const _PayoutsOverviewShimmer(),
              ),
              error: (error, stackTrace) => const SizedBox.shrink(),
            );
  }
}

class _PayoutsOverviewShimmer extends StatelessWidget {
  const _PayoutsOverviewShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeaderShimmer(hasAction: true, titleWidth: 70),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: 3,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.border
                  : Colors.grey.withValues(alpha: 0.12),
            ),
            itemBuilder: (_, _) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: 60.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

