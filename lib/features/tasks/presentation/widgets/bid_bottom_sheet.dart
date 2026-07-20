import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/models/api/tasks/task.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/utils/extensions/num_ext.dart';
import 'package:tasker_app/core/ui/widgets/app_text_field.dart';

class BidBottomSheet extends StatefulWidget {
  final double? initialBudget;
  final String? initialMessage;
  final Duration? initialDurationEstimate;

  const BidBottomSheet({
    super.key,
    this.initialBudget,
    this.initialMessage,
    this.initialDurationEstimate,
  });

  static Future<CreateBidRequest?> show(
    BuildContext context, {
    double? initialBudget,
    String? initialMessage,
    Duration? initialDurationEstimate,
  }) {
    return showModalBottomSheet<CreateBidRequest>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BidBottomSheet(
          initialBudget: initialBudget,
          initialMessage: initialMessage,
          initialDurationEstimate: initialDurationEstimate,
        ),
      ),
    );
  }

  @override
  State<BidBottomSheet> createState() => _BidBottomSheetState();
}

class _BidBottomSheetState extends State<BidBottomSheet> {
  final _priceController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _durationHours = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialBudget != null) {
      _priceController.text = widget.initialBudget!.toStringAsFixed(2);
    }
    if (widget.initialMessage != null) {
      _messageController.text = widget.initialMessage!;
    }
    if (widget.initialDurationEstimate != null) {
      _durationHours =
          widget.initialDurationEstimate!.inHours.clamp(1, 24).toDouble();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final request = CreateBidRequest(
        price: price,
        message: _messageController.text.trim(),
        estimatedDuration: '${_durationHours.toInt()} hours',
      );
      Navigator.of(context).pop(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B2E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── DRAG HANDLE ───
              _buildDragHandle(isDark),

              // ─── HEADER ───
              _buildHeader(isDark),

              SizedBox(height: 24.h),
              _buildDivider(isDark),
              SizedBox(height: 24.h),

              // ─── PRICE SECTION ───
              _buildPriceSection(isDark),

              SizedBox(height: 24.h),

              // ─── DURATION SECTION ───
              _buildDurationSection(isDark, context),

              SizedBox(height: 20.h),

              // ─── MESSAGE SECTION ───
              _buildMessageSection(isDark),

              SizedBox(height: 28.h),

              // ─── SUBMIT BUTTON ───
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DRAG HANDLE ──────────────────────────────────────────────────────────

  Widget _buildDragHandle(bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 12.h),
        child: Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.15)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
      child: Column(
        children: [
          // Gradient icon badge
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.gavel_rounded,
              color: Colors.white,
              size: 24.r,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Submit Your Bid',
            style: AppTextStyles.h3.copyWith(
              color: isDark
                  ? AppColors.textPrimary
                  : const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Set your price and estimated time to complete this task',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textMuted
                  : const Color(0xFF64748B),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── DIVIDER ──────────────────────────────────────────────────────────────

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      color: isDark ? AppColors.border : Colors.grey.shade100,
    );
  }

  // ─── PRICE SECTION ────────────────────────────────────────────────────────

  Widget _buildPriceSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            icon: Icons.payments_outlined,
            iconColor: AppColors.success,
            label: 'Your Price',
            isDark: isDark,
          ),
          SizedBox(height: 10.h),
          AppTextField(
            controller: _priceController,
            hintText: '0.00',
            prefixText: '₦ ',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter a price';
              }
              if (double.tryParse(val.trim()) == null) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          if (widget.initialBudget != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: _BudgetHintChip(budget: widget.initialBudget!),
            ),
        ],
      ),
    );
  }

  // ─── DURATION SECTION ─────────────────────────────────────────────────────

  Widget _buildDurationSection(bool isDark, BuildContext context) {
    final hours = _durationHours.toInt();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(
                icon: Icons.schedule_rounded,
                color: AppColors.warning,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Estimated Duration',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondary
                        : const Color(0xFF334155),
                  ),
                ),
              ),
              _DurationBadge(hours: hours),
            ],
          ),
          SizedBox(height: 14.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor:
                  isDark ? AppColors.border : Colors.grey.shade200,
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 8.r,
                elevation: 3,
                pressedElevation: 6,
              ),
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              trackHeight: 5.h,
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: _durationHours,
              min: 1,
              max: 24,
              divisions: 23,
              onChanged: (val) => setState(() => _durationHours = val),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 hr',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                ),
                Text(
                  '24 hrs',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── MESSAGE SECTION ──────────────────────────────────────────────────────

  Widget _buildMessageSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(
                icon: Icons.chat_bubble_outline_rounded,
                color: const Color(0xFF3B82F6),
              ),
              SizedBox(width: 8.w),
              Text(
                'Message',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondary
                      : const Color(0xFF334155),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.border : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Optional',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          AppTextField(
            controller: _messageController,
            hintText: 'Explain why you\'re the best fit for this task...',
            maxLength: 500,
            maxLines: 3,
            minLines: 2,
          ),
        ],
      ),
    );
  }

  // ─── SUBMIT BUTTON ────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _submit,
          borderRadius: BorderRadius.circular(16.r),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white, size: 20.r),
                  SizedBox(width: 10.w),
                  Text(
                    'Submit Bid',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
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

  // ─── SHARED HELPERS ───────────────────────────────────────────────────────

  Widget _buildSectionLabel({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isDark,
  }) {
    return Row(
      children: [
        _buildSectionIcon(icon: icon, color: iconColor),
        SizedBox(width: 8.w),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondary : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionIcon({required IconData icon, required Color color}) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: 16.r),
    );
  }
}

// ─── SMALL EXTRACTED WIDGETS ──────────────────────────────────────────────────

class _BudgetHintChip extends StatelessWidget {
  final double budget;
  const _BudgetHintChip({required this.budget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14.r,
            color: AppColors.primaryLight,
          ),
          SizedBox(width: 6.w),
          Text(
            'Budget: ${budget.toNaira()}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final int hours;
  const _DurationBadge({required this.hours});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primaryDark.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        '$hours hr${hours > 1 ? 's' : ''}',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primaryLight,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
