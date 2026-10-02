import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:tasker_app/core/models/models.dart';
import 'package:tasker_app/core/providers/providers.dart';
import 'package:tasker_app/core/providers/services_provider.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/decorations.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import 'package:tasker_app/features/tasks/tasks_routes.dart' show TasksRoutes;

/// A premium bottom sheet presenting an incoming dispatch ping for a task,
/// allowing the provider to accept or decline the offer.
class OfferPingBottomSheet extends ConsumerStatefulWidget {
  final String taskId;
  final DateTime? expiresAt;

  const OfferPingBottomSheet({
    super.key,
    required this.taskId,
    this.expiresAt,
  });

  /// Shows the offer-ping bottom sheet using the root navigator context.
  ///
  /// Returns `true` if accepted, `false` if declined, and `null` if dismissed
  /// or timed out.
  static Future<bool?> show(String taskId, {DateTime? expiresAt}) {
    final context = NavigatorKeys.rootNavigatorKey.currentContext;
    if (context == null) return Future.value(null);

    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          OfferPingBottomSheet(taskId: taskId, expiresAt: expiresAt),
    );
  }

  @override
  ConsumerState<OfferPingBottomSheet> createState() =>
      _OfferPingBottomSheetState();
}

class _OfferPingBottomSheetState extends ConsumerState<OfferPingBottomSheet>
    with TickerProviderStateMixin {
  late final AnimationController _countdownController;
  late final AnimationController _entranceController;
  Timer? _autoDeclineTimer;
  bool _isResponding = false;

  Duration get _timeoutDuration {
    if (widget.expiresAt != null) {
      final difference = widget.expiresAt!.difference(DateTime.now());
      return difference.isNegative ? Duration.zero : difference;
    }
    return const Duration(minutes: 5);
  }

  @override
  void initState() {
    super.initState();

    final duration = _timeoutDuration;

    _countdownController = AnimationController(vsync: this, duration: duration)
      ..forward();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _autoDeclineTimer = Timer(duration, _onTimeout);
  }

  @override
  void dispose() {
    _autoDeclineTimer?.cancel();
    _countdownController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onTimeout() {
    if (mounted && !_isResponding) {
      Navigator.of(context).pop(null);
    }
  }

  void _respond(String status) {
    if (_isResponding) return;
    setState(() => _isResponding = true);
    _autoDeclineTimer?.cancel();
    context.showLoading();
    ref
        .read(dispatchPingProvider.notifier)
        .respond(
          widget.taskId,
          status: status,
          onSuccess: () {
            ref.invalidate(currentDispatchProvider);
            ref.invalidate(currentAssignmentProvider);
            ref.invalidate(userProvider);
            ref.invalidate(taskDetailProvider(widget.taskId));

            context.hideLoading();
            if (mounted) {
              Navigator.of(context).pop(status == 'accepted');

              Future.delayed(const Duration(milliseconds: 400), () {
                NavigatorKeys.rootNavigatorKey.currentContext?.pushNamed(
                  TasksRoutes.taskDetailRoute,
                  pathParameters: {'taskId': widget.taskId},
                );
              });
            }
          },
          onError: (err) {
            context.hideLoading();
            if (mounted) {
              setState(() => _isResponding = false);
              // If already assigned, close the sheet
              final msg = err.toLowerCase();
              const kwds = ['already', 'assigned'];
              if (kwds.every((k) => msg.contains(k))) {
                Navigator.of(context).pop(status == 'accepted');
              } else {
                context.showError(err);
              }
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final colorScheme = Theme.of(context).colorScheme;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _entranceController,
              curve: Curves.easeOutCubic,
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DragHandle(colorScheme: colorScheme),
              SizedBox(height: 12.h),
              _Header(
                colorScheme: colorScheme,
                isResponding: _isResponding,
                onClose: () => Navigator.of(context).pop(null),
              ),
              _UrgencyBar(
                colorScheme: colorScheme,
                animation: _countdownController,
              ),
              taskAsync.when(
                data: (task) => _TaskDetails(
                  task: task,
                  colorScheme: colorScheme,
                  isResponding: _isResponding,
                  onAccept: () => _respond('accepted'),
                  onDecline: () => _respond('declined'),
                ),
                loading: () => _LoadingState(colorScheme: colorScheme),
                error: (e, _) =>
                    _ErrorState(error: e, colorScheme: colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final ColorScheme colorScheme;

  const _DragHandle({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isResponding;
  final VoidCallback onClose;

  const _Header({
    required this.colorScheme,
    required this.isResponding,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'New Offer',
            style: AppTextStyles.h3.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
            ),
          ),
          IconButton(
            onPressed: isResponding ? null : onClose,
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 24.r,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: 24.r,
          ),
        ],
      ),
    );
  }
}

class _UrgencyBar extends StatelessWidget {
  final ColorScheme colorScheme;
  final Animation<double> animation;

  const _UrgencyBar({required this.colorScheme, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final progress = 1 - animation.value;
          return LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary.withValues(alpha: 0.8),
            ),
            minHeight: 2.h,
          );
        },
      ),
    );
  }
}

class _TaskDetails extends ConsumerWidget {
  final Task task;
  final ColorScheme colorScheme;
  final bool isResponding;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _TaskDetails({
    required this.task,
    required this.colorScheme,
    required this.isResponding,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceStr = _formatDistance(task.locations);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text(
            task.title ?? 'Untitled Task',
            style: AppTextStyles.subtitle.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          if (task.categoryId != null)
            ref
                .watch(categoryByIdProvider(task.categoryId!))
                .when(
                  data: (category) => Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      category.name ?? 'Unknown Category',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  loading: () => Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.withValues(alpha: 0.2),
                      highlightColor: Colors.grey.withValues(alpha: 0.1),
                      child: Container(
                        width: 100.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  error: (err, st) => const SizedBox.shrink(),
                ),
          SizedBox(height: 12.h),
          Text(
            task.description ?? 'You\'ve been matched for a task nearby.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 20.h),
          _DetailListItem(
            icon: Icons.location_on_outlined,
            text: _getLocationString(task.locations),
            colorScheme: colorScheme,
            isChecked: false,
          ),
          if (distanceStr != null) ...[
            SizedBox(height: 12.h),
            _DetailListItem(
              icon: Icons.directions_walk_rounded,
              text: distanceStr,
              colorScheme: colorScheme,
              isChecked: false,
            ),
          ],
          SizedBox(height: 12.h),
          _DetailListItem(
            icon: Icons.access_time_rounded,
            text: _formatSchedule(task.scheduledStartAt),
            colorScheme: colorScheme,
            isChecked: false,
          ),
          SizedBox(height: 20.h),

          // Payout & Renegotiation Info Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
              borderRadius: AppDecorations.radiusLg,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1.r,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 16.r,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Payout',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 11.sp,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatPayout(task.providerPayout),
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Amount shown is an initial estimate and is subject to renegotiation with the customer once assigned.',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11.5.sp,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Accept Offer Button (Primary Call to Action)
          _AcceptButton(
            task: task,
            colorScheme: colorScheme,
            isResponding: isResponding,
            onAccept: onAccept,
          ),
          SizedBox(height: 8.h),

          // Decline Button (Unemphasized text button)
          Center(
            child: TextButton(
              onPressed: isResponding ? null : onDecline,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Decline Offer',
                style: AppTextStyles.label.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _DetailListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;
  final bool isChecked;

  const _DetailListItem({
    required this.icon,
    required this.text,
    required this.colorScheme,
    this.isChecked = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isChecked
              ? AppColors.primary
              : colorScheme.onSurfaceVariant,
          size: 20.r,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isChecked
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _AcceptButton extends StatelessWidget {
  final Task task;
  final ColorScheme colorScheme;
  final bool isResponding;
  final VoidCallback onAccept;

  const _AcceptButton({
    required this.task,
    required this.colorScheme,
    required this.isResponding,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isResponding ? null : onAccept,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isResponding) ...[
                  SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5.r,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Accepting Offer...',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Accept Offer',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '•',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatPayout(task.providerPayout),
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final ColorScheme colorScheme;

  const _LoadingState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.withValues(alpha: 0.2),
        highlightColor: Colors.grey.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: 250.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 200.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 150.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final ColorScheme colorScheme;

  const _ErrorState({required this.error, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.08),
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.error,
              size: 20.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Could not load task details',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FORMATTING HELPERS ───────────────────────────────────────────────────

String _formatPayout(double? payout) {
  if (payout == null) return '—';
  return payout.toNaira();
}

String _getLocationString(List<TaskLocation>? locations) {
  if (locations == null || locations.isEmpty) return 'Location not specified';
  final loc = locations.first;
  final parts = <String>[];
  if (loc.city != null && loc.city!.isNotEmpty) parts.add(loc.city!);
  if (loc.state != null && loc.state!.isNotEmpty) parts.add(loc.state!);
  if (parts.isEmpty) return loc.address ?? 'Location not specified';
  return parts.join(', ');
}

String? _formatDistance(List<TaskLocation>? locations) {
  if (locations == null || locations.isEmpty) return null;
  final first = locations.first;
  if (first.distanceKm != null) {
    return '${first.distanceKm!.toStringAsFixed(1)} km away';
  }
  return null;
}

String _formatSchedule(DateTime? scheduledAt) {
  if (scheduledAt == null) return 'As Soon As Possible';
  final now = DateTime.now();
  final diff = scheduledAt.difference(now);
  if (diff.isNegative) return 'As Soon As Possible';
  if (diff.inHours < 1) return 'Starts in ${diff.inMinutes}m';
  if (diff.inHours < 24) return 'Starts in ${diff.inHours}h';
  return 'Starts in ${diff.inDays}d';
}
