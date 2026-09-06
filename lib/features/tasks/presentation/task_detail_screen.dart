import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tasker_app/core/models/models.dart';
import 'package:tasker_app/core/providers/tasks_provider.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/decorations.dart';
import 'package:tasker_app/core/ui/designs/spacing.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/ui/widgets/app_error_widget.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import 'package:tasker_app/features/tasks/presentation/widgets/task_details_option_sheet.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;
  final String? distance;

  const TaskDetailScreen({super.key, required this.taskId, this.distance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: taskAsync.when(
        data: (task) => _TaskDetailBody(task: task, distance: distance),
        loading: () => const _TaskDetailShimmer(),
        error: (err, st) => SafeArea(
          child: Column(
            children: [
              const _DetailAppBar(title: 'Task Details'),
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

class _TaskDetailBody extends StatelessWidget {
  final Task task;
  final String? distance;

  const _TaskDetailBody({required this.task, this.distance});

  @override
  Widget build(BuildContext context) {
    // 1. First image attachment is used as task cover image
    final imageAttachments =
        task.attachments
            ?.where((a) => a.mimeType?.startsWith('image/') ?? false)
            .toList() ??
        [];
    final TaskAttachment? coverImage = imageAttachments.isNotEmpty
        ? imageAttachments.first
        : null;

    // 2. All other attachments (remaining images + non-images)
    final otherAttachments =
        task.attachments?.where((a) => a != coverImage).toList() ?? [];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ─── TOP APP BAR ───
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BackButton(),
                  Text(
                    'Task Details',
                    style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
                  ),
                  _CircleIconButton(
                    icon: Icons.more_vert_rounded,
                    onTap: () async {
                      final action = await TaskDetailsOptionSheet.show(
                        context,
                        task: task,
                      );
                      if (action != null && context.mounted) {
                        _handleOptionAction(context, action);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── HERO CARD (Cover Image in Background) ───
                _TaskHeroCard(
                  task: task,
                  distance: distance,
                  coverImage: coverImage,
                ),

                AppSpacing.hLg,

                // ─── POSTER INFO CARD ("Latest Teleconsult" Style) ───
                _PosterInfoRow(task: task),

                AppSpacing.hLg,

                // ─── BUDGET CARD ("e-Cards" Style) ───
                _BudgetCard(task: task),

                AppSpacing.hLg,

                // ─── DESCRIPTION SECTION ───
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

                // ─── OTHER ATTACHMENTS (Bottom Section) ───
                if (otherAttachments.isNotEmpty) ...[
                  _AttachmentsSection(attachments: otherAttachments),
                  AppSpacing.hLg,
                ],

                // ─── ASSIGNMENT STATUS ───
                if (task.assignment != null) ...[
                  _AssignmentCard(assignment: task.assignment!),
                  AppSpacing.hLg,
                ],

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleOptionAction(BuildContext context, TaskOptionAction action) {
    switch (action) {
      case TaskOptionAction.startTask:
      case TaskOptionAction.completeTask:
      case TaskOptionAction.getPin:
        break;
      case TaskOptionAction.call:
        _makePhoneCall(context, task.customer?.phoneNumber);
        break;
      case TaskOptionAction.report:
        context.showMessage('Report task clicked');
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR (fallback header)
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
          SizedBox(width: 48.r),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD (Cover Image background from first attachment image)
// ─────────────────────────────────────────────────────────────────────────────

class _TaskHeroCard extends ConsumerWidget {
  final Task task;
  final String? distance;
  final TaskAttachment? coverImage;

  const _TaskHeroCard({required this.task, this.distance, this.coverImage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusInfo = _StatusHelper.resolve(task.status);
    final heroImageUrl = coverImage?.url;

    final isAssignedAsync = ref.watch(
      isUserAssignedToTaskProvider(task.id ?? ''),
    );
    final isAssigned = isAssignedAsync.value ?? false;

    final firstLocation = (task.locations != null && task.locations!.isNotEmpty)
        ? task.locations!.first
        : null;

    String locationText = 'Location not specified';
    if (firstLocation != null) {
      final parts = <String>[];
      if (firstLocation.city != null) parts.add(firstLocation.city!);
      if (firstLocation.state != null) parts.add(firstLocation.state!);
      if (parts.isNotEmpty) locationText = parts.join(', ');
    }
    if (distance != null) {
      locationText += ' ($distance km)';
    }

    String scheduleText = 'Flexible timing';
    if (task.scheduledStartAt != null) {
      scheduleText =
          'Scheduled • ${DateFormat('MMM d, h:mm a').format(task.scheduledStartAt!)}';
    } else if (task.createdAt != null) {
      scheduleText = 'Posted ${_formatTimeAgo(task.createdAt!)}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Cover Photo Header (Tappable to launch full attachment dialog)
          GestureDetector(
            onTap: coverImage != null
                ? () => _AttachmentPreviewDialog.show(context, coverImage!)
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              child: SizedBox(
                height: 200.h,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: heroImageUrl != null
                          ? Image.network(
                              heroImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultGradientBanner(statusInfo),
                            )
                          : _buildDefaultGradientBanner(statusInfo),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    if (coverImage != null)
                      Positioned(
                        top: 16.h,
                        right: 16.w,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.r,
                            ),
                          ),
                          child: Icon(
                            Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 18.r,
                          ),
                        ),
                      ),
                    // Status Pill Tag overlaid on bottom left of media
                    Positioned(
                      bottom: 16.h,
                      left: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusInfo.color,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusInfo.icon,
                              color: Colors.white,
                              size: 14.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              statusInfo.label,
                              style: AppTextStyles.label.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content section inside card
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? 'Untitled Task',
                  style: AppTextStyles.h2.copyWith(fontSize: 20.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 12.h),

                // Location row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppColors.textMuted,
                      size: 16.r,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        locationText,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Schedule row
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: AppColors.textMuted,
                      size: 16.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      scheduleText,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Action Row inside Card Bottom (Direction button + call/more icons matching mockup)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.showMessage('Opening directions...');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(30.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10.r,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.near_me_rounded,
                                color: Colors.white,
                                size: 18.r,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'Direction',
                                  style: AppTextStyles.buttonMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isAssigned) ...[
                      SizedBox(width: 10.w),
                      _CircleIconButton(
                        icon: Icons.phone_outlined,
                        onTap: () {
                          _makePhoneCall(context, task.customer?.phoneNumber);
                        },
                      ),
                    ],
                    SizedBox(width: 8.w),
                    _CircleIconButton(
                      icon: Icons.more_horiz_rounded,
                      onTap: () async {
                        final action = await TaskDetailsOptionSheet.show(
                          context,
                          task: task,
                        );
                        if (action != null && context.mounted) {
                          _handleOptionAction(context, action);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultGradientBanner(_StatusInfo statusInfo) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusInfo.color.withValues(alpha: 0.8),
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.work_outline_rounded,
          color: Colors.white.withValues(alpha: 0.4),
          size: 64.r,
        ),
      ),
    );
  }

  void _handleOptionAction(BuildContext context, TaskOptionAction action) {
    switch (action) {
      case TaskOptionAction.startTask:
      case TaskOptionAction.completeTask:
      case TaskOptionAction.getPin:
        break;
      case TaskOptionAction.call:
        _makePhoneCall(context, task.customer?.phoneNumber);
        break;
      case TaskOptionAction.report:
        context.showMessage('Report task clicked');
        break;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POSTER INFO ROW ("Latest Teleconsult" style profile card)
// ─────────────────────────────────────────────────────────────────────────────

class _PosterInfoRow extends ConsumerWidget {
  final Task task;

  const _PosterInfoRow({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerName =
        task.customer?.fullname?.split(' ').first ?? 'Customer';
    final fullCustomerName = task.customer?.fullname ?? 'Customer';
    final rating = task.customer?.averageRatings?.toStringAsFixed(1) ?? 'New';

    final isAssignedAsync = ref.watch(
      isUserAssignedToTaskProvider(task.id ?? ''),
    );
    final isAssigned = isAssignedAsync.value ?? false;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
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
          Container(
            width: 52.r,
            height: 52.r,
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
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: Colors.white,
                size: 26.r,
              ),
            ),
          ),
          SizedBox(width: 14.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullCustomerName,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedStar,
                            color: const Color(0xFFF59E0B),
                            size: 12.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            rating,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFFD97706),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (isAssigned)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _makePhoneCall(context, task.customer?.phoneNumber);
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1.r,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCall,
                        color: AppColors.primary,
                        size: 16.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Call',
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

Future<void> _makePhoneCall(BuildContext context, String? phoneNumber) async {
  if (phoneNumber == null || phoneNumber.trim().isEmpty) {
    context.showError('Customer phone number not available');
    return;
  }
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.trim());
  try {
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      await launchUrl(launchUri);
    }
  } catch (_) {
    if (context.mounted) {
      context.showError('Could not launch device dialer');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUDGET CARD ("e-Cards" style gradient card)
// ─────────────────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final Task task;

  const _BudgetCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final budgetText = task.providerPayout?.toNaira() ?? 'Negotiable';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEA580C), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.3),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PROPOSED PAYOUT',
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 11.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Fixed Budget',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                budgetText,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 28.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Guaranteed task payment upon completion',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11.sp,
                ),
              ),
            ],
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24.r),
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
// SCHEDULE SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleSection extends StatelessWidget {
  final Task task;

  const _ScheduleSection({required this.task});

  @override
  Widget build(BuildContext context) {
    // Only consider expiresAt if it is valid (i.e. after createdAt)
    final bool isExpiresValid =
        task.expiresAt != null &&
        (task.createdAt == null || task.expiresAt!.isAfter(task.createdAt!));

    final hasSchedule =
        task.scheduledStartAt != null ||
        isExpiresValid ||
        task.createdAt != null;

    if (!hasSchedule) {
      return const SizedBox.shrink();
    }

    final rows = <Widget>[];

    if (task.createdAt != null) {
      rows.add(
        _InfoRow(
          icon: Icons.calendar_today_rounded,
          label: 'Posted On',
          value: _formatDate(task.createdAt!),
          color: AppColors.textMuted,
        ),
      );
    }

    if (task.scheduledStartAt != null) {
      if (rows.isNotEmpty) rows.add(_InfoDivider());
      rows.add(
        _InfoRow(
          icon: Icons.event_rounded,
          label: 'Scheduled Start',
          value: _formatDate(task.scheduledStartAt!),
          color: const Color(0xFF3B82F6),
        ),
      );
    }

    if (isExpiresValid) {
      if (rows.isNotEmpty) rows.add(_InfoDivider());
      rows.add(
        _InfoRow(
          icon: Icons.timer_off_rounded,
          label: 'Expires On',
          value: _formatDate(task.expiresAt!),
          color: const Color(0xFFF59E0B),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Schedule & Timing'),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
          child: Column(children: rows),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date.toLocal());
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border, width: 1.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
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
// OTHER ATTACHMENTS SECTION (Bottom Section for remaining attachments)
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentsSection extends StatelessWidget {
  final List<TaskAttachment> attachments;

  const _AttachmentsSection({required this.attachments});

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final images = attachments
        .where((a) => a.mimeType?.startsWith('image/') ?? false)
        .toList();
    final nonImages = attachments
        .where((a) => !(a.mimeType?.startsWith('image/') ?? false))
        .toList();

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
        if (images.isNotEmpty) _buildImageGrid(context, images),
        ...nonImages.map(
          (a) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _FileAttachmentItem(attachment: a),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context, List<TaskAttachment> images) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: SizedBox(
          height: 180.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: images.length,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final img = images[index];
              return GestureDetector(
                onTap: () => _AttachmentPreviewDialog.show(context, img),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    width: 200.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: AppColors.border, width: 1.r),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: img.url != null
                              ? Image.network(
                                  img.url!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
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
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 16.r,
                            ),
                          ),
                        ),
                      ],
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
    return GestureDetector(
      onTap: () => _AttachmentPreviewDialog.show(context, attachment),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.border, width: 1.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getFileIcon(attachment.mimeType),
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
            Icon(
              Icons.visibility_rounded,
              color: AppColors.textMuted,
              size: 20.r,
            ),
          ],
        ),
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
// FULL ATTACHMENT PREVIEW DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentPreviewDialog extends StatelessWidget {
  final TaskAttachment attachment;

  const _AttachmentPreviewDialog({required this.attachment});

  static void show(BuildContext context, TaskAttachment attachment) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (context) => _AttachmentPreviewDialog(attachment: attachment),
    );
  }

  bool get isImage => attachment.mimeType?.startsWith('image/') ?? false;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Center Preview Area
          Center(
            child: isImage
                ? _buildImageViewer(context)
                : _buildFilePreview(context),
          ),

          // Top Header Overlay Bar
          Positioned(
            top: 44.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.r,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isImage
                            ? Icons.image_rounded
                            : Icons.insert_drive_file_rounded,
                        color: Colors.white,
                        size: 16.r,
                      ),
                      SizedBox(width: 8.w),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 180.w),
                        child: Text(
                          attachment.fileName ??
                              (isImage ? 'Task Photo' : 'Attachment'),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Close Circular Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.r,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    if (attachment.url == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded, color: Colors.white70, size: 64.r),
            SizedBox(height: 12.h),
            Text(
              'Image unavailable',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.network(
        attachment.url!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.broken_image_rounded,
                color: Colors.white70,
                size: 64.r,
              ),
              SizedBox(height: 12.h),
              Text(
                'Failed to load image',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    return Container(
      width: 0.85.sw,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border, width: 1.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getFileIcon(attachment.mimeType),
              color: AppColors.primary,
              size: 48.r,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            attachment.fileName ?? 'Document Attachment',
            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          if (attachment.fileSize != null)
            Text(
              _formatFileSize(attachment.fileSize!),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.showMessage('Downloading attachment...');
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24.r),
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
              borderRadius: BorderRadius.circular(10.r),
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

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.border, height: 1.h, thickness: 1.r);
  }
}

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
        width: 42.r,
        height: 42.r,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
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
        highlightColor: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: AppSpacing.pAllMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _shimmerBox(40.r, 40.r, isCircle: true),
                  const Spacer(),
                  _shimmerBox(40.r, 40.r, isCircle: true),
                ],
              ),
              SizedBox(height: 24.h),
              _shimmerBox(double.infinity, 240.h, radius: 24.r),
              SizedBox(height: 24.h),
              _shimmerBox(double.infinity, 80.h, radius: 24.r),
              SizedBox(height: 24.h),
              _shimmerBox(double.infinity, 100.h, radius: 24.r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(
    double width,
    double height, {
    bool isCircle = false,
    double? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCircle ? null : BorderRadius.circular(radius ?? 12.r),
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
    switch (status?.toLowerCase().trim()) {
      case 'open' || 'searching':
        return const _StatusInfo(
          label: 'Accepting Offers',
          color: Color(0xFF10B981),
          icon: Icons.radio_button_checked_rounded,
        );
     
      case 'assigned':
        return const _StatusInfo(
          label: 'Assigned',
          color: AppColors.primary,
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
