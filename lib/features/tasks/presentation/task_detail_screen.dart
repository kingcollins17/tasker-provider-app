import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/models/models.dart';
import 'package:tasker_app/core/providers/tasks_provider.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/decorations.dart';
import 'package:tasker_app/core/ui/designs/spacing.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/ui/widgets/app_error_widget.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import 'package:tasker_app/core/providers/bid_providers.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';
import 'package:tasker_app/features/tasks/presentation/widgets/bid_bottom_sheet.dart';
import 'package:tasker_app/features/tasks/presentation/widgets/task_details_option_sheet.dart';

import '../../../core/utils/debug_logger.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  final String? distance;

  const TaskDetailScreen({super.key, required this.taskId, this.distance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final myBidAsync = ref.watch(myBidProvider(taskId));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar:
          taskAsync.hasValue && taskAsync.value != null && !myBidAsync.isLoading
          ? _SendABidFAB(
              taskId: taskId,
              task: taskAsync.value!,
              myBid: myBidAsync.value,
            )
          : null,
      body: taskAsync.when(
        data: (task) => _TaskDetailBody(
          task: task,
          distance: distance,
          myBid: myBidAsync.value,
        ),
        loading: () => const _TaskDetailShimmer(),
        error: (err, st) => SafeArea(
          child: Column(
            children: [
              _DetailAppBar(title: 'Task Details'),
              Expanded(
                child: AppErrorWidget(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN BODY (data loaded)
// ─────────────────────────────────────────────────────────────────────────────

class _SendABidFAB extends ConsumerWidget {
  final String taskId;
  final Task task;
  final TaskBid? myBid;

  const _SendABidFAB({required this.taskId, required this.task, this.myBid});

  bool get _isUpdate =>
      myBid != null &&
      myBid!.status != 'rejected' &&
      myBid!.status != 'cancelled';

  Duration? _parseDuration(String? duration) {
    if (duration == null) return null;
    final parts = duration.split(' ');
    if (parts.isNotEmpty) {
      final hours = int.tryParse(parts[0]);
      if (hours != null) return Duration(hours: hours);
    }
    return null;
  }

  Future<void> _onSendBid(BuildContext context, WidgetRef ref) async {
    final request = await BidBottomSheet.show(
      context,
      initialBudget: _isUpdate ? myBid!.price : task.providerPayout,
      initialMessage: _isUpdate ? myBid!.message : null,
      initialDurationEstimate: _isUpdate
          ? _parseDuration(myBid!.estimatedDuration)
          : null,
      title: _isUpdate ? 'Update Your Bid' : null,
      submitButtonText: _isUpdate ? 'Update Bid' : null,
    );
    debugLog(request);

    if (request != null && context.mounted) {
      context.showLoading();

      void onSuccess() {
        if (context.mounted) {
          context.hideLoading();
          context.showMessage(
            _isUpdate
                ? 'Your bid has been successfully updated! 🎉'
                : 'Your bid has been successfully submitted! 🎉',
          );
        }
        ref.invalidate(taskDetailProvider(taskId));
        ref.invalidate(myBidProvider(taskId));
      }

      void onError(String error) {
        if (context.mounted) {
          context.hideLoading();
          context.showError(error);
        }
      }

      if (_isUpdate && myBid?.id != null) {
        await ref
            .read(bidManagementProvider.notifier)
            .updateBid(
              myBid!.id!,
              request,
              onSuccess: onSuccess,
              onError: onError,
            );
      } else {
        await ref
            .read(bidManagementProvider.notifier)
            .submitBid(taskId, request, onSuccess: onSuccess, onError: onError);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canBid = switch (task.status?.toLowerCase()) {
      'open' || 'bidding' => true,
      _ => false,
    };

    final bidStatus = myBid?.status?.toLowerCase();

    final isBidFinalized = switch (bidStatus) {
      'rejected' || 'cancelled' || 'withdrawn' => true,
      _ => false,
    };

    if (isBidFinalized) {
      final message = switch (bidStatus) {
        'rejected' => 'Your bid was not accepted. Keep trying on other tasks!',
        'cancelled' => 'You cancelled your bid for this task.',
        'withdrawn' => 'You withdrew your bid for this task.',
        _ => 'Your bid is no longer active.',
      };

      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surface
              : Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.r),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.textMuted,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!canBid) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.0),
            AppColors.background.withValues(alpha: 0.85),
            AppColors.background,
          ],
          stops: const [0.0, 0.35, 0.65],
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => _onSendBid(context, ref),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _isUpdate ? Icons.edit_rounded : Icons.gavel_rounded,
                    color: Colors.white,
                    size: 18.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  _isUpdate ? 'Update your Bid' : 'Send a Bid',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 18.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDetailBody extends StatelessWidget {
  final Task task;
  final String? distance;
  final TaskBid? myBid;

  const _TaskDetailBody({required this.task, this.distance, this.myBid});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ─── HERO HEADER ───
        SliverToBoxAdapter(
          child: _TaskHeroHeader(task: task, myBid: myBid),
        ),

        SliverPadding(
          padding: AppSpacing.pHorsMd,
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.hLg,

                // ─── POSTER INFO (like a social media post header) ───
                _PosterInfoRow(task: task),

                AppSpacing.hLg,

                // ─── DESCRIPTION ───
                _DescriptionSection(description: task.description),

                AppSpacing.hLg,

                // ─── SCHEDULE & TIMING ───
                _ScheduleSection(task: task),

                AppSpacing.hLg,

                // ─── LOCATIONS ───
                if (task.locations != null && task.locations!.isNotEmpty) ...[
                  _LocationsSection(
                    locations: task.locations!,
                    distance: distance,
                  ),
                  AppSpacing.hLg,
                ],

                // ─── ATTACHMENTS ───
                if (task.attachments != null &&
                    task.attachments!.isNotEmpty) ...[
                  _AttachmentsSection(attachments: task.attachments!),
                  AppSpacing.hLg,
                ],

                // ─── ASSIGNMENT STATUS ───
                if (task.assignment != null) ...[
                  _AssignmentCard(assignment: task.assignment!),
                  AppSpacing.hLg,
                ],

                // Bottom padding for the floating button
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR (simple back + title)
// ─────────────────────────────────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  final String title;

  const _DetailAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          const BackButton(),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
              textAlign: TextAlign.center,
            ),
          ),
          // Balance the row
          SizedBox(width: 48.r),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO HEADER (gradient banner with status badge + title)
// ─────────────────────────────────────────────────────────────────────────────

class _TaskHeroHeader extends ConsumerWidget {
  final Task task;
  final TaskBid? myBid;

  const _TaskHeroHeader({required this.task, this.myBid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusInfo = _StatusHelper.resolve(task.status);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusInfo.color.withValues(alpha: 0.35),
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back row with share/more actions
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(),
                    Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.share_rounded,
                          onTap: () {},
                        ),
                        SizedBox(width: 4.w),
                        _CircleIconButton(
                          icon: Icons.more_vert_rounded,
                          onTap: () async {
                            final action = await TaskDetailsOptionSheet.show(
                              context,
                              task: task,
                            );

                            if (action != null && context.mounted) {
                              switch (action) {
                                case TaskOptionAction.bid:
                                  await BidBottomSheet.show(
                                    context,
                                    initialBudget: task.providerPayout,
                                  );
                                  break;
                                case TaskOptionAction.chat:
                                  context.showMessage(
                                    'Chat with customer clicked',
                                  );
                                  break;
                                case TaskOptionAction.cancelBid:
                                  if (myBid != null && myBid!.id != null) {
                                    context.showLoading();
                                    await ref
                                        .read(bidManagementProvider.notifier)
                                        .withdrawBid(
                                          myBid!.id!,
                                          onSuccess: () {
                                            if (context.mounted) {
                                              context.hideLoading();
                                              context.showMessage(
                                                'Your bid has been successfully withdrawn',
                                              );
                                            }
                                            ref.invalidate(
                                              taskDetailProvider(task.id!),
                                            );
                                            ref.invalidate(
                                              myBidProvider(task.id!),
                                            );
                                          },
                                          onError: (error) {
                                            if (context.mounted) {
                                              context.hideLoading();
                                              context.showError(error);
                                            }
                                          },
                                        );
                                  } else {
                                    context.showError(
                                      'No active bid to cancel.',
                                    );
                                  }
                                  break;
                                case TaskOptionAction.report:
                                  context.showMessage('Report task clicked');
                                  break;
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: AppSpacing.pHorsMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),

                    // Status badge
                    _StatusBadge(
                      label: statusInfo.label,
                      color: statusInfo.color,
                      icon: statusInfo.icon,
                    ),

                    SizedBox(height: 12.h),

                    // Title
                    Text(
                      task.title ?? 'Untitled Task',
                      style: AppTextStyles.h2.copyWith(fontSize: 22.sp),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8.h),

                    // Posted time
                    if (task.createdAt != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14.r,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Posted ${_formatTimeAgo(task.createdAt!)}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    SizedBox(height: 16.h),
                    _BudgetCard(task: task),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POSTER INFO ROW (customer avatar + id, like social media post author)
// ─────────────────────────────────────────────────────────────────────────────

class _PosterInfoRow extends StatelessWidget {
  final Task task;

  const _PosterInfoRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final customerName =
        task.customer?.fullname?.split(' ').first ?? 'Customer';
    final rating = task.customer?.averageRatings?.toStringAsFixed(1) ?? 'New';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Customer avatar
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8B5CF6),
                  Color(0xFFC084FC),
                ], // Elegant purple gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                  blurRadius: 8.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: Colors.white,
                size: 24.r,
              ),
            ),
          ),
          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedStar,
                      color: const Color(0xFFF59E0B),
                      size: 14.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      rating,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Message button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.r,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedMessage01,
                      color: AppColors.primary,
                      size: 18.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Message',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DESCRIPTION SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  final String? description;

  const _DescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Description'),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDecorations.radiusMd,
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: Text(
            description!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUDGET CARD (glassmorphism feel)
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final Task task;

  const _BudgetCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final budgetText = task.providerPayout?.toNaira() ?? 'N/A';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.15),
            const Color(0xFF7C3AED).withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.r,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payments_rounded,
              color: AppColors.primaryLight,
              size: 24.r,
            ),
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  budgetText,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 20.sp,
                    color: AppColors.textPrimary,
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
// SCHEDULE SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleSection extends StatelessWidget {
  final Task task;

  const _ScheduleSection({required this.task});

  @override
  Widget build(BuildContext context) {
    final hasSchedule = task.scheduledStartAt != null || task.expiresAt != null;

    if (!hasSchedule && task.createdAt == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Schedule & Timing'),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDecorations.radiusMd,
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: Column(
            children: [
              if (task.scheduledStartAt != null)
                _InfoRow(
                  icon: Icons.event_rounded,
                  label: 'Scheduled Start',
                  value: _formatDate(task.scheduledStartAt!),
                  color: const Color(0xFF3B82F6),
                ),
              if (task.scheduledStartAt != null &&
                  (task.expiresAt != null || task.createdAt != null))
                _InfoDivider(),
              if (task.expiresAt != null)
                _InfoRow(
                  icon: Icons.timer_off_rounded,
                  label: 'Accepting Offers Until',
                  value: _formatDate(task.expiresAt!),
                  color: const Color(0xFFF59E0B),
                ),
              if (task.expiresAt != null && task.createdAt != null)
                _InfoDivider(),
              if (task.createdAt != null)
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Posted On',
                  value: _formatDate(task.createdAt!),
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATIONS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _LocationsSection extends StatelessWidget {
  final List<TaskLocation> locations;
  final String? distance;

  const _LocationsSection({required this.locations, this.distance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Location'),
        SizedBox(height: 8.h),
        ...locations.map(
          (loc) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _LocationCard(location: loc, distance: distance),
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final TaskLocation location;
  final String? distance;

  const _LocationCard({required this.location, this.distance});

  @override
  Widget build(BuildContext context) {
    final addressParts = <String>[];
    if (location.city != null) addressParts.add(location.city!);
    if (location.state != null) addressParts.add(location.state!);

    final addressText = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'No location specified';

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
              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              borderRadius: AppDecorations.radiusSm,
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: const Color(0xFF3B82F6),
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addressText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (distance != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '$distance km away',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
            size: 20.r,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ATTACHMENTS SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentsSection extends StatelessWidget {
  final List<TaskAttachment> attachments;

  const _AttachmentsSection({required this.attachments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Attachments',
          trailing: Text(
            '${attachments.length} file${attachments.length > 1 ? 's' : ''}',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              fontSize: 11.sp,
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // Image attachments grid
        _buildImageGrid(context),

        // Non-image attachments list
        ...attachments
            .where((a) => !(a.mimeType?.startsWith('image/') ?? false))
            .map(
              (a) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _FileAttachmentItem(attachment: a),
              ),
            ),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final images = attachments
        .where((a) => a.mimeType?.startsWith('image/') ?? false)
        .toList();

    if (images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: ClipRRect(
        borderRadius: AppDecorations.radiusMd,
        child: SizedBox(
          height: 180.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: images.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final img = images[index];
              return ClipRRect(
                borderRadius: AppDecorations.radiusMd,
                child: Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border, width: 1.r),
                    borderRadius: AppDecorations.radiusMd,
                  ),
                  child: img.url != null
                      ? Image.network(
                          img.url!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              color: AppColors.textMuted,
                              size: 32.r,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.image_rounded,
                            color: AppColors.textMuted,
                            size: 32.r,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FileAttachmentItem extends StatelessWidget {
  final TaskAttachment attachment;

  const _FileAttachmentItem({required this.attachment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(color: AppColors.border, width: 1.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              borderRadius: AppDecorations.radiusSm,
            ),
            child: Icon(
              _getFileIcon(attachment.mimeType),
              color: const Color(0xFF8B5CF6),
              size: 18.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName ?? 'Unknown file',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (attachment.fileSize != null)
                  Text(
                    _formatFileSize(attachment.fileSize!),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.download_rounded, color: AppColors.textMuted, size: 20.r),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file_rounded;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (mimeType.contains('video')) return Icons.videocam_rounded;
    if (mimeType.contains('audio')) return Icons.audiotrack_rounded;
    return Icons.insert_drive_file_rounded;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSIGNMENT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final TaskAssignment assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _StatusHelper.resolve(assignment.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Assignment'),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDecorations.radiusMd,
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.assignment_ind_rounded,
                label: 'Status',
                value: statusInfo.label,
                color: statusInfo.color,
              ),
              if (assignment.acceptedPrice != null) ...[
                _InfoDivider(),
                _InfoRow(
                  icon: Icons.payments_rounded,
                  label: 'Accepted Price',
                  value: assignment.acceptedPrice!.toNaira(),
                  color: const Color(0xFF10B981),
                ),
              ],
              if (assignment.assignedAt != null) ...[
                _InfoDivider(),
                _InfoRow(
                  icon: Icons.event_available_rounded,
                  label: 'Assigned',
                  value: DateFormat(
                    'MMM d, yyyy • h:mm a',
                  ).format(assignment.assignedAt!),
                  color: const Color(0xFF3B82F6),
                ),
              ],
              if (assignment.completedAt != null) ...[
                _InfoDivider(),
                _InfoRow(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  value: DateFormat(
                    'MMM d, yyyy • h:mm a',
                  ).format(assignment.completedAt!),
                  color: const Color(0xFF10B981),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// REUSABLE INTERNAL WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

// ─── Section Title ───

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16.sp)),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

// ─── Status Badge ───

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppDecorations.radiusXl,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.r),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Row (icon + label + value) ───

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppDecorations.radiusSm,
            ),
            child: Icon(icon, color: color, size: 16.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
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

// ─── Info Divider ───

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.border, height: 1.h, thickness: 1.r);
  }
}

// ─── Circle Icon Button ───

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1.r),
        ),
        child: Center(
          child: Icon(icon, color: AppColors.textSecondary, size: 20.r),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LOADING SKELETON
// ─────────────────────────────────────────────────────────────────────────────

class _TaskDetailShimmer extends StatelessWidget {
  const _TaskDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: AppColors.border,
        highlightColor: AppColors.surface,
        child: SingleChildScrollView(
          padding: AppSpacing.pAllMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button placeholder
              Row(
                children: [
                  _shimmerBox(40.r, 40.r, isCircle: true),
                  const Spacer(),
                  _shimmerBox(40.r, 40.r, isCircle: true),
                  SizedBox(width: 8.w),
                  _shimmerBox(40.r, 40.r, isCircle: true),
                ],
              ),
              SizedBox(height: 24.h),

              // Status badge
              _shimmerBox(100.w, 28.h),
              SizedBox(height: 16.h),

              // Title
              _shimmerBox(double.infinity, 24.h),
              SizedBox(height: 8.h),
              _shimmerBox(200.w, 24.h),
              SizedBox(height: 12.h),

              // Time
              _shimmerBox(150.w, 16.h),
              SizedBox(height: 24.h),

              // Poster info
              _shimmerBox(double.infinity, 72.h),
              SizedBox(height: 24.h),

              // Description
              _shimmerBox(80.w, 20.h),
              SizedBox(height: 8.h),
              _shimmerBox(double.infinity, 120.h),
              SizedBox(height: 24.h),

              // Budget
              _shimmerBox(double.infinity, 80.h),
              SizedBox(height: 24.h),

              // Schedule
              _shimmerBox(120.w, 20.h),
              SizedBox(height: 8.h),
              _shimmerBox(double.infinity, 140.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height, {bool isCircle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCircle ? null : AppDecorations.radiusSm,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS HELPER
// ─────────────────────────────────────────────────────────────────────────────

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _StatusHelper {
  static _StatusInfo resolve(String? status) {
    switch (status?.toLowerCase()) {
      case 'open':
        return const _StatusInfo(
          label: 'Accepting Offers',
          color: Color(0xFF10B981),
          icon: Icons.radio_button_checked_rounded,
        );
      case 'bidding':
        return const _StatusInfo(
          label: 'Accepting Offers',
          color: Color(0xFF3B82F6),
          icon: Icons.gavel_rounded,
        );
      case 'assigned':
        return const _StatusInfo(
          label: 'Assigned',
          color: Color(0xFF8B5CF6),
          icon: Icons.person_pin_rounded,
        );
      case 'in_progress':
        return const _StatusInfo(
          label: 'In Progress',
          color: Color(0xFFF59E0B),
          icon: Icons.play_circle_filled_rounded,
        );
      case 'completed':
        return const _StatusInfo(
          label: 'Completed',
          color: Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
      case 'cancelled':
        return const _StatusInfo(
          label: 'Cancelled',
          color: Color(0xFFEF4444),
          icon: Icons.cancel_rounded,
        );
      case 'expired':
        return const _StatusInfo(
          label: 'Expired',
          color: Color(0xFF64748B),
          icon: Icons.timer_off_rounded,
        );
      default:
        return const _StatusInfo(
          label: 'Unknown',
          color: Color(0xFF64748B),
          icon: Icons.help_outline_rounded,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UTIL
// ─────────────────────────────────────────────────────────────────────────────

String _formatTimeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hrs ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return DateFormat('MMM d, yyyy').format(date);
}
