import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:tasker_app/core/providers/providers.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';

import '../../../core/ui/designs/colors.dart';
import '../../../core/ui/designs/text_styles.dart';
import '../../../core/ui/designs/decorations.dart';
import '../../../core/ui/designs/spacing.dart';
import '../../notifications/presentation/widgets/notification_icon.dart';
import '../../profile/presentation/widgets/earnings_card.dart';
import 'package:tasker_app/core/ui/widgets/current_location.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Animation<double> _staggered(int index, {int total = 6}) {
    final start = (index / total).clamp(0.0, 1.0);
    final end = ((index + 2) / total).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(syncUserLocationProvider);
    ref.watch(userAddressProvider);
    ref.watch(currentRegionProvider);
    ref.watch(deviceTrayNotificationProvider);
    ref.watch(offerPingListenerProvider);
    ref.watch(pingLocationProvider);
    final user = ref.watch(userProvider);
    final address = ref.watch(userAddressProvider);

    final firstName = user.value?.providerProfile?.firstName ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── APP BAR ───
                SliverPadding(
                  padding: AppSpacing.pHorsMd,
                  sliver: SliverToBoxAdapter(
                    child: _SlideUp(
                      animation: _staggered(0),
                      child: _HomeAppBar(
                        firstName: firstName,
                        pulseController: _pulseController,
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: AppSpacing.hLg),

                // ─── EARNINGS CARD ───
                SliverPadding(
                  padding: AppSpacing.pHorsMd,
                  sliver: SliverToBoxAdapter(
                    child: _SlideUp(
                      animation: _staggered(1),
                      child: const EarningsCard(),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: AppSpacing.hLg),

                // ─── ACTIVE WORK ───
                SliverPadding(
                  padding: AppSpacing.pHorsMd,
                  sliver: SliverToBoxAdapter(
                    child: _SlideUp(
                      animation: _staggered(2),
                      child: const _ActiveWorkSection(),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: AppSpacing.hLg),

                // ─── PERFORMANCE SNAPSHOT ───
                SliverPadding(
                  padding: AppSpacing.pHorsMd,
                  sliver: SliverToBoxAdapter(
                    child: _SlideUp(
                      animation: _staggered(3),
                      child: const _PerformanceSnapshotCard(),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: AppSpacing.hLg),
                // Bottom padding for the floating banner
                SliverToBoxAdapter(child: SizedBox(height: 120.h)),
              ],
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
                            pulseController: _pulseController,
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
// STAGGERED ENTRANCE ANIMATION WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class _SlideUp extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _SlideUp({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 30 * (1 - animation.value)),
        child: Opacity(opacity: animation.value, child: child),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _HomeAppBar extends ConsumerWidget {
  final String firstName;
  final AnimationController pulseController;

  const _HomeAppBar({required this.firstName, required this.pulseController});

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
          // Avatar with online pulse ring
          Stack(
            alignment: Alignment.center,
            children: [
              isOnlineAsync.when(
                data: (isOnline) {
                  if (isOnline) {
                    return AnimatedBuilder(
                      animation: pulseController,
                      builder: (context, child) => Container(
                        width: 52.r + (6 * pulseController.value),
                        height: 52.r + (6 * pulseController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.success.withValues(
                              alpha: 0.3 - 0.2 * pulseController.value,
                            ),
                            width: 2.r,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
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
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
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

class _ActiveWorkSection extends StatelessWidget {
  const _ActiveWorkSection();

  @override
  Widget build(BuildContext context) {
    // Mock active tasks
    final activeTasks = [
      {
        'title': 'Plumbing Repair',
        'address': '123 Main St, Lagos',
        'time': 'Today, 2:00 PM',
        'icon': Icons.plumbing_rounded,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'AC Installation',
        'address': '45 Victoria Island, Lagos',
        'time': 'Tomorrow, 10:00 AM',
        'icon': Icons.ac_unit_rounded,
        'color': const Color(0xFF10B981),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Active Work",
          actionText: "See All",
          onAction: () {},
        ),
        ...activeTasks.map(
          (task) => _ActiveWorkCard(
            title: task['title'] as String,
            address: task['address'] as String,
            time: task['time'] as String,
            icon: task['icon'] as IconData,
            color: task['color'] as Color,
            onTap: () {},
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
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActiveWorkCard({
    required this.title,
    required this.address,
    required this.time,
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
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                    ],
                  ),
                ],
              ),
            ),
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

class _PerformanceSnapshotCard extends StatelessWidget {
  const _PerformanceSnapshotCard();

  @override
  Widget build(BuildContext context) {
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
                value: "4.9",
                label: "Rating",
                color: const Color(0xFFF59E0B),
              ),
              _statDivider(),
              _PerformanceStat(
                icon: Icons.work_rounded,
                value: "18",
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
                value: "98%",
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
  final AnimationController pulseController;

  const _FloatingOnlineToggle({
    required this.isOnline,
    required this.onToggle,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isOnline ? AppColors.success : AppColors.textMuted;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
            // Pulsing status dot
            AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) => Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(
                              alpha: 0.5 * pulseController.value,
                            ),
                            blurRadius: 8.r * pulseController.value,
                            spreadRadius: 2.r * pulseController.value,
                          ),
                        ]
                      : null,
                ),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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
