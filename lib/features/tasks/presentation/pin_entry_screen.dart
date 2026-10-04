import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tasker_app/core/providers/payments_provider.dart';
import 'package:tasker_app/core/providers/tasks_provider.dart';
import 'package:tasker_app/core/providers/user_provider.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';

class PinEntryScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final String? mode;
  final bool? isInitialCash;

  const PinEntryScreen({super.key, this.taskId, this.mode, this.isInitialCash});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _pin = '';
  late bool _isCash;

  @override
  void initState() {
    super.initState();
    _isCash = widget.isInitialCash ?? true;
    _controller.addListener(() {
      setState(() {
        _pin = _controller.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pin.length != 4) return;

    final taskId = widget.taskId;
    if (taskId == null || taskId.isEmpty) {
      context.showError('Invalid task ID');
      return;
    }

    final mode = widget.mode ?? 'startPin';
    context.showLoading();

    if (mode == 'startPin') {
      await ref
          .read(taskManagementProvider.notifier)
          .startTask(
            taskId,
            pin: _pin,
            onSuccess: () {
              context.hideLoading();
              ref.invalidate(taskDetailProvider(taskId));
              ref.invalidate(taskAssignmentProvider(taskId));
              context.pop();
            },
            onError: (errorMsg) {
              context.hideLoading();
              context.showError(errorMsg);
            },
          );
    } else if (mode == 'completePin') {
      final maxThreshold = ref.read(maxDebtThresholdProvider);
      final debtAsync = ref.read(debtSummaryProvider);
      final userDebt = debtAsync.value?.totalDebtOwed ?? 0.0;
      final isCashDisabled = userDebt >= (maxThreshold - 500.0);

      final user = ref.read(userProvider).value;
      final isOnlineDisabled = user?.paymentAccount == null;

      if (isCashDisabled && isOnlineDisabled) {
        context.hideLoading();
        context.showError(
          'Cannot complete task: Cash payment is unavailable due to debt limit and Online payment requires a payment account.',
        );
        return;
      }

      String paymentMode;
      if (isCashDisabled) {
        paymentMode = 'ONLINE';
      } else if (isOnlineDisabled) {
        paymentMode = 'CASH';
      } else {
        paymentMode = _isCash ? 'CASH' : 'ONLINE';
      }
      await ref
          .read(taskManagementProvider.notifier)
          .completeTask(
            taskId,
            pin: _pin,
            paymentMode: paymentMode,
            onSuccess: () {
              context.hideLoading();
              ref.invalidate(taskDetailProvider(taskId));
              ref.invalidate(taskAssignmentProvider(taskId));
              context.pop();
            },
            onError: (errorMsg) {
              context.hideLoading();
              context.showError(errorMsg);
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final mode = widget.mode ?? 'startPin';
    final isCompleteMode = mode == 'completePin';

    final maxThreshold = ref.watch(maxDebtThresholdProvider);
    final debtAsync = ref.watch(debtSummaryProvider);
    final userDebt = debtAsync.value?.totalDebtOwed ?? 0.0;

    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;
    final isOnlineDisabled = user?.paymentAccount == null;

    // Cash option disabled if debt >= maxThreshold or difference is within 500 of maxThreshold
    final isCashDisabled = userDebt >= (maxThreshold - 500.0);

    final bool isCashSelected;
    final bool isOnlineSelected;
    if (isCashDisabled && isOnlineDisabled) {
      isCashSelected = false;
      isOnlineSelected = false;
    } else if (isCashDisabled) {
      isCashSelected = false;
      isOnlineSelected = true;
    } else if (isOnlineDisabled) {
      isCashSelected = true;
      isOnlineSelected = false;
    } else {
      isCashSelected = _isCash;
      isOnlineSelected = !_isCash;
    }

    final displayTitle = isCompleteMode
        ? 'Enter Completion PIN'
        : 'Enter Start PIN';
    final displaySubtitle = isCompleteMode
        ? 'Please enter the 4-digit PIN provided by the customer and select the payment mode.'
        : 'Please enter the 4-digit PIN provided by the customer to start this task.';
    final displayConfirmButtonText = isCompleteMode
        ? 'Complete Task'
        : 'Start Task';
    final displayIcon = isCompleteMode
        ? Icons.check_circle_rounded
        : Icons.play_circle_fill_rounded;
    final displayShowPaymentMode = isCompleteMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - AppBar().preferredSize.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: 32.h),

                      // Icon Badge
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            displayIcon,
                            color: AppColors.primary,
                            size: 36.r,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        displayTitle,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 22.sp,
                          color: isDark
                              ? AppColors.textPrimary
                              : const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),

                      // Subtitle
                      Text(
                        displaySubtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40.h),

                      // 4 Box PIN Display (Tap to focus hidden input)
                      GestureDetector(
                        onTap: () {
                          _focusNode.requestFocus();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          children: [
                            // Hidden TextField capturing input
                            Opacity(
                              opacity: 0.0,
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(4),
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onSubmitted: (_) => _submit(),
                              ),
                            ),

                            // 4 Digit Boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(4, (index) {
                                final isFilled = index < _pin.length;
                                final isCurrentFocus =
                                    index == _pin.length && _focusNode.hasFocus;
                                final char = isFilled ? _pin[index] : '';

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 64.r,
                                  height: 70.r,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: isCurrentFocus
                                          ? AppColors.primary
                                          : (isFilled
                                                ? AppColors.primary.withValues(
                                                    alpha: 0.5,
                                                  )
                                                : (isDark
                                                    ? AppColors.border
                                                    : const Color(0xFFE2E8F0))),
                                      width: isCurrentFocus ? 2.r : 1.r,
                                    ),
                                    boxShadow: isCurrentFocus
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 12.r,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      char,
                                      style: AppTextStyles.h1.copyWith(
                                        fontSize: 28.sp,
                                        color: isDark
                                            ? AppColors.textPrimary
                                            : const Color(0xFF0F172A),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      // Optional Payment Mode Selector (when showPaymentMode is true)
                      if (displayShowPaymentMode) ...[
                        SizedBox(height: 40.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Payment Settlement Mode',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _PaymentModeCard(
                                title: 'Cash',
                                subtitle: 'Direct cash',
                                icon: Icons.payments_outlined,
                                isSelected: isCashSelected,
                                isDisabled: isCashDisabled,
                                disabledSubtitle: 'Limit reached',
                                onTap: () => setState(() => _isCash = true),
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _PaymentModeCard(
                                title: 'Online',
                                subtitle: 'Electronic',
                                icon: Icons.credit_card_rounded,
                                isSelected: isOnlineSelected,
                                isDisabled: isOnlineDisabled,
                                disabledSubtitle: 'No account',
                                onTap: () => setState(() => _isCash = false),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        if (isCashDisabled || isOnlineDisabled) ...[
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 16.r,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    isCashDisabled && isOnlineDisabled
                                        ? 'Both payment options are disabled. Cash settlement is unavailable due to your debt limit (${userDebt.toNaira(2)}), and Online settlement is unavailable because no payment account has been added.'
                                        : isCashDisabled
                                            ? 'Cash settlement is disabled because your debt (${userDebt.toNaira(2)}) is close to or above the ${maxThreshold.toNaira(0)} threshold limit. Online settlement is required to deduct debt from payout.'
                                            : 'Online settlement is disabled because you have no payment account added. Payments cannot be disbursed to you electronically without a payment account.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondary
                                          : const Color(0xFF0F172A),
                                      fontSize: 11.5.sp,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],

                      const Spacer(),
                      SizedBox(height: 32.h),

                      // Submit Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _pin.length == 4 ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.35),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            elevation: _pin.length == 4 ? 4 : 0,
                          ),
                          child: Text(
                            displayConfirmButtonText,
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PaymentModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDisabled;
  final String? disabledSubtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _PaymentModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    this.isDisabled = false,
    this.disabledSubtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDisabled
        ? (isDark
            ? AppColors.border.withValues(alpha: 0.3)
            : Colors.grey.shade300)
        : (isSelected
            ? AppColors.primary
            : (isDark ? AppColors.border : const Color(0xFFE2E8F0)));

    final bgColor = isDisabled
        ? (isDark
            ? Colors.white.withValues(alpha: 0.02)
            : Colors.grey.shade100)
        : (isSelected
            ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
            : (isDark
                ? Colors.white.withValues(alpha: 0.03)
                : const Color(0xFFF8FAFC)));

    final iconColor = isDisabled
        ? (isDark
            ? AppColors.textMuted.withValues(alpha: 0.4)
            : Colors.grey.shade400)
        : (isSelected
            ? AppColors.primary
            : (isDark ? AppColors.textMuted : const Color(0xFF64748B)));

    final titleColor = isDisabled
        ? (isDark ? AppColors.textMuted : Colors.grey.shade400)
        : (isSelected
            ? AppColors.primary
            : (isDark ? AppColors.textPrimary : const Color(0xFF0F172A)));

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: isSelected && !isDisabled ? 2.r : 1.r,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isSelected && !isDisabled
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : (isDark
                        ? Colors.white10
                        : const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 18.r,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5.sp,
                            color: titleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isDisabled) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.lock_rounded,
                          size: 12.r,
                          color: AppColors.error,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isDisabled ? (disabledSubtitle ?? 'Disabled') : subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDisabled
                          ? AppColors.error.withValues(alpha: 0.8)
                          : AppColors.textMuted,
                      fontSize: 11.sp,
                      fontWeight:
                          isDisabled ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
