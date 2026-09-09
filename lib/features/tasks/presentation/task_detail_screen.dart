import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tasker_app/core/models/models.dart';
import 'package:tasker_app/core/providers/tasks_provider.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/ui/widgets/app_error_widget.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import 'package:tasker_app/core/utils/extensions/image_ext.dart';
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(taskDetailProvider(taskId));
          ref.invalidate(taskAssignmentProvider(taskId));
          ref.invalidate(isUserAssignedToTaskProvider(taskId));
          try {
            await Future.wait([
              ref.read(taskDetailProvider(taskId).future),
            ]);
          } catch (_) {}
        },
        child: taskAsync.when(
          data: (task) => _TaskDetailBody(task: task, distance: distance),
          loading: () => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: const _TaskDetailShimmer(),
            ),
          ),
          error: (err, st) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100.h,
              child: SafeArea(
                child: Column(
                  children: [
                    const _DetailAppBar(title: 'Task Details'),
                    Expanded(
                      child: AppErrorWidget(
                        error: err,
                        onRetry: () =>
                            ref.invalidate(taskDetailProvider(taskId)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN BODY
// ─────────────────────────────────────────────────────────────────────────────

class _TaskDetailBody extends ConsumerWidget {
  final Task task;
  final String? distance;

  const _TaskDetailBody({required this.task, this.distance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final imageAttachments =
        task.attachments
            ?.where((a) => a.mimeType?.startsWith('image/') ?? false)
            .toList() ??
        [];
    final otherAttachments =
        task.attachments
            ?.where((a) => !(a.mimeType?.startsWith('image/') ?? false))
            .toList() ??
        [];

    final formattedDate = task.scheduledStartAt != null
        ? DateFormat('MMMM d, yyyy').format(task.scheduledStartAt!)
        : (task.createdAt != null
            ? DateFormat('MMMM d, yyyy').format(task.createdAt!)
            : 'Flexible Date');

    final payoutStr = task.providerPayout?.toNaira() ??
        task.customerTotalPrice?.toNaira() ??
        'Negotiable';

    final isAssignedAsync = ref.watch(
      isUserAssignedToTaskProvider(task.id ?? ''),
    );
    final isAssigned = isAssignedAsync.value ?? false;

    // Location text
    String? primaryLocationText;
    if (task.locations != null && task.locations!.isNotEmpty) {
      final loc = task.locations!.first;
      final parts = <String>[];
      if (loc.city != null && loc.city!.isNotEmpty) parts.add(loc.city!);
      if (loc.state != null && loc.state!.isNotEmpty) parts.add(loc.state!);
      if (parts.isNotEmpty) {
        primaryLocationText = parts.join(', ');
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          children: [
            // ─── TOP BANNER CAROUSEL ───
            _ImageHeaderCarousel(
              imageAttachments: imageAttachments,
              onOptionTap: () async {
                final action = await TaskDetailsOptionSheet.show(
                  context,
                  task: task,
                );
                if (action != null && context.mounted) {
                  _handleOptionAction(context, action);
                }
              },
            ),

            // ─── OVERLAPPING CONTENT CARD ───
            Transform.translate(
              offset: Offset(0, -24.h),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── TITLE ───
                    Text(
                      task.title ?? 'Untitled Task',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : Colors.black87,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 6.h),

                    // ─── LOCATION & SCHEDULED DATE ROW ───
                    Row(
                      children: [
                        if (primaryLocationText != null) ...[
                          Icon(
                            Icons.location_on_rounded,
                            size: 15.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            primaryLocationText,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textSecondary
                                  : Colors.grey[700],
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 12.w),
                        ],
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textSecondary
                                  : Colors.grey[700],
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // ─── STATUS & PAYOUT ROW ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusDropdownPill(
                          status: task.status,
                          isDark: isDark,
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
                        Text(
                          payoutStr,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),

                    // ─── DESCRIPTION DIRECTLY UNDER TITLE ───
                    if (task.description != null &&
                        task.description!.trim().isNotEmpty) ...[
                      SizedBox(height: 10.h),
                      Text(
                        task.description!.trim(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13.5.sp,
                          color: isDark
                              ? AppColors.textSecondary
                              : Colors.grey[700],
                          height: 1.45,
                        ),
                      ),
                    ],

                    SizedBox(height: 12.h),

                    // ─── CUSTOMER CARD ───
                    if (task.customer != null) ...[
                      _CustomerCard(
                        customer: task.customer,
                        isDark: isDark,
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // ─── ATTACHMENTS (NON-IMAGE FILES) ───
                    if (otherAttachments.isNotEmpty) ...[
                      Text(
                        'Attachments',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ...otherAttachments.map(
                        (att) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: _WorkFileCard(
                            attachment: att,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // ─── LOCATION SECTION ───
                    if (task.locations != null && task.locations!.isNotEmpty) ...[
                      Text(
                        'Locations',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ...task.locations!.map(
                        (loc) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: _LocationCard(
                            location: loc,
                            distance: distance,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // ─── ASSIGNMENT CARD ───
                    if (task.assignment != null) ...[
                      _AssignmentCard(
                        assignment: task.assignment!,
                        isDark: isDark,
                      ),
                      SizedBox(height: 14.h),
                    ],

                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ─── FIXED BOTTOM BAR (Matching Inspo Layout) ───
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.border : Colors.grey.withValues(alpha: 0.2),
              width: 1.r,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Payout',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    payoutStr,
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final action = await TaskDetailsOptionSheet.show(
                    context,
                    task: task,
                  );
                  if (action != null && context.mounted) {
                    _handleOptionAction(context, action);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAssigned
                      ? const Color(0xFFEF4444)
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                ),
                child: Text(
                  isAssigned ? 'Manage Task' : 'Accept Job',
                  style: AppTextStyles.buttonMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOptionAction(BuildContext context, TaskOptionAction action) {
    switch (action) {
      case TaskOptionAction.startTask:
      case TaskOptionAction.completeTask:
      case TaskOptionAction.getPin:
      case TaskOptionAction.adjustPrice:
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
// TOP HEADER CAROUSEL WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _ImageHeaderCarousel extends StatefulWidget {
  final List<TaskAttachment> imageAttachments;
  final VoidCallback onOptionTap;

  const _ImageHeaderCarousel({
    required this.imageAttachments,
    required this.onOptionTap,
  });

  @override
  State<_ImageHeaderCarousel> createState() => _ImageHeaderCarouselState();
}

class _ImageHeaderCarouselState extends State<_ImageHeaderCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasImages = widget.imageAttachments.isNotEmpty;

    return SizedBox(
      height: 280.h,
      child: Stack(
        children: [
          // Banner Image Carousel / Placeholder
          Positioned.fill(
            child: hasImages
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: widget.imageAttachments.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final img = widget.imageAttachments[index];
                      return GestureDetector(
                        onTap: () =>
                            _AttachmentPreviewDialog.show(context, img),
                        child: img.url.image(
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          fallbackIcon: Icons.image_rounded,
                        ),
                      );
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.landscape_rounded,
                            size: 56.r,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'No Attachment Photos',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Bottom Gradient Overlay for Carousel Dots Visibility
          if (hasImages)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 70.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

          // Carousel Page Indicator Dots
          if (hasImages && widget.imageAttachments.length > 1)
            Positioned(
              bottom: 34.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageAttachments.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    width: _currentIndex == index ? 20.w : 7.w,
                    height: 7.h,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),

          // Top Action Buttons
          Positioned(
            top: 44.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleOverlayButton(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const BackButton(color: Colors.white),
                ),
                _CircleOverlayButton(
                  onTap: widget.onOptionTap,
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.white,
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

class _CircleOverlayButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _CircleOverlayButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.r,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER CARD WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _CustomerCard extends StatelessWidget {
  final CustomerLite? customer;
  final bool isDark;

  const _CustomerCard({
    required this.customer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final name = customer?.fullname?.trim();
    final displayName = (name != null && name.isNotEmpty) ? name : 'Customer';
    final phoneNumber = customer?.phoneNumber;
    final hasPhone = phoneNumber != null && phoneNumber.trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.border : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primary,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Customer',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _makePhoneCall(context, phoneNumber),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: hasPhone
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : (isDark ? Colors.white10 : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: hasPhone
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone_rounded,
                      size: 14.r,
                      color: hasPhone
                          ? const Color(0xFF10B981)
                          : AppColors.textMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Call',
                      style: AppTextStyles.label.copyWith(
                        color: hasPhone
                            ? const Color(0xFF10B981)
                            : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5.sp,
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
// STATUS DROPDOWN PILL WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _StatusDropdownPill extends StatelessWidget {
  final String? status;
  final bool isDark;
  final VoidCallback onTap;

  const _StatusDropdownPill({
    required this.status,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _StatusHelper.resolve(status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: statusInfo.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusInfo.icon,
              size: 13.r,
              color: statusInfo.color,
            ),
            SizedBox(width: 4.w),
            Text(
              statusInfo.label,
              style: AppTextStyles.label.copyWith(
                color: statusInfo.color,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 15.r,
              color: statusInfo.color,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WORK FILE CARD WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _WorkFileCard extends StatelessWidget {
  final TaskAttachment attachment;
  final bool isDark;

  const _WorkFileCard({
    required this.attachment,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final title = attachment.fileName ?? 'Task Attachment';
    final urlStr = attachment.url ?? 'https://tasker-app.internal';
    final isImage = attachment.mimeType?.startsWith('image/') ?? false;

    return GestureDetector(
      onTap: () => _AttachmentPreviewDialog.show(context, attachment),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark
                ? AppColors.border
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                isImage
                    ? Icons.image_outlined
                    : Icons.insert_drive_file_outlined,
                color: AppColors.primary,
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    urlStr,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp,
                      color: Colors.blue[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (attachment.url != null && isImage)
              attachment.url.image(
                width: 50.w,
                height: 38.h,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8.r),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR (Fallback Header)
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
// LOCATION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final TaskLocation location;
  final String? distance;
  final bool isDark;

  const _LocationCard({
    required this.location,
    this.distance,
    required this.isDark,
  });

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
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? AppColors.border
              : Colors.grey.withValues(alpha: 0.2),
        ),
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
                    color: isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
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
// ASSIGNMENT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _AssignmentCard extends StatelessWidget {
  final TaskAssignment assignment;
  final bool isDark;

  const _AssignmentCard({required this.assignment, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _StatusHelper.resolve(assignment.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assignment Details',
          style: AppTextStyles.h3.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? AppColors.border
                  : Colors.grey.withValues(alpha: 0.2),
            ),
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
                Divider(color: AppColors.border, height: 1.h, thickness: 1.r),
                _InfoRow(
                  icon: Icons.payments_rounded,
                  label: 'Accepted Price',
                  value: assignment.acceptedPrice!.toNaira(),
                  color: const Color(0xFF10B981),
                ),
              ],
              if (assignment.assignedAt != null) ...[
                Divider(color: AppColors.border, height: 1.h, thickness: 1.r),
                _InfoRow(
                  icon: Icons.event_available_rounded,
                  label: 'Assigned Date',
                  value: DateFormat('MMM d, yyyy • h:mm a').format(assignment.assignedAt!),
                  color: const Color(0xFF3B82F6),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

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
          Center(
            child: isImage
                ? _buildImageViewer(context)
                : _buildFilePreview(context),
          ),
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
      child: attachment.url.image(
        fit: BoxFit.contain,
        fallbackIcon: Icons.broken_image_rounded,
        errorWidget: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.broken_image_rounded,
            color: Colors.white70,
            size: 64.r,
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
              Icons.insert_drive_file_rounded,
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
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.showMessage('Downloading attachment...');
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER SKELETON
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
          padding: EdgeInsets.all(20.r),
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
              _shimmerBox(220.w, 24.h),
              SizedBox(height: 12.h),
              _shimmerBox(120.w, 20.h, radius: 10.r),
              SizedBox(height: 20.h),
              _shimmerBox(double.infinity, 44.h, radius: 16.r),
              SizedBox(height: 20.h),
              _shimmerBox(double.infinity, 80.h, radius: 16.r),
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
