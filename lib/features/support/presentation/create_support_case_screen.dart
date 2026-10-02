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

class SupportCategoryOption {
  final String code;
  final String title;
  final String description;
  final IconData icon;

  const SupportCategoryOption({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
  });
}

const List<SupportCategoryOption> _supportCategories = [
  SupportCategoryOption(
    code: 'GENERAL',
    title: 'General Inquiry',
    description:
        'General questions about tasker features, services, or policies.',
    icon: Icons.help_outline_rounded,
  ),
  SupportCategoryOption(
    code: 'DISPUTE',
    title: 'Task Dispute',
    description:
        'Disagreements regarding completed tasks, cancellations, or ratings.',
    icon: Icons.gavel_rounded,
  ),
  SupportCategoryOption(
    code: 'PAYMENT',
    title: 'Payment & Payout',
    description:
        'Issues with task earnings, bank payouts, or transaction errors.',
    icon: Icons.payments_rounded,
  ),
  SupportCategoryOption(
    code: 'TASK_ISSUE',
    title: 'Task Issue',
    description:
        'Problems during active task execution or client communication.',
    icon: Icons.assignment_late_rounded,
  ),
  SupportCategoryOption(
    code: 'ACCOUNT',
    title: 'Account & Verification',
    description:
        'ID verification, profile updates, or account login assistance.',
    icon: Icons.manage_accounts_rounded,
  ),
  SupportCategoryOption(
    code: 'TECHNICAL',
    title: 'Technical Bug',
    description:
        'App crashes, freeze errors, or unexpected functional glitches.',
    icon: Icons.build_circle_rounded,
  ),
  SupportCategoryOption(
    code: 'OTHER',
    title: 'Other Request',
    description: 'Any other inquiries or feedback not listed above.',
    icon: Icons.more_horiz_rounded,
  ),
];

class CreateSupportCaseScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final String? assignmentId;
  final String? payoutId;
  final String? initialType;

  const CreateSupportCaseScreen({
    super.key,
    this.taskId,
    this.assignmentId,
    this.payoutId,
    this.initialType,
  });

  @override
  ConsumerState<CreateSupportCaseScreen> createState() =>
      _CreateSupportCaseScreenState();
}

class _CreateSupportCaseScreenState
    extends ConsumerState<CreateSupportCaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _subjectController;
  late final TextEditingController _descriptionController;

  late String _selectedType;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _subjectController = TextEditingController();
    _descriptionController = TextEditingController();

    final validTypes = _supportCategories.map((c) => c.code).toList();
    if (widget.initialType != null &&
        validTypes.contains(widget.initialType!.toUpperCase().trim())) {
      _selectedType = widget.initialType!.toUpperCase().trim();
    } else {
      _selectedType = 'GENERAL';
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentStep = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _tabController.animateTo(step);
  }

  void _submitCase() {
    if (!_formKey.currentState!.validate()) return;

    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    context.showLoading(null, 'Creating support ticket...');

    ref
        .read(customerSupportNotifierProvider(null).notifier)
        .createCase(
          CreateSupportCaseRequest(
            subject: subject,
            description: description,
            type: _selectedType,
            taskId: widget.taskId,
            assignmentId: widget.assignmentId,
            payoutId: widget.payoutId,
          ),
          onSuccess: () {
            if (mounted) {
              context.hideLoading();
              context.showMessage(
                'Support ticket created successfully!',
                title: 'Success',
                onComplete: () {
                  context.pop();
                },
              );
            }
          },
          onError: (err) {
            if (mounted) {
              context.hideLoading();
              context.showError(err);
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          'Create Support Ticket',
          style: AppTextStyles.h3.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 6.h),
            // Custom 2-step Progress Header TabBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildStepTabHeader(isDark),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCategorySelectionTab(isDark),
                  _buildTicketDetailsTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTabHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.grey[100]!,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: isDark ? 0.3 : 0.6),
          width: 1.r,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildHeaderTabTile(
              stepIndex: 0,
              stepLabel: '1. Category',
              isActive: _currentStep == 0,
              isCompleted: _currentStep > 0,
              isDark: isDark,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _buildHeaderTabTile(
              stepIndex: 1,
              stepLabel: '2. Details',
              isActive: _currentStep == 1,
              isCompleted: false,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTabTile({
    required int stepIndex,
    required String stepLabel,
    required bool isActive,
    required bool isCompleted,
    required bool isDark,
  }) {
    final activeBg = isDark ? AppColors.surface : Colors.white;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? AppColors.textMuted : Colors.grey[600]!;

    return GestureDetector(
      onTap: () {
        if (stepIndex == 1 && _selectedType.isEmpty) return;
        _goToStep(stepIndex);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(9.r),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 4.r,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : (stepIndex == 0
                        ? Icons.grid_view_rounded
                        : Icons.edit_note_rounded),
              size: 15.r,
              color: isActive || isCompleted ? activeColor : inactiveColor,
            ),
            SizedBox(width: 5.w),
            Text(
              stepLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive || isCompleted
                    ? (isDark ? AppColors.textPrimary : const Color(0xFF0F172A))
                    : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionTab(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you need help with?',
            style: AppTextStyles.h3.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Select the request category that best matches your issue.',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _supportCategories.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final category = _supportCategories[index];
                final isSelected = _selectedType == category.code;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = category.code;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? (isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : Theme.of(context).colorScheme.surface)
                          : (isSelected
                                ? AppColors.primary.withValues(alpha: 0.06)
                                : Colors.white),
                      borderRadius: AppDecorations.radiusLg,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border.withValues(alpha: 0.6),
                        width: isSelected ? 1.5.r : 1.r,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: isDark ? 0.15 : 0.08,
                                ),
                                blurRadius: 6.r,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppDecorations.radiusMd,
                          ),
                          child: Icon(
                            category.icon,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                            size: 18.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                category.description,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11.sp,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Radio<String>(
                          value: category.code,
                          groupValue: _selectedType,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedType = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          PrimaryButton(
            text: 'Continue',
           
            onPressed: () => _goToStep(1),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildTicketDetailsTab(bool isDark) {
    final selectedCategory = _supportCategories.firstWhere(
      (c) => c.code == _selectedType,
      orElse: () => _supportCategories.first,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected Category Summary Card
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: AppDecorations.radiusMd,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.r,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedCategory.icon,
                            color: AppColors.primary,
                            size: 18.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Category: ${selectedCategory.title}',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5.sp,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Code: $_selectedType',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 10.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _goToStep(0),
                            icon: Icon(Icons.edit_rounded, size: 13.r),
                            label: Text(
                              'Change',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Subject Input
                    AppTextField(
                      controller: _subjectController,
                      label: 'Subject',
                      hintText:
                          'Brief summary of your request (e.g. Delayed payout)',
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject for your ticket';
                        }
                        if (value.trim().length < 4) {
                          return 'Subject must be at least 4 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Description Input
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hintText:
                          'Provide detailed information about the issue to help us resolve it quickly...',
                      minLines: 3,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a detailed description';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Submit Button docked at bottom
            PrimaryButton(
              text: 'Request Support',
              onPressed: _submitCase,
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
