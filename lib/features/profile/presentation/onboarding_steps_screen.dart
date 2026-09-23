import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/pages/liveliness_page.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import '../../kyc/presentation/document_submission_screen.dart';
import '../profile_routes.dart';
import 'widgets/interview_schedule_sheet.dart';

/// Screen displaying the required setup and verification steps for providers
/// to become eligible to receive task offers.
///
/// Tracks 4 core setup steps:
/// 1. Face Capture (Live Selfie)
/// 2. Submit KYC Document (Government ID)
/// 3. Provide Professional Reference (Guarantor details)
/// 4. Online Interview (Video session)
class OnboardingStepsScreen extends ConsumerStatefulWidget {
  const OnboardingStepsScreen({super.key});

  @override
  ConsumerState<OnboardingStepsScreen> createState() =>
      _OnboardingStepsScreenState();
}

class _OnboardingStepsScreenState
    extends ConsumerState<OnboardingStepsScreen> {
  bool _selfieCompletedLocally = false;
  bool _docCompletedLocally = false;

  Future<void> _refreshData() async {
    ref.invalidate(userProvider);
    ref.invalidate(getKycStatusProvider);
    ref.invalidate(guarantorNotifierProvider);
    ref.invalidate(interviewProvider);

    try {
      await Future.wait([
        ref.read(userProvider.future),
        ref.read(getKycStatusProvider.future),
        ref.read(guarantorNotifierProvider.future),
        ref.read(interviewProvider.future),
      ]);
    } catch (_) {}
  }

  Future<void> _handleSelfieTap() async {
    final file = await LivelinessPage.check(context);
    if (file != null && mounted) {
      context.showLoading();
      try {
        final path = file.absolute.path;
        final lastDot = path.lastIndexOf('.');
        final targetPath = lastDot != -1
            ? '${path.substring(0, lastDot)}_compressed${path.substring(lastDot)}'
            : '${path}_compressed.jpg';

        final compressedXFile = await FlutterImageCompress.compressAndGetFile(
          path,
          targetPath,
          quality: 80,
        );

        final finalFile =
            compressedXFile != null ? File(compressedXFile.path) : file;

        if (mounted) {
          final userNotifier = ref.read(userProvider.notifier);
          String? error;

          await userNotifier.submitSelfie(
            finalFile,
            onSuccess: () {},
            onError: (err) {
              error = err;
            },
          );

          if (error != null) {
            if (mounted) {
              context.hideLoading();
              context.showError(error!);
            }
            return;
          }

          if (mounted) {
            setState(() {
              _selfieCompletedLocally = true;
            });
            context.hideLoading();
            context.showMessage(
              'Face capture submitted successfully!',
              title: 'Success',
            );
            _refreshData();
          }
        }
      } catch (e) {
        if (mounted) {
          context.hideLoading();
          context.showError(
            'An unexpected error occurred during face capture.',
          );
        }
      }
    }
  }

  Future<void> _handleDocumentTap() async {
    final result = await Navigator.push<DocumentSubmissionResult?>(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentSubmissionScreen(),
      ),
    );

    if (result != null && mounted) {
      context.showLoading();
      try {
        final userNotifier = ref.read(userProvider.notifier);
        String? error;

        await userNotifier.submitDocument(
          idType: result.idType,
          idNumber: result.idNumber,
          idDoc: result.file,
          onSuccess: () {},
          onError: (err) {
            error = err;
          },
        );

        if (error != null) {
          if (mounted) {
            context.hideLoading();
            context.showError(error!);
          }
          return;
        }

        if (mounted) {
          setState(() {
            _docCompletedLocally = true;
          });
          context.hideLoading();
          context.showMessage('KYC document submitted successfully!');
          _refreshData();
        }
      } catch (e) {
        if (mounted) {
          context.hideLoading();
          context.showError(
            'An unexpected error occurred during document submission.',
          );
        }
      }
    }
  }

  Future<void> _handleReferenceTap(VerificationStatus? status) async {
    await context.pushNamed(
      ProfileRoutes.guarantorRoute,
      queryParameters: status == VerificationStatus.failed
          ? {'is_resubmission': 'true'}
          : const <String, String>{},
    );
    _refreshData();
  }

  Future<void> _launchMeeting(String url) async {
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        context.showError('Could not open meeting link');
      }
    } catch (_) {
      if (mounted) {
        context.showError('Could not open meeting link');
      }
    }
  }

  void _handleInterviewTap(Interview? interview) {
    InterviewScheduleSheet.show(context, interview: interview);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasSelfieAsync = ref.watch(hasSelfieProvider);
    final kycDocAsync = ref.watch(getKycStatusProvider);
    final kycStatusAsync = ref.watch(kycStatusProvider);
    final guarantorAsync = ref.watch(guarantorProvider);
    final interviewAsync = ref.watch(interviewProvider);

    final hasSelfie = (hasSelfieAsync.value ?? false) || _selfieCompletedLocally;

    // KYC Document State
    final kycDoc = kycDocAsync.value;
    final kycEnum = kycDoc?.verificationStatus ??
        (kycStatusAsync.value == KycStatus.approved
            ? VerificationStatus.passed
            : kycStatusAsync.value == KycStatus.underReview ||
                    kycStatusAsync.value == KycStatus.submitted
                ? VerificationStatus.underReview
                : kycStatusAsync.value == KycStatus.rejected
                    ? VerificationStatus.failed
                    : VerificationStatus.pending);

    final isDocApproved = kycEnum == VerificationStatus.passed;
    final isDocSubmitted = _docCompletedLocally || kycEnum == VerificationStatus.underReview;
    final isDocFailed = kycEnum == VerificationStatus.failed;
    final docRejectionReason = kycDoc?.rejectionReason;

    // Guarantor / Reference State
    final guarantor = guarantorAsync.value;
    final guarantorStatus = guarantor?.verificationStatus;
    final isGuarantorPassed = guarantorStatus == VerificationStatus.passed;
    final isGuarantorFailed = guarantorStatus == VerificationStatus.failed;
    final isGuarantorUnderReview =
        (guarantor != null && !isGuarantorPassed && !isGuarantorFailed) ||
            guarantorStatus == VerificationStatus.underReview;

    // Interview State
    final interview = interviewAsync.value;
    final rawInterviewStatus = interview?.status?.toUpperCase().trim();
    final isInterviewPassed = rawInterviewStatus == 'PASSED' ||
        rawInterviewStatus == 'COMPLETED';
    final isInterviewScheduled = interview?.scheduledAt != null &&
        !isInterviewPassed &&
        rawInterviewStatus != 'CANCELLED' &&
        rawInterviewStatus != 'REJECTED';

    // Calculation for progress percentage (4 steps total)
    int completedCount = 0;
    if (hasSelfie) completedCount++;
    if (isDocApproved) {
      completedCount++;
    } else if (isDocSubmitted) {
      completedCount += 0; // pending review count
    }
    if (isGuarantorPassed) completedCount++;
    if (isInterviewPassed) completedCount++;

    final progress = (completedCount / 4.0).clamp(0.0, 1.0);
    final isInitialLoading =
        (hasSelfieAsync.isLoading && !hasSelfieAsync.hasValue) ||
        (kycDocAsync.isLoading && !kycDocAsync.hasValue) ||
        (guarantorAsync.isLoading && !guarantorAsync.hasValue) ||
        (interviewAsync.isLoading && !interviewAsync.hasValue);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: Text(
          'Account Setup & Eligibility',
          style: AppTextStyles.h3.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refreshData,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.h),
                Text(
                  'Complete your account onboarding to start receiving task offers from clients near you.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 16.h),

                // Progress Bar Card
                _buildProgressCard(isDark, progress, completedCount),
                SizedBox(height: 20.h),

                // Steps list
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      children: [
                        if (isInitialLoading) ...[
                          _buildShimmerStepCard(isDark),
                          SizedBox(height: 12.h),
                          _buildShimmerStepCard(isDark),
                          SizedBox(height: 12.h),
                          _buildShimmerStepCard(isDark),
                          SizedBox(height: 12.h),
                          _buildShimmerStepCard(isDark),
                        ] else ...[
                          // Step 1: Face Capture
                          _buildStepCard(
                            isDark: isDark,
                            stepNumber: 1,
                            icon: Icons.face_retouching_natural_rounded,
                            title: 'Face Capture',
                            description: hasSelfie
                                ? 'Your face capture verification is complete.'
                                : 'Take a live selfie to confirm your identity and prevent fraud.',
                            isCompleted: hasSelfie,
                            statusBadgeText: hasSelfie ? 'COMPLETED' : null,
                            onTap: hasSelfie ? null : _handleSelfieTap,
                          ),
                          SizedBox(height: 12.h),

                          // Step 2: KYC Document
                          _buildStepCard(
                            isDark: isDark,
                            stepNumber: 2,
                            icon: Icons.badge_rounded,
                            title: 'Submit KYC Document',
                            description: isDocApproved
                                ? 'Your government ID document has been verified.'
                                : isDocSubmitted
                                    ? 'Your ID document is currently under review.'
                                    : isDocFailed
                                        ? (docRejectionReason ??
                                            'Document verification failed. Tap to re-upload.')
                                        : 'Upload clear photo of your Passport, Driver\'s License, or National ID.',
                            isCompleted: isDocApproved,
                            isSubmitted: isDocSubmitted,
                            isRejected: isDocFailed,
                            statusBadgeText: isDocApproved
                                ? 'COMPLETED'
                                : isDocFailed
                                    ? 'REJECTED'
                                    : (isDocSubmitted ? 'UNDER REVIEW' : null),
                            onTap: (isDocApproved || isDocSubmitted)
                                ? null
                                : _handleDocumentTap,
                          ),
                          SizedBox(height: 12.h),

                          // Step 3: Professional Reference
                          _buildStepCard(
                            isDark: isDark,
                            stepNumber: 3,
                            icon: Icons.assignment_ind_rounded,
                            title: 'Provide Professional Reference',
                            description: isGuarantorPassed
                                ? 'Your professional reference has been verified.'
                                : isGuarantorUnderReview
                                    ? 'Reference details submitted and pending verification.'
                                    : isGuarantorFailed
                                        ? (guarantor?.failureReason ??
                                            'Reference verification failed. Tap to resubmit.')
                                        : 'Provide a trusted professional reference for background vetting.',
                            isCompleted: isGuarantorPassed,
                            isSubmitted: isGuarantorUnderReview,
                            isRejected: isGuarantorFailed,
                            statusBadgeText: isGuarantorPassed
                                ? 'COMPLETED'
                                : isGuarantorFailed
                                    ? 'ACTION NEEDED'
                                    : (isGuarantorUnderReview
                                        ? 'UNDER REVIEW'
                                        : null),
                            onTap: (isGuarantorPassed || isGuarantorUnderReview)
                                ? null
                                : () => _handleReferenceTap(guarantorStatus),
                          ),
                          SizedBox(height: 12.h),

                          // Step 4: Online Interview
                          _buildStepCard(
                            isDark: isDark,
                            stepNumber: 4,
                            icon: Icons.video_camera_front_rounded,
                            title: 'Online Interview',
                            description: isInterviewPassed
                                ? 'Online interview completed successfully.'
                                : isInterviewScheduled
                                    ? 'Scheduled for ${DateFormat.yMMMd().add_jm().format(interview!.scheduledAt!)}'
                                    : 'A brief video call interview with our team to finalize eligibility.',
                            isCompleted: isInterviewPassed,
                            isSubmitted: isInterviewScheduled,
                            statusBadgeText: isInterviewPassed
                                ? 'COMPLETED'
                                : isInterviewScheduled
                                    ? 'SCHEDULED'
                                    : null,
                            customBottomWidget: (isInterviewScheduled &&
                                    interview?.meetingLink != null &&
                                    interview!.meetingLink!.trim().isNotEmpty)
                                ? Padding(
                                    padding: EdgeInsets.only(top: 10.h),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _launchMeeting(
                                          interview.meetingLink!,
                                        ),
                                        icon: Icon(
                                          Icons.video_call_rounded,
                                          size: 16.r,
                                          color: AppColors.primary,
                                        ),
                                        label: Text(
                                          'Join Interview Call',
                                          style: AppTextStyles.buttonMedium
                                              .copyWith(
                                            fontSize: 12.sp,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.primary,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6.h,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                            onTap: () => _handleInterviewTap(interview),
                          ),
                        ],
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    bool isDark,
    double progress,
    int completedCount,
  ) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).toInt();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppDecorations.radiusLg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1.2.r,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
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
                'Setup Progress',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$completedCount of 4 Steps Completed',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: Stack(
                    children: [
                      Container(
                        height: 8.h,
                        color: isDark ? AppColors.border : Colors.grey[200]!,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                        height: 8.h,
                        width: (MediaQuery.of(context).size.width - 72.w) *
                            progress,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '$percentage%',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required bool isDark,
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
    bool isCompleted = false,
    bool isSubmitted = false,
    bool isRejected = false,
    String? statusBadgeText,
    Widget? customBottomWidget,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isActive = !isCompleted && !isSubmitted && !isRejected;

    final Color stateColor = isCompleted
        ? AppColors.success
        : isRejected
            ? AppColors.error
            : isSubmitted
                ? AppColors.warning
                : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: onTap != null ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(
            color: (isCompleted || isRejected || isSubmitted)
                ? stateColor.withValues(alpha: 0.4)
                : isActive
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border,
            width: 1.2.r,
          ),
          boxShadow: [
            BoxShadow(
              color: stateColor.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: stateColor.withValues(
                      alpha: (isCompleted || isRejected || isSubmitted)
                          ? 0.14
                          : 0.08,
                    ),
                    borderRadius: AppDecorations.radiusMd,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle_rounded : icon,
                    color: stateColor,
                    size: 22.r,
                  ),
                ),
                SizedBox(width: 12.w),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Step $stepNumber',
                            style: AppTextStyles.labelUppercase.copyWith(
                              color: stateColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (statusBadgeText != null) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: stateColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                statusBadgeText,
                                style: AppTextStyles.labelUppercase.copyWith(
                                  color: stateColor,
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        title,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isRejected
                              ? AppColors.error
                              : AppColors.textMuted,
                          fontSize: 11.5.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action chevron
                if (onTap != null) ...[
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 22.r,
                  ),
                ],
              ],
            ),
            ?customBottomWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerStepCard(bool isDark) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surface;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(color: AppColors.border, width: 1.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.radiusMd,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 50.w, height: 10.h, color: Colors.white),
                  SizedBox(height: 6.h),
                  Container(width: 120.w, height: 14.h, color: Colors.white),
                  SizedBox(height: 6.h),
                  Container(
                      width: double.infinity,
                      height: 10.h,
                      color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
