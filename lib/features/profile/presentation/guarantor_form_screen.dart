import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';

class GuarantorFormScreen extends ConsumerStatefulWidget {
  final bool isResubmission;

  const GuarantorFormScreen({super.key, this.isResubmission = false});

  @override
  ConsumerState<GuarantorFormScreen> createState() =>
      _GuarantorFormScreenState();
}

class _GuarantorFormScreenState extends ConsumerState<GuarantorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _relationshipController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _relationshipController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _populateFormIfEmpty(Guarantor? guarantor) {
    if (guarantor == null) return;
    if (_nameController.text.isEmpty && guarantor.guarantorName != null) {
      _nameController.text = guarantor.guarantorName!;
    }
    if (_phoneController.text.isEmpty && guarantor.guarantorPhone != null) {
      String phone = guarantor.guarantorPhone!;
      if (phone.startsWith('+234')) {
        phone = phone.substring(4);
      } else if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }
      _phoneController.text = phone;
    }
    if (_relationshipController.text.isEmpty &&
        guarantor.relationship != null) {
      _relationshipController.text = guarantor.relationship!;
    }
  }

  void _submitForm(bool isResubmitting) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    final relationship = _relationshipController.text.trim();

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    if (!phone.startsWith('+234')) {
      phone = '+234$phone';
    }

    final request = GuarantorRequest(
      guarantorName: name,
      guarantorPhone: phone,
      relationship: relationship.isNotEmpty ? relationship : null,
    );

    context.showLoading(
      null,
      isResubmitting ? 'Resubmitting details...' : 'Submitting details...',
    );

    final notifier = ref.read(guarantorNotifierProvider.notifier);

    if (isResubmitting) {
      notifier.resubmitGuarantor(
        request,
        onSuccess: () {
          if (!mounted) return;
          context.hideLoading();
          context.showInfo(
            'Professional reference resubmitted successfully!',
            onComplete: () {
              context.pop();
            },
          );
          setState(() {
            _isEditing = false;
          });
        },
        onError: (err) {
          if (!mounted) return;
          context.hideLoading();
          context.showError(err);
        },
      );
    } else {
      notifier.submitGuarantor(
        request,
        onSuccess: () {
          if (!mounted) return;
          context.hideLoading();
          context.showInfo('Professional reference submitted successfully!');
          setState(() {
            _isEditing = false;
          });
        },
        onError: (err) {
          if (!mounted) return;
          context.hideLoading();
          context.showError(err);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final guarantorAsync = ref.watch(guarantorNotifierProvider);

    guarantorAsync.whenData((guarantor) {
      _populateFormIfEmpty(guarantor);
    });

    final guarantor = guarantorAsync.value;
    final status = guarantor?.verificationStatus;
    final isFailed = status == VerificationStatus.failed;
    final isResubmitting = widget.isResubmission || isFailed || _isEditing;

    Widget? bottomBar;

    if (!guarantorAsync.isLoading) {
      if (guarantor != null && !isResubmitting) {
        if (isFailed) {
          bottomBar = Container(
            padding: EdgeInsets.only(
              left: 16.r,
              right: 16.r,
              top: 12.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.r,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                  width: 1.r,
                ),
              ),
            ),
            child: SafeArea(
              child: PrimaryButton(
                text: 'Resubmit Reference',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            ),
          );
        }
      } else {
        final resubmitting = isResubmitting || (guarantor != null);
        bottomBar = Container(
          padding: EdgeInsets.only(
            left: 16.r,
            right: 16.r,
            top: 12.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.r,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                width: 1.r,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  text: resubmitting
                      ? 'Resubmit Guarantor Form'
                      : 'Submit Guarantor Form',
                  icon: resubmitting
                      ? Icons.refresh_rounded
                      : Icons.send_rounded,
                  onPressed: () => _submitForm(resubmitting),
                ),
                if (_isEditing) ...[
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                    },
                    child: Text(
                      'Cancel Editing',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        centerTitle: true,
        title: Text(
          'Professional Reference',
          style: AppTextStyles.h3.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: guarantorAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: _buildForm(
              context,
              isDark,
              isResubmitting: widget.isResubmission,
            ),
          ),
          data: (guarantor) {
            if (guarantor != null && !isResubmitting) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusCard(context, guarantor, isDark),
                    SizedBox(height: 24.h),
                    _buildGuarantorDetailsCard(context, guarantor, isDark),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (guarantor != null && isFailed) ...[
                    _buildStatusCard(context, guarantor, isDark),
                    SizedBox(height: 20.h),
                  ],
                  _buildForm(
                    context,
                    isDark,
                    isResubmitting: isResubmitting || (guarantor != null),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }

  Widget _buildForm(
    BuildContext context,
    bool isDark, {
    required bool isResubmitting,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info banner
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: AppDecorations.radiusMd,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.r,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_pin_rounded,
                  color: AppColors.primary,
                  size: 22.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    isResubmitting
                        ? 'Update your guarantor details to request a new verification review.'
                        : 'Provide details of a trusted professional reference or guarantor to verify your profile.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Guarantor Full Name
          AppTextField(
            controller: _nameController,
            label: 'Guarantor Full Name',
            hintText: 'e.g. Dr. Samuel Vance',
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: AppColors.textMuted,
              size: 18.r,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter the guarantor\'s full name';
              }
              if (val.trim().split(' ').length < 2) {
                return 'Please enter first and last name';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Guarantor Phone Number
          AppTextField(
            controller: _phoneController,
            label: 'Guarantor Phone Number',
            hintText: '8012345678',
            keyboardType: TextInputType.phone,
            maxLength: 10,
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w, right: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🇳🇬 +234',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 1.w,
                    height: 16.h,
                    color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                  ),
                ],
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter the guarantor\'s phone number';
              }
              final clean = val.trim().replaceAll(RegExp(r'\D'), '');
              if (clean.length < 10) {
                return 'Enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Relationship / Designation
          AppTextField(
            controller: _relationshipController,
            label: 'Relationship / Role',
            hintText: 'e.g. Former Manager, Mentor, Colleague',
            prefixIcon: Icon(
              Icons.work_outline_rounded,
              color: AppColors.textMuted,
              size: 18.r,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please specify your relationship with the guarantor';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    Guarantor guarantor,
    bool isDark,
  ) {
    final status = guarantor.verificationStatus;

    final Color statusColor;
    final IconData statusIcon;
    final String title;
    final String description;

    switch (status) {
      case VerificationStatus.passed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_rounded;
        title = 'Guarantor Verified';
        description =
            'Your professional reference has been verified and approved.';
        break;
      case VerificationStatus.failed:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        title = 'Verification Failed';
        description =
            guarantor.failureReason ??
            'Verification of your reference was not successful. Please review details and resubmit.';
        break;
      case VerificationStatus.underReview:
        statusColor = AppColors.warning;
        statusIcon = Icons.pending_actions_rounded;
        title = 'Under Review';
        description =
            'Your guarantor information is currently being reviewed by our verification team.';
        break;
      case VerificationStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_empty_rounded;
        title = 'Pending Verification';
        description =
            'Your guarantor submission has been received and is waiting for verification.';
        break;
    }

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surface
            : statusColor.withValues(alpha: 0.06),
        borderRadius: AppDecorations.radiusLg,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.2.r,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 14.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 16.sp,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      status.label,
                      style: AppTextStyles.label.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: statusColor.withValues(alpha: 0.2), height: 1.h),
          SizedBox(height: 12.h),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textPrimary : const Color(0xFF334155),
              fontSize: 12.5.sp,
              height: 1.4,
            ),
          ),
          if (status == VerificationStatus.failed &&
              guarantor.failureReason != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppDecorations.radiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.error,
                    size: 16.r,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Reason: ${guarantor.failureReason}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuarantorDetailsCard(
    BuildContext context,
    Guarantor guarantor,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppDecorations.radiusLg,
        border: Border.all(
          color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
          width: 1.r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SUBMITTED REFERENCE',
                style: AppTextStyles.labelUppercase.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11.sp,
                  letterSpacing: 0.8,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                icon: Icon(
                  Icons.edit_outlined,
                  size: 18.r,
                  color: AppColors.primary,
                ),
                tooltip: 'Edit details',
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildDetailRow(
            icon: Icons.person_rounded,
            label: 'Guarantor Name',
            value: guarantor.guarantorName ?? 'N/A',
            isDark: isDark,
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.phone_rounded,
            label: 'Phone Number',
            value: guarantor.guarantorPhone ?? 'N/A',
            isDark: isDark,
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.work_rounded,
            label: 'Relationship / Role',
            value: guarantor.relationship ?? 'N/A',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: AppDecorations.radiusSm,
          ),
          child: Icon(icon, color: AppColors.primary, size: 16.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5.sp,
                  color: isDark
                      ? AppColors.textPrimary
                      : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
