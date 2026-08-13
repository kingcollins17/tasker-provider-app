import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/models/models.dart';
import 'package:tasker_app/core/providers/tasks_provider.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'package:tasker_app/core/ui/designs/decorations.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/providers/services_provider.dart';

/// A premium bottom sheet that presents an incoming dispatch ping for a task,
/// allowing the provider to accept or decline within a 30-second window.
class OfferPingBottomSheet extends ConsumerStatefulWidget {
  final String taskId;

  final DateTime? expiresAt;
  const OfferPingBottomSheet({super.key, required this.taskId, this.expiresAt});

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
      builder: (_) => OfferPingBottomSheet(taskId: taskId, expiresAt: expiresAt),
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

    _countdownController = AnimationController(
      vsync: this,
      duration: duration,
    )..forward();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _autoDeclineTimer = Timer(
      duration,
      _onTimeout,
    );
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
            context.hideLoading();
            if (mounted) {
              Navigator.of(context).pop(status == 'accepted');
            }
          },
          onError: (err) {
            context.hideLoading();
            if (mounted) {
              setState(() => _isResponding = false);
              context.showError(err);
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
                onDecline: () => _respond('declined'),
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
  final VoidCallback onDecline;

  const _Header({
    required this.colorScheme,
    required this.isResponding,
    required this.onDecline,
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
            ),
          ),
          IconButton(
            onPressed: isResponding ? null : onDecline,
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
              const Color(0xFF059669).withValues(alpha: 0.8),
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

  const _TaskDetails({
    required this.task,
    required this.colorScheme,
    required this.isResponding,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceStr = _formatDistance(task.locations);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
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
                        color: const Color(0xFF059669),
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
                  error: (_, __) => const SizedBox.shrink(),
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
          SizedBox(height: 24.h),
          _DetailListItem(
            icon: Icons.location_on_outlined,
            text: _getLocationString(task.locations),
            colorScheme: colorScheme,
            isChecked: false,
          ),
          if (distanceStr != null) ...[
            SizedBox(height: 16.h),
            _DetailListItem(
              icon: Icons.directions_walk_rounded,
              text: distanceStr,
              colorScheme: colorScheme,
              isChecked: false,
            ),
          ],
          SizedBox(height: 16.h),
          _DetailListItem(
            icon: Icons.access_time_rounded,
            text: _formatSchedule(task.scheduledStartAt),
            colorScheme: colorScheme,
            isChecked: false,
          ),
          SizedBox(height: 32.h),
          _AcceptButton(
            task: task,
            colorScheme: colorScheme,
            isResponding: isResponding,
            onAccept: onAccept,
          ),
          SizedBox(height: 24.h),
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
              ? const Color(0xFF059669)
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
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isResponding ? null : onAccept,
          borderRadius: BorderRadius.circular(16.r),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF059669),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isResponding) ...[
                        SizedBox(
                          width: 18.r,
                          height: 18.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.r,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                      Text(
                        'Accept Job',
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatPayout(task.providerPayout),
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
  if (scheduledAt == null) return 'Flexible Schedule';
  final now = DateTime.now();
  final diff = scheduledAt.difference(now);
  if (diff.isNegative) return 'ASAP';
  if (diff.inHours < 1) return 'Starts in ${diff.inMinutes}m';
  if (diff.inHours < 24) return 'Starts in ${diff.inHours}h';
  return 'Starts in ${diff.inDays}d';
}
