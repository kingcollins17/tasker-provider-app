import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:tasker_app/core/providers/providers.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';

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
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import 'package:tasker_app/features/tasks/tasks_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      child: _HomeAppBar(firstName: firstName),
                    ),
                  ),

                  SliverToBoxAdapter(child: AppSpacing.hLg),

                  // ─── EARNINGS CARD ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(child: EarningsCard()),
                  ),

                  SliverToBoxAdapter(child: AppSpacing.hLg),

                  // ─── ACCOUNT ISSUES ───
                  SliverPadding(
                    padding: AppSpacing.pHorsMd,
                    sliver: const SliverToBoxAdapter(
                      child: _AccountIssuesSection(),
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
  final String firstName;

  const _HomeAppBar({required this.firstName});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);

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
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 20.sp,
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
                      width: 14.r,
                      height: 14.r,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.success
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2.5.r,
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
          AppSpacing.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting,',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  firstName,
                  style: AppTextStyles.h3.copyWith(fontSize: 20.sp),
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
        width: 44.r,
        height: 44.r,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: color, size: 24.r),
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
    final user = ref.watch(userProvider).value;

    final avgRating = user?.averageRatings != null
        ? user!.averageRatings!.toDouble().toStringAsFixed(1)
        : '0.0';
    final totalJobs = user?.providerProfile?.totalTasksCompleted ?? 0;
    final credibility = user?.credibilityScore != null
        ? '${user!.credibilityScore}%'
        : '0%';

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppDecorations.radiusLg,
        border: Border.all(color: AppColors.border, width: 1.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance",
                style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppDecorations.radiusXl,
                ),
                child: Text(
                  "This Month",
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryLight,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _PerformanceStat(
                icon: Icons.star_rounded,
                value: avgRating,
                label: "Rating",
                color: const Color(0xFFF59E0B),
              ),
              _statDivider(),
              _PerformanceStat(
                icon: Icons.work_rounded,
                value: "$totalJobs",
                label: "Jobs",
                color: const Color(0xFF3B82F6),
              ),
              _statDivider(),
              _PerformanceStat(
                icon: Icons.payments_rounded,
                value: "₦245k",
                label: "Earned",
                color: const Color(0xFF10B981),
              ),
              _statDivider(),
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

  Widget _statDivider() {
    return Container(width: 1.r, height: 40.h, color: AppColors.border);
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
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
          SizedBox(height: 2.h),
          Text(label, style: AppTextStyles.label.copyWith(fontSize: 11.sp)),
        ],
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

