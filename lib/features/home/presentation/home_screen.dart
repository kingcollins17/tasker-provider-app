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
import '../../notifications/presentation/widgets/notification_icon.dart';
import '../../profile/presentation/widgets/earnings_card.dart';
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
    final user = ref.watch(userProvider);
    ref.watch(syncUserLocationProvider);
    ref.watch(userAddressProvider);

    final firstName = user.value?.providerProfile?.firstName ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(userProvider);
                ref.invalidate(isOnlineProvider);
                ref.invalidate(notificationsProvider);
                ref.invalidate(selectedEarningsProvider);
                try {
                  await Future.wait([
                    ref.read(userProvider.future),
                    ref.read(selectedEarningsProvider.future),
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
                          data: (isOnline) => _FloatingOnlineToggle(
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

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE WORK SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveWorkSection extends ConsumerWidget {
  const _ActiveWorkSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentAsync = ref.watch(currentAssignmentProvider(null));

    return assignmentAsync.when(
      data: (assignment) {
        if (assignment == null) {
          return const _NoActiveWorkCard();
        }

        final title = assignment.task?.title ?? 'Active Task';
        final address =
            assignment.provider?.location?.addressLine ??
            assignment.task?.description ??
            'Location not specified';

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

        final priceStr = assignment.acceptedPrice != null
            ? assignment.acceptedPrice!.toNaira()
            : (assignment.task?.providerPayout != null
                  ? assignment.task!.providerPayout!.toNaira()
                  : null);

        final statusStr = (assignment.status ?? 'assigned')
            .replaceAll('_', ' ')
            .toUpperCase();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: "Active Work", onAction: () {}),
            _ActiveWorkCard(
              title: title,
              address: address,
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
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: "Active Work"),
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppDecorations.radiusMd,
              border: Border.all(color: AppColors.border, width: 1.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDecorations.radiusSm,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 180.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            width: 80.w,
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
        ),
      ],
    );
  }
}

class _ActiveWorkCard extends StatelessWidget {
  final String title;
  final String address;
  final String time;
  final String? price;
  final String? status;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActiveWorkCard({
    required this.title,
    required this.address,
    required this.time,
    this.price,
    this.status,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppDecorations.radiusSm,
              ),
              child: Icon(icon, color: color, size: 24.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            status!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textMuted,
                        size: 14.r,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          address,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: AppColors.textMuted,
                        size: 14.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(time, style: AppTextStyles.bodySmall),
                      if (price != null) ...[
                        const Spacer(),
                        Text(
                          price!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 16.r,
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
// FLOATING ONLINE TOGGLE
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingOnlineToggle extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;

  const _FloatingOnlineToggle({required this.isOnline, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? AppColors.success : AppColors.textMuted;

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 1.sw - 32.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(
            color: isOnline
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border,
            width: 1.5.r,
          ),
          boxShadow: [
            BoxShadow(
              color: isOnline
                  ? AppColors.success.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: 20.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 12.r,
              height: 12.r,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline ? "You're Online" : "You're Offline",
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: isOnline ? AppColors.success : null,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isOnline
                        ? "Receiving nearby job requests"
                        : "Tap to start receiving jobs",
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.primary,
                borderRadius: AppDecorations.radiusSm,
              ),
              child: Text(
                isOnline ? "Go Offline" : "Go Online",
                style: AppTextStyles.buttonMedium.copyWith(
                  color: isOnline ? AppColors.success : Colors.white,
                  fontSize: 13.sp,
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
// ACCOUNT ISSUES SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _AccountIssuesSection extends ConsumerWidget {
  const _AccountIssuesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final kycStatusAsync = ref.watch(kycStatusProvider);
    final user = userAsync.value;

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

    final kycStatus = kycStatusAsync.value;
    if (kycStatus == KycStatus.pending ||
        kycStatus == KycStatus.rejected ||
        kycStatus == null) {
      issues.add(
        _AccountIssueCard(
          title: kycStatus == KycStatus.rejected
              ? 'KYC Rejected'
              : 'Complete KYC',
          description: kycStatus == KycStatus.rejected
              ? 'Your identity verification was rejected. Please try again.'
              : 'Verify your identity to start receiving tasks.',
          icon: Icons.verified_user_outlined,
          isError: kycStatus == KycStatus.rejected,
          onTap: () {
            context.go('/profile');
          },
        ),
      );
    }

    if (issues.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: "Account Issues"),
        ...issues,
        SizedBox(height: 8.h),
      ],
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
    final color = isError ? AppColors.error : AppColors.warning;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppDecorations.radiusSm,
              ),
              child: Icon(icon, color: color, size: 20.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 14.r,
            ),
          ],
        ),
      ),
    );
  }
}
