import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/providers/providers.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import '../../../core/ui/designs/colors.dart';
import '../../../core/ui/designs/text_styles.dart';
import '../../../core/ui/designs/decorations.dart';
import '../../../core/ui/designs/spacing.dart';
import '../../notifications/presentation/widgets/notification_icon.dart';
// import 'widgets/stats_widgets.dart';
import 'package:tasker_app/core/ui/widgets/current_location.dart';
import '../../tasks/tasks_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  bool isOnline = true;

  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _gradientController;

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

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _gradientController.dispose();
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
    final user = ref.watch(userProvider);
    final address = ref.watch(userAddressProvider);

    final firstName = user.value?.providerProfile?.firstName ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
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
                    isOnline: isOnline,
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
                  child: _EarningsCard(gradientController: _gradientController),
                ),
              ),
            ),

            SliverToBoxAdapter(child: AppSpacing.hLg),

            // ─── NEARBY JOBS ───
            SliverPadding(
              padding: EdgeInsets.only(left: AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: _SlideUp(
                  animation: _staggered(2),
                  child: const _NearbyJobsSection(),
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

            // ─── PENDING OFFERS ───
            SliverPadding(
              padding: AppSpacing.pHorsMd,
              sliver: SliverToBoxAdapter(
                child: _SlideUp(
                  animation: _staggered(4),
                  child: const _PendingOffersSection(),
                ),
              ),
            ),

            SliverToBoxAdapter(child: AppSpacing.hLg),

            // ─── RECENT MESSAGES ───
            SliverPadding(
              padding: AppSpacing.pHorsMd,
              sliver: SliverToBoxAdapter(
                child: _SlideUp(
                  animation: _staggered(5),
                  child: const _RecentMessagesSection(),
                ),
              ),
            ),

            // Bottom padding for the floating banner
            SliverToBoxAdapter(child: SizedBox(height: 120.h)),
          ],
        ),
      ),
      floatingActionButton: _FloatingOnlineToggle(
        isOnline: isOnline,
        pulseController: _pulseController,
        onToggle: () {
          setState(() {
            isOnline = !isOnline;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

class _HomeAppBar extends StatelessWidget {
  final String firstName;
  final AnimationController pulseController;
  final bool isOnline;

  const _HomeAppBar({
    required this.firstName,
    required this.pulseController,
    required this.isOnline,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with online pulse ring
          Stack(
            alignment: Alignment.center,
            children: [
              if (isOnline)
                AnimatedBuilder(
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
              // Small green dot for online status
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14.r,
                    height: 14.r,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 2.5.r,
                      ),
                    ),
                  ),
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
                SizedBox(height: 4.h),
                const CurrentLocation(),
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
// EARNINGS CARD (Animated gradient + glassmorphism)
// ─────────────────────────────────────────────────────────────────────────────

class _EarningsCard extends StatelessWidget {
  final AnimationController gradientController;

  const _EarningsCard({required this.gradientController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gradientController,
      builder: (context, child) {
        final angle = gradientController.value * 2 * math.pi;
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            borderRadius: AppDecorations.radiusLg,
            gradient: LinearGradient(
              colors: const [
                Color(0xFF6366F1),
                Color(0xFF4F46E5),
                Color(0xFF7C3AED),
                Color(0xFF6366F1),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
              begin: Alignment(math.cos(angle), math.sin(angle)),
              end: Alignment(-math.cos(angle), -math.sin(angle)),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 24.r,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        );
      },
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
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                  AppSpacing.wSm,
                  Text(
                    "Today's Earnings",
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppDecorations.radiusXl,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 14.r,
                    ),
                    AppSpacing.wXs,
                    Text(
                      "+12%",
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "₦18,500",
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 32.sp,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "3 completed tasks today",
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
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
// NEARBY JOBS SECTION (horizontal scroll)
// ─────────────────────────────────────────────────────────────────────────────

class _NearbyJobsSection extends ConsumerWidget {
  const _NearbyJobsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyJobsAsync = ref.watch(nearbyJobsProvider);

    // If there is no data, do not show the section
    if (nearbyJobsAsync.hasValue && nearbyJobsAsync.value?.isEmpty == true) {
      return SizedBox.shrink();
    }
    final allTasks = nearbyJobsAsync.value ?? [];
    final hasMoreThan5 = allTasks.length > 5;
    final displayTasks = allTasks.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.md),
          child: _SectionHeader(
            title: "Nearby Jobs",
            actionText: hasMoreThan5 ? "See All" : null,
            onAction: hasMoreThan5 ? () {} : null,
          ),
        ),
        SizedBox(
          height: 190.h,
          child: nearbyJobsAsync.when(
            data: (_) {
              if (displayTasks.isEmpty) {
                return Center(
                  child: Text(
                    "No nearby jobs available.",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: displayTasks.length + 1,
                itemBuilder: (context, index) {
                  if (index == displayTasks.length) {
                    return SizedBox(width: AppSpacing.md);
                  }
                  final task = displayTasks[index];
                  return _JobCard(
                    title: task.title ?? 'No Title',
                    category: task.category?.name ?? 'General',
                    distance: task.distanceKm != null
                        ? '${task.distanceKm!.toStringAsFixed(1)} km'
                        : 'N/A',
                    price: '${task.budgetMax?.toNaira(2)}',
                    onTap: () {
                      if (task.id != null) {
                        context.pushNamed(
                          TasksRoutes.taskDetailRoute,
                          pathParameters: {'taskId': task.id!},
                          queryParameters: task.distanceKm != null
                              ? {
                                  'distance': task.distanceKm!.toStringAsFixed(
                                    1,
                                  ),
                                }
                              : const {},
                        );
                      }
                    },
                    timePosted: _formatTimeAgo(task.createdAt),
                    categoryIcon: _getCategoryIcon(task.category?.name),
                    accentColor: _getCategoryColor(task.category?.name),
                  );
                },
              );
            },
            loading: () {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return const _JobCardShimmer();
                },
              );
            },
            error: (err, st) => Center(
              child: Text(
                "Error loading jobs",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  IconData _getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.work_outline_rounded;
    final lower = categoryName.toLowerCase();
    if (lower.contains('plumb')) return Icons.plumbing_rounded;
    if (lower.contains('clean')) return Icons.cleaning_services_rounded;
    if (lower.contains('elect') || lower.contains('generator'))
      return Icons.bolt_rounded;
    return Icons.work_outline_rounded;
  }

  Color _getCategoryColor(String? categoryName) {
    if (categoryName == null) return const Color(0xFF6366F1);
    final lower = categoryName.toLowerCase();
    if (lower.contains('plumb')) return const Color(0xFF3B82F6);
    if (lower.contains('clean')) return const Color(0xFF10B981);
    if (lower.contains('elect') || lower.contains('generator'))
      return const Color(0xFFF59E0B);
    return const Color(0xFF6366F1);
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String category;
  final String distance;
  final String price;
  final String timePosted;
  final IconData categoryIcon;
  final Color accentColor;
  final VoidCallback? onTap;

  const _JobCard({
    required this.title,
    required this.category,
    required this.distance,
    required this.price,
    required this.timePosted,
    required this.categoryIcon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240.w,
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Category badge + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 4.h,
                    ),
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: AppDecorations.radiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon, color: accentColor, size: 12.r),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            category,
                            style: AppTextStyles.label.copyWith(
                              color: accentColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  price,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Title
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            // Distance + time
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textMuted,
                  size: 14.r,
                ),
                SizedBox(width: 4.w),
                Text(distance, style: AppTextStyles.bodySmall),
                SizedBox(width: 12.w),
                Icon(
                  Icons.access_time_rounded,
                  color: AppColors.textMuted,
                  size: 14.r,
                ),
                SizedBox(width: 4.w),
                Text(timePosted, style: AppTextStyles.bodySmall),
              ],
            ),
            SizedBox(height: 12.h),
            // Accept button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDecorations.radiusSm,
                  ),
                ),
                child: Text(
                  "View & Bid",
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: Colors.white,
                    fontSize: 13.sp,
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

class _JobCardShimmer extends StatelessWidget {
  const _JobCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(color: AppColors.border, width: 1.r),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.border,
        highlightColor: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDecorations.radiusSm,
                  ),
                ),
                Container(
                  width: 50.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDecorations.radiusSm,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: 180.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.radiusSm,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDecorations.radiusSm,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 60.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppDecorations.radiusSm,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.radiusSm,
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

class _PerformanceSnapshotCard extends StatelessWidget {
  const _PerformanceSnapshotCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                color: const Color(0xFF8B5CF6),
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
// PENDING OFFERS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _PendingOffersSection extends StatelessWidget {
  const _PendingOffersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Pending Offers",
          actionText: "See All",
          onAction: () {},
        ),
        _PendingOfferItem(
          title: "Painting Job",
          status: "Waiting for customer",
          statusColor: AppColors.warning,
          icon: Icons.format_paint_rounded,
        ),
        SizedBox(height: 8.h),
        _PendingOfferItem(
          title: "Furniture Assembly",
          status: "Viewed by customer",
          statusColor: AppColors.primaryLight,
          icon: Icons.chair_rounded,
        ),
      ],
    );
  }
}

class _PendingOfferItem extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final IconData icon;

  const _PendingOfferItem({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(color: AppColors.border, width: 1.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppDecorations.radiusSm,
            ),
            child: Icon(icon, color: statusColor, size: 20.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  status,
                  style: AppTextStyles.bodySmall.copyWith(color: statusColor),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENT MESSAGES SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _RecentMessagesSection extends StatelessWidget {
  const _RecentMessagesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: "Recent Messages",
          actionText: "View All",
          onAction: () {},
        ),
        _MessageItem(
          name: "Sarah",
          message: "Can you come earlier tomorrow?",
          time: "2 min ago",
          avatarColor: const Color(0xFFEC4899),
          hasUnread: true,
        ),
        SizedBox(height: 8.h),
        _MessageItem(
          name: "Michael",
          message: "Thanks for the great work!",
          time: "1 hr ago",
          avatarColor: const Color(0xFF3B82F6),
          hasUnread: false,
        ),
      ],
    );
  }
}

class _MessageItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final Color avatarColor;
  final bool hasUnread;

  const _MessageItem({
    required this.name,
    required this.message,
    required this.time,
    required this.avatarColor,
    required this.hasUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(color: AppColors.border, width: 1.r),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [avatarColor, avatarColor.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: AppTextStyles.buttonMedium.copyWith(
                  color: Colors.white,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      time,
                      style: AppTextStyles.label.copyWith(fontSize: 10.sp),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: hasUnread
                              ? AppColors.textSecondary
                              : AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasUnread) ...[
                      SizedBox(width: 8.w),
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
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
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
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
                      color: isOnline
                          ? AppColors.success
                          : AppColors.textPrimary,
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
