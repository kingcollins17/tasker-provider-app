import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';
import '../../providers/providers.dart';
import '../../router/navigator_keys.dart';
import '../../utils/extensions/flushbar_context_ext.dart';
import '../../utils/extensions/num_ext.dart';
import '../designs/colors.dart';
import '../designs/text_styles.dart';
import 'primary_button.dart';

/// A premium, visually appealing modal bottom sheet for providers to request
/// a price adjustment for an assigned task.
///
/// Fetches task details (title, current price) dynamically via [taskDetailProvider].
/// Non-dismissible by tap-outside or drag; can only be closed via the top-right 'X' button.
class AdjustTaskPriceSheet extends ConsumerStatefulWidget {
  final String taskId;
  final VoidCallback? onSuccess;

  const AdjustTaskPriceSheet({
    super.key,
    required this.taskId,
    this.onSuccess,
  });

  /// Displays the non-dismissible [AdjustTaskPriceSheet] modal bottom sheet.
  /// Always uses [NavigatorKeys.rootNavigatorKey.currentContext] internally.
  static Future<void> show({
    required String taskId,
    VoidCallback? onSuccess,
  }) async {
    final ctx = NavigatorKeys.rootNavigatorKey.currentContext;
    if (ctx == null || taskId.isEmpty) return;

    await showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => AdjustTaskPriceSheet(
        taskId: taskId,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<AdjustTaskPriceSheet> createState() =>
      _AdjustTaskPriceSheetState();
}

class _AdjustTaskPriceSheetState extends ConsumerState<AdjustTaskPriceSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _amountController.addListener(_onAmountChanged);
    _descriptionController = TextEditingController();
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final taskDetailAsync = ref.watch(taskDetailProvider(widget.taskId));
    final taskManagementState = ref.watch(taskManagementProvider);

    return PopScope(
      canPop: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              left: 18.w,
              right: 18.w,
              top: 14.h,
              bottom: 18.h + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header Row with Title and Close (X) Button
                  Row(
                    children: [
                      Text(
                        'Request Price Adjustment',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimary
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18.r,
                          color: isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF64748B),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF262626)
                              : const Color(0xFFF1F5F9),
                          padding: EdgeInsets.all(6.r),
                          minimumSize: Size(32.r, 32.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Content View (Shimmer if loading, else Populated Sheet Content)
                  taskDetailAsync.when(
                    loading: () => _buildShimmerLoadingLayout(context, isDark),
                    error: (err, st) => _buildPopulatedContent(
                      context,
                      isDark,
                      taskManagementState,
                      taskTitle: _fallbackTaskRef(widget.taskId),
                      currentPrice: 0.0,
                    ),
                    data: (task) => _buildPopulatedContent(
                      context,
                      isDark,
                      taskManagementState,
                      taskTitle: task.title ?? _fallbackTaskRef(widget.taskId),
                      currentPrice: task.providerPayout ??
                          task.customerTotalPrice ??
                          0.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoadingLayout(BuildContext context, bool isDark) {
    final baseColor =
        isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0);
    final highlightColor =
        isDark ? const Color(0xFF3B3B3B) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 58.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: 18.h),
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulatedContent(
    BuildContext context,
    bool isDark,
    AsyncValue<void> taskManagementState, {
    required String taskTitle,
    required double currentPrice,
  }) {
    final rawAmountText = _amountController.text.trim();
    final enteredAmount = double.tryParse(rawAmountText) ?? 0.0;
    final bool hasInput = rawAmountText.isNotEmpty;
    final bool isValidAmount = enteredAmount > currentPrice;
    final double additionalAmount = enteredAmount - currentPrice;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Task Info Card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              width: 1.r,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TASK DETAILS',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      taskTitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.textPrimary
                            : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Original Payout',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    currentPrice.toNaira(2),
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Requested Price Field Label
        Text(
          'New Total Task Price (₦)',
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12.5.sp,
            color: isDark ? AppColors.textPrimary : const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            prefixText: '₦ ',
            prefixStyle: AppTextStyles.bodyMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            hintText: 'Enter total new price (e.g. 15000)',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              fontSize: 13.sp,
              color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasInput && !isValidAmount
                    ? AppColors.error
                    : AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),

        // Subtext explaining additional price adjustment calculation
        Text(
          !hasInput
              ? 'Must be greater than current payout of ${currentPrice.toNaira(2)}'
              : !isValidAmount
                  ? 'Price must be higher than current payout of ${currentPrice.toNaira(2)}'
                  : 'Additional price adjustment: +${additionalAmount.toNaira(2)}',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11.5.sp,
            fontWeight: isValidAmount ? FontWeight.bold : FontWeight.w500,
            color: !hasInput
                ? AppColors.textMuted
                : !isValidAmount
                    ? AppColors.error
                    : AppColors.primary,
          ),
        ),

        SizedBox(height: 14.h),

        // Explanation / Reason Description Field
        Text(
          'Reason / Explanation (Optional)',
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12.5.sp,
            color: isDark ? AppColors.textPrimary : const Color(0xFF334155),
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          maxLength: 500,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13.sp,
            color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText:
                'Explain why a price adjustment is requested (e.g. additional materials required)',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor:
                isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
            contentPadding: EdgeInsets.all(12.r),
            counterStyle: AppTextStyles.bodySmall.copyWith(
              fontSize: 10.sp,
              color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Submit Adjustment Request Button
        PrimaryButton(
          text: 'Submit',
          isLoading: taskManagementState.isLoading,
          onPressed: !isValidAmount
              ? null
              : () {
                  final finalAmountToPass = enteredAmount - currentPrice;

                  final description =
                      _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim();

                  context.showLoading(null, 'Requesting price adjustment...');
                  ref
                      .read(taskManagementProvider.notifier)
                      .requestPriceAdjustment(
                        widget.taskId,
                        amount: finalAmountToPass,
                        description: description,
                        onSuccess: () {
                          if (mounted) {
                            context.hideLoading();
                            widget.onSuccess?.call();
                            Navigator.of(context).pop();
                          }
                        },
                        onError: (error) {
                          if (mounted) {
                            context.hideLoading();
                            context.showError(error);
                          }
                        },
                      );
                },
        ),
      ],
    );
  }

  String _fallbackTaskRef(String id) {
    return '#${id.length > 8 ? id.substring(0, 8).toUpperCase() : id}';
  }
}
