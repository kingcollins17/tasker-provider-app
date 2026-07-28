import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/pages/liveliness_page.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/providers/user_provider.dart';
import 'document_submission_screen.dart';

/// KYC onboarding screen showing the required verification steps.
///
/// Guides users through two steps:
/// 1. Selfie verification via [LivelinessPage]
/// 2. ID document submission via [DocumentSubmissionScreen]
class KycOnboardingScreen extends ConsumerStatefulWidget {
  const KycOnboardingScreen({super.key});

  @override
  ConsumerState<KycOnboardingScreen> createState() =>
      _KycOnboardingScreenState();
}

class _KycOnboardingScreenState extends ConsumerState<KycOnboardingScreen>
    with SingleTickerProviderStateMixin {
  bool _selfieCompleted = false;
  bool _documentCompleted = false;

  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
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

        final finalFile = compressedXFile != null
            ? File(compressedXFile.path)
            : file;

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
              _selfieCompleted = true;
            });
            context.hideLoading();
            context.showMessage(
              'Selfie submitted successfully!',
              title: 'Success',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          context.hideLoading();
          context.showError(
            'An unexpected error occurred during selfie verification.',
          );
        }
      }
    }
  }

  Future<void> _handleDocumentTap() async {
    final result = await Navigator.push<DocumentSubmissionResult?>(
      context,
      MaterialPageRoute(builder: (context) => const DocumentSubmissionScreen()),
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
            _documentCompleted = true;
          });
          context.hideLoading();
          context.showMessage(
            'ID Document submitted successfully!',
            // title: 'Success',
          );
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

  void _submitKyc(bool hasSelfie, KycStatus status) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      context.go('/');
    }
  }

  void _handleContinue(bool hasSelfie, KycStatus status) {
    final selfieDone = _selfieCompleted || hasSelfie;
    final documentDone = _documentCompleted || status == KycStatus.approved;

    if (!selfieDone && !documentDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete both verification steps to continue.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    if (!selfieDone) {
      _handleSelfieTap();
      return;
    }

    if (!documentDone) {
      _handleDocumentTap();
      return;
    }

    // Both completed — perform submission
    _submitKyc(hasSelfie, status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasSelfieAsync = ref.watch(hasSelfieProvider);
    final kycStatusAsync = ref.watch(kycStatusProvider);
    final docRejectionReasonAsync = ref.watch(documentRejectionReasonProvider);

    final hasSelfie = hasSelfieAsync.value ?? false;
    final kycStatus = kycStatusAsync.value ?? KycStatus.pending;

    final isSelfieDone = _selfieCompleted || hasSelfie;
    final isDocumentApproved = kycStatus == KycStatus.approved;
    final isDocumentSubmitted =
        _documentCompleted ||
        kycStatus == KycStatus.submitted ||
        kycStatus == KycStatus.underReview;
    final isDocumentRejected = kycStatus == KycStatus.rejected;

    final double selfieProgress = isSelfieDone ? 1.0 : 0.0;
    double documentProgress = 0.0;
    if (isDocumentApproved) {
      documentProgress = 1.0;
    } else if (kycStatus == KycStatus.underReview) {
      documentProgress = 0.5;
    } else if (_documentCompleted || kycStatus == KycStatus.submitted) {
      documentProgress = 0.25;
    }
    final progress = (selfieProgress + documentProgress) / 2.0;

    final isLoading = hasSelfieAsync.isLoading || kycStatusAsync.isLoading;

    final hideButton = isLoading || (isSelfieDone && (
        kycStatus == KycStatus.submitted ||
        kycStatus == KycStatus.underReview ||
        kycStatus == KycStatus.approved ||
        _documentCompleted
    ));

    final String buttonText;
    final IconData buttonIcon;
    final VoidCallback buttonAction;

    if (!isSelfieDone) {
      buttonText = 'Capture Selfie';
      buttonIcon = Icons.face_retouching_natural_rounded;
      buttonAction = _handleSelfieTap;
    } else if (kycStatus == KycStatus.rejected) {
      buttonText = 'Reupload Document';
      buttonIcon = Icons.refresh_rounded;
      buttonAction = _handleDocumentTap;
    } else if (kycStatus == KycStatus.pending && !_documentCompleted) {
      buttonText = 'Submit ID Document';
      buttonIcon = Icons.badge_rounded;
      buttonAction = _handleDocumentTap;
    } else {
      buttonText = 'Continue';
      buttonIcon = Icons.arrow_forward_rounded;
      buttonAction = () => _handleContinue(hasSelfie, kycStatus);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h),

              // Title
              Text(
                'Identity Verification',
                style:
                    (theme.textTheme.titleLarge?.copyWith(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    )) ??
                    AppTextStyles.h2.copyWith(fontSize: 28.sp),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'Complete the steps below to verify your identity and unlock full access.',
                style:
                    (theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    )) ??
                    AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 24.h),

              // Progress bar
              _buildProgressIndicator(isDark, progress),
              SizedBox(height: 32.h),

              // Steps
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      if (isLoading) ...[
                        _buildShimmerStepCard(isDark, theme),
                        SizedBox(height: 16.h),
                        _buildShimmerStepCard(isDark, theme),
                      ] else ...[
                        _buildStepCard(
                          isDark: isDark,
                          stepNumber: 1,
                          icon: Icons.face_retouching_natural_rounded,
                          title: 'Selfie Verification',
                          description: isSelfieDone
                              ? 'Your selfie has been successfully verified.'
                              : 'Take a live selfie to confirm your identity. Our AI will verify you\'re a real person.',
                          isCompleted: isSelfieDone,
                          statusBadgeText: isSelfieDone ? 'COMPLETED' : null,
                          onTap: isSelfieDone ? null : _handleSelfieTap,
                        ),
                        SizedBox(height: 16.h),
                        _buildStepCard(
                          isDark: isDark,
                          stepNumber: 2,
                          icon: Icons.badge_rounded,
                          title: 'Submit ID Document',
                          description: isDocumentApproved
                              ? 'Your government-issued ID document has been verified and approved.'
                              : isDocumentSubmitted
                              ? 'Your ID document is under review. This usually takes less than 24 hours.'
                              : isDocumentRejected
                              ? (docRejectionReasonAsync.value ??
                                    'Your ID document verification was rejected. Please re-submit.')
                              : 'Upload a clear photo of your government-issued ID (passport, driver\'s licence, or national ID).',
                          isCompleted: isDocumentApproved,
                          isSubmitted: isDocumentSubmitted,
                          isRejected: isDocumentRejected,
                          statusBadgeText: isDocumentApproved
                              ? 'COMPLETED'
                              : isDocumentRejected
                              ? 'REJECTED'
                              : (kycStatus == KycStatus.underReview
                                    ? 'UNDER REVIEW'
                                    : (isDocumentSubmitted ? 'SUBMITTED' : null)),
                          onTap: (isDocumentApproved || isDocumentSubmitted)
                              ? null
                              : _handleDocumentTap,
                        ),
                      ],
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),

              // Continue button
              if (!hideButton)
                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: PrimaryButton(
                    text: buttonText,
                    onPressed: buttonAction,
                    icon: buttonIcon,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Verification Progress',
              style: AppTextStyles.label.copyWith(
                color: isDark ? AppColors.textMuted : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Stack(
            children: [
              // Track
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              // Fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                height: 8.h,
                width: (MediaQuery.of(context).size.width - 48.w) * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8.r,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(
            color: (isCompleted || isRejected || isSubmitted)
                ? stateColor.withValues(alpha: 0.5)
                : isActive
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
            width: (isCompleted || isRejected || isSubmitted || isActive)
                ? 1.5.r
                : 1.r,
          ),
          boxShadow: [
            BoxShadow(
              color: stateColor.withValues(
                alpha: (isCompleted || isRejected || isSubmitted) ? 0.06 : 0.08,
              ),
              blurRadius: (isCompleted || isRejected || isSubmitted)
                  ? 16.r
                  : 20.r,
              offset: (isCompleted || isRejected || isSubmitted)
                  ? const Offset(0, 4)
                  : const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: stateColor.withValues(
                  alpha: (isCompleted || isRejected || isSubmitted)
                      ? 0.15
                      : 0.1,
                ),
                borderRadius: AppDecorations.radiusMd,
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : icon,
                color: stateColor,
                size: 28.r,
              ),
            ),
            SizedBox(width: 16.w),

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
                        ),
                      ),
                      if (statusBadgeText != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: stateColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            statusBadgeText,
                            style: AppTextStyles.labelUppercase.copyWith(
                              color: stateColor,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isRejected
                          ? AppColors.error
                          : isDark
                          ? AppColors.textMuted
                          : AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron / check
            SizedBox(width: 8.w),
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : isRejected
                  ? Icons.error_outline_rounded
                  : isSubmitted
                  ? Icons.schedule_rounded
                  : Icons.chevron_right_rounded,
              color: (isCompleted || isRejected || isSubmitted)
                  ? stateColor
                  : AppColors.textMuted,
              size: 24.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerStepCard(bool isDark, ThemeData theme) {
    final baseColor = Theme.of(context).colorScheme.surface;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(
            color: isDark ? AppColors.border : Colors.grey[300]!,
            width: 1.r,
          ),
        ),
        child: Row(
          children: [
            // Icon placeholder
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.radiusMd,
              ),
            ),
            SizedBox(width: 16.w),

            // Content placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50.w,
                    height: 10.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 120.w,
                    height: 16.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    height: 12.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 180.w,
                    height: 12.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
