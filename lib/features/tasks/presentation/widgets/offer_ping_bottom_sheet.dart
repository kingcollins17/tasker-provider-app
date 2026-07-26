import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/models/models.dart';
import 'package:tasker_app/core/providers/tasks_provider.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/decorations.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';

/// A premium bottom sheet that presents an incoming dispatch ping for a task,
/// allowing the provider to accept or decline within a 30-second window.
class OfferPingBottomSheet extends ConsumerStatefulWidget {
  final String taskId;

  const OfferPingBottomSheet({super.key, required this.taskId});

  /// Shows the offer-ping bottom sheet using the root navigator context.
  ///
  /// Returns `true` if accepted, `false` if declined, and `null` if dismissed
  /// or timed out.
  static Future<bool?> show(String taskId) {
    final context = NavigatorKeys.rootNavigatorKey.currentContext;
    if (context == null) return Future.value(null);

    return showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OfferPingBottomSheet(taskId: taskId),
    );
  }

  @override
  ConsumerState<OfferPingBottomSheet> createState() =>
      _OfferPingBottomSheetState();
}

class _OfferPingBottomSheetState extends ConsumerState<OfferPingBottomSheet>
    with TickerProviderStateMixin {
  static const _timeoutSeconds = 120;

  late final AnimationController _countdownController;
  late final AnimationController _pulseController;
  late final AnimationController _entranceController;
  Timer? _autoDeclineTimer;
  bool _isResponding = false;

  @override
  void initState() {
    super.initState();

    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _timeoutSeconds),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _autoDeclineTimer = Timer(
      const Duration(seconds: _timeoutSeconds),
      _onTimeout,
    );
  }

  @override
  void dispose() {
    _autoDeclineTimer?.cancel();
    _countdownController.dispose();
    _pulseController.dispose();
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

    ref
        .read(dispatchPingProvider.notifier)
        .respond(
          widget.taskId,
          status: status,
          onSuccess: () {
            if (mounted) {
              Navigator.of(context).pop(status == 'accepted');
            }
          },
          onError: (err) {
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
          color: const Color(0xFF161B2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDragHandle(),
              _buildUrgencyBar(),
              SizedBox(height: 20.h),
              _buildHeader(),
              SizedBox(height: 20.h),
              _buildDivider(),
              SizedBox(height: 16.h),
              taskAsync.when(
                data: (task) => _buildTaskDetails(task),
                loading: () => _buildLoadingState(),
                error: (e, _) => _buildErrorState(e),
              ),
              SizedBox(height: 24.h),
              _buildActionButtons(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DRAG HANDLE ──────────────────────────────────────────────────────────

  Widget _buildDragHandle() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  // ─── URGENCY COUNTDOWN BAR ────────────────────────────────────────────────

  Widget _buildUrgencyBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _countdownController,
            builder: (context, _) {
              final remaining =
                  (_timeoutSeconds * (1 - _countdownController.value)).ceil();
              final progress = 1 - _countdownController.value;
              final isUrgent = remaining <= 10;

              return Column(
                children: [
                  // Timer text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: isUrgent
                                ? 0.5 + 0.5 * _pulseController.value
                                : 1.0,
                            child: Icon(
                              Icons.timer_outlined,
                              color: isUrgent
                                  ? AppColors.error
                                  : AppColors.warning,
                              size: 16.r,
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${remaining}s remaining',
                        style: AppTextStyles.label.copyWith(
                          color: isUrgent ? AppColors.error : AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: SizedBox(
                      height: 4.h,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.border.withValues(
                          alpha: 0.5,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUrgent ? AppColors.error : AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Animated icon badge
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + 0.06 * _pulseController.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF6C00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 16.r,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 28.r,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16.h),
          Text(
            'New Job Offer',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'You\'ve been matched for a task nearby',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── DIVIDER ──────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      color: AppColors.border,
    );
  }

  // ─── TASK DETAILS ─────────────────────────────────────────────────────────

  Widget _buildTaskDetails(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task title
          Text(
            task.title ?? 'Untitled Task',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),

          // Detail cards row
          Row(
            children: [
              Expanded(
                child: _DetailCard(
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.success,
                  label: 'Payout',
                  value: _formatPayout(task.providerPayout),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DetailCard(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.primary,
                  label: 'Distance',
                  value: _formatDistance(task.locations),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _DetailCard(
                  icon: Icons.category_outlined,
                  iconColor: AppColors.warning,
                  label: 'Category',
                  value: task.categoryId ?? '—',
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DetailCard(
                  icon: Icons.schedule_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'Schedule',
                  value: _formatSchedule(task.scheduledStartAt),
                ),
              ),
            ],
          ),

          // Description preview
          if (task.description != null && task.description!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDecorations.radiusSm,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    task.description!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── LOADING STATE ────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(
        children: [
          SizedBox(
            width: 32.r,
            height: 32.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.5.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Loading task details…',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ─── ERROR STATE ──────────────────────────────────────────────────────────

  Widget _buildErrorState(Object error) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Could not load task details',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACTION BUTTONS ───────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Accept button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isResponding ? null : () => _respond('accepted'),
                borderRadius: BorderRadius.circular(16.r),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: _isResponding
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.success, Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: _isResponding
                        ? AppColors.success.withValues(alpha: 0.3)
                        : null,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: _isResponding
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.3),
                              blurRadius: 12.r,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isResponding)
                          SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.r,
                              color: Colors.white,
                            ),
                          )
                        else
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 20.r,
                          ),
                        SizedBox(width: 10.w),
                        Text(
                          'Accept Job',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Decline button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isResponding ? null : () => _respond('declined'),
                borderRadius: BorderRadius.circular(16.r),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _isResponding
                          ? AppColors.border
                          : AppColors.textMuted.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: _isResponding
                              ? AppColors.border
                              : AppColors.textMuted,
                          size: 20.r,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Decline',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: _isResponding
                                ? AppColors.border
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── FORMATTING HELPERS ───────────────────────────────────────────────────

  String _formatPayout(double? payout) {
    if (payout == null) return '—';
    return payout.toNaira();
  }

  String _formatDistance(List<TaskLocation>? locations) {
    if (locations == null || locations.isEmpty) return '—';
    final first = locations.first;
    if (first.distanceKm != null) {
      return '${first.distanceKm!.toStringAsFixed(1)} km';
    }
    if (first.city != null) return first.city!;
    return '—';
  }

  String _formatSchedule(DateTime? scheduledAt) {
    if (scheduledAt == null) return 'Flexible';
    final now = DateTime.now();
    final diff = scheduledAt.difference(now);
    if (diff.isNegative) return 'ASAP';
    if (diff.inHours < 1) return '${diff.inMinutes}m away';
    if (diff.inHours < 24) return '${diff.inHours}h away';
    return '${diff.inDays}d away';
  }
}

// ─── DETAIL CARD WIDGET ───────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.radiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, color: iconColor, size: 14.r),
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
