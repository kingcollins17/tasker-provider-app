import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/api/users/interview.dart';
import '../../../../core/ui/designs/colors.dart';
import '../../../../core/ui/designs/decorations.dart';
import '../../../../core/ui/designs/text_styles.dart';
import '../../../../core/utils/extensions/flushbar_context_ext.dart';

/// Modal bottom sheet displaying detailed online interview information for providers.
class InterviewScheduleSheet extends StatelessWidget {
  final Interview? interview;

  const InterviewScheduleSheet({
    super.key,
    this.interview,
  });

  /// Displays the modal bottom sheet with the given [interview] details.
  static Future<void> show(
    BuildContext context, {
    Interview? interview,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InterviewScheduleSheet(interview: interview),
    );
  }

  Future<void> _launchMeeting(BuildContext context, String url) async {
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        context.showError('Could not open meeting link');
      }
    } catch (_) {
      if (context.mounted) {
        context.showError('Could not open meeting link');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasScheduledDate = interview?.scheduledAt != null;
    final formattedDate = hasScheduledDate
        ? DateFormat.yMMMMd().add_jm().format(interview!.scheduledAt!)
        : 'Not scheduled yet';

    final rawStatus = (interview?.status ?? 'PENDING').toUpperCase().trim();
    final isPassed = rawStatus == 'PASSED' || rawStatus == 'COMPLETED';
    final isCancelled = rawStatus == 'CANCELLED' || rawStatus == 'REJECTED';

    final Color statusColor = isPassed
        ? AppColors.success
        : isCancelled
            ? AppColors.error
            : hasScheduledDate
                ? AppColors.primary
                : AppColors.warning;

    final String statusText = isPassed
        ? 'COMPLETED'
        : isCancelled
            ? rawStatus
            : hasScheduledDate
                ? 'SCHEDULED'
                : 'PENDING SCHEDULE';

    final meetingLink = interview?.meetingLink?.trim();
    final hasMeetingLink = meetingLink != null && meetingLink.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(
          color: isDark ? AppColors.border : Colors.grey.shade200,
          width: 1.r,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.border : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: AppDecorations.radiusMd,
                    ),
                    child: Icon(
                      Icons.video_camera_front_rounded,
                      color: AppColors.primary,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Online Interview Details',
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20.r,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Status & Date Card
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppDecorations.radiusLg,
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 1.2.r,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.05),
                  blurRadius: 10.r,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Interview Status',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        statusText,
                        style: AppTextStyles.labelUppercase.copyWith(
                          color: statusColor,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Scheduled Date & Time
                Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      color: AppColors.primary,
                      size: 18.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10.5.sp,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5.sp,
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
          SizedBox(height: 16.h),

          // Notes / Instructions section
          if (interview?.notes != null && interview!.notes!.trim().isNotEmpty) ...[
            Text(
              'Notes & Instructions',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textMuted,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppDecorations.radiusMd,
                border: Border.all(
                  color: isDark ? AppColors.border : Colors.grey.shade200,
                  width: 1.r,
                ),
              ),
              child: Text(
                interview!.notes!,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.5.sp,
                  height: 1.4,
                  color: isDark
                      ? AppColors.textSecondary
                      : const Color(0xFF334155),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ] else if (!hasScheduledDate) ...[
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: AppDecorations.radiusMd,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Your interview will be scheduled after your KYC documents and professional reference have been submitted and reviewed by our team.',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.sp,
                        height: 1.35,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Join Meeting Button
          if (hasMeetingLink && !isPassed && !isCancelled) ...[
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: () => _launchMeeting(context, meetingLink),
                icon: Icon(
                  Icons.video_call_rounded,
                  size: 20.r,
                  color: Colors.white,
                ),
                label: Text(
                  'Join Interview Call',
                  style: AppTextStyles.buttonMedium.copyWith(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDecorations.radiusMd,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
