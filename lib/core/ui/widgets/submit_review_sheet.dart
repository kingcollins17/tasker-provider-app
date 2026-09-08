import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../router/navigator_keys.dart';
import '../../utils/extensions/flushbar_context_ext.dart';
import '../designs/colors.dart';
import '../designs/text_styles.dart';
import 'primary_button.dart';

/// A premium, visually appealing modal bottom sheet for providers to rate
/// and submit reviews for completed tasks and customer interactions.
///
/// Fetches task details (title, customer information) dynamically via [taskDetailProvider].
/// Non-dismissible by tap-outside or drag; can only be closed via the 'X' button.
class SubmitReviewSheet extends ConsumerStatefulWidget {
  final String taskId;
  final VoidCallback? onSuccess;

  const SubmitReviewSheet({
    super.key,
    required this.taskId,
    this.onSuccess,
  });

  /// Displays the non-dismissible [SubmitReviewSheet] modal bottom sheet.
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
      builder: (_) => SubmitReviewSheet(
        taskId: taskId,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<SubmitReviewSheet> createState() => _SubmitReviewSheetState();
}

class _SubmitReviewSheetState extends ConsumerState<SubmitReviewSheet> {
  int _rating = 0;
  bool _isCommentExpanded = false;
  late final TextEditingController _commentController;

  static const List<String> _ratingLabels = [
    'Tap a star to rate',
    '1 ★ - Poor',
    '2 ★ - Fair',
    '3 ★ - Good',
    '4 ★ - Very Good',
    '5 ★ - Excellent!',
  ];

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final submitState = ref.watch(submitReviewNotifierProvider);
    final taskDetailAsync = ref.watch(taskDetailProvider(widget.taskId));

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
                        'Rate Experience',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18.r,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
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
                      submitState,
                      taskTitle: _fallbackTaskRef(widget.taskId),
                      customerName: 'Customer',
                    ),
                    data: (task) => _buildPopulatedContent(
                      context,
                      isDark,
                      submitState,
                      taskTitle: task.title ?? _fallbackTaskRef(widget.taskId),
                      customerName: task.customer?.fullname ?? 'Customer',
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
    final baseColor = isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF3B3B3B) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Container(
              width: 56.r,
              height: 56.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 180.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Center(
            child: Container(
              width: 140.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
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
    AsyncValue<void> submitState, {
    required String taskTitle,
    required String customerName,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Card (Task Info & Completed Status Badge)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
                      'COMPLETED TASK',
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
                        color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 13.r,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Completed',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Center Avatar / Icon Section
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5.r,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(customerName),
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -2.r,
                right: -2.r,
                child: Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 1.5.r,
                    ),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 12.r,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        // Main Question & Prompt Subtitle
        Text(
          'How was your experience?',
          textAlign: TextAlign.center,
          style: AppTextStyles.h3.copyWith(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Share your feedback for working with $customerName',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12.sp,
            color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
          ),
        ),

        SizedBox(height: 14.h),

        // Interactive Star Rating Bar
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = starValue <= _rating;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starValue;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: AnimatedScale(
                    scale: isSelected ? 1.12 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      isSelected
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 34.r,
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 6.h),

        // Dynamic Rating Subtitle Indicator
        Text(
          _ratingLabels[_rating],
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11.5.sp,
            fontWeight: _rating > 0 ? FontWeight.bold : FontWeight.w500,
            color: _rating > 0
                ? const Color(0xFFF59E0B)
                : isDark
                    ? AppColors.textMuted
                    : const Color(0xFF94A3B8),
          ),
        ),

        SizedBox(height: 14.h),

        // Collapsible Comment Section Toggle
        InkWell(
          onTap: () {
            setState(() {
              _isCommentExpanded = !_isCommentExpanded;
            });
          },
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isCommentExpanded
                      ? Icons.chat_bubble_outline_rounded
                      : Icons.add_comment_outlined,
                  size: 15.r,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  _isCommentExpanded
                      ? 'Hide comment'
                      : 'Add a comment (optional)',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  _isCommentExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18.r,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),

        // Collapsible Comment Input Field with AnimatedCrossFade
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _isCommentExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: TextField(
              controller: _commentController,
              maxLines: 2,
              maxLength: 500,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.sp,
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText:
                    'What went well? Was $customerName clear, responsive, and friendly?',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC),
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
          ),
        ),

        SizedBox(height: 16.h),

        // Submit Review Button
        PrimaryButton(
          text: 'Submit review',
          isLoading: submitState.isLoading,
          onPressed: _rating == 0
              ? null
              : () {
                  final request = SubmitReviewRequest(
                    taskId: widget.taskId,
                    rating: _rating,
                    comment: _commentController.text.trim().isEmpty
                        ? null
                        : _commentController.text.trim(),
                  );
                  context.showLoading(null, 'Submitting review...');
                  ref.read(submitReviewNotifierProvider.notifier).submitReview(
                    request,
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

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'C';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
