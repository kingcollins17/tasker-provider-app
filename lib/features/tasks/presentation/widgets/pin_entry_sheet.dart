import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/ui/designs/colors.dart';
import 'package:tasker_app/core/ui/designs/text_styles.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';

typedef PinSubmitCallback = Future<bool> Function(WidgetRef ref, String pin, bool isCash);

class PinEntryAndPaymentModeSheet extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final String confirmButtonText;
  final IconData icon;
  final bool showPaymentMode;
  final bool initialIsCash;
  final PinSubmitCallback? onConfirm;

  const PinEntryAndPaymentModeSheet({
    super.key,
    this.title = 'Enter Verification PIN',
    this.subtitle = 'Please enter the 4-digit PIN provided by the customer',
    this.confirmButtonText = 'Submit PIN',
    this.icon = Icons.lock_outline_rounded,
    this.showPaymentMode = false,
    this.initialIsCash = true,
    this.onConfirm,
  });

  static Future<(String?, bool?)?> show(
    BuildContext context, {
    String title = 'Enter Verification PIN',
    String subtitle = 'Please enter the 4-digit PIN provided by the customer',
    String confirmButtonText = 'Submit PIN',
    IconData icon = Icons.lock_outline_rounded,
    bool showPaymentMode = false,
    bool initialIsCash = true,
    PinSubmitCallback? onConfirm,
  }) {
    return showModalBottomSheet<(String?, bool?)>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PinEntryAndPaymentModeSheet(
          title: title,
          subtitle: subtitle,
          confirmButtonText: confirmButtonText,
          icon: icon,
          showPaymentMode: showPaymentMode,
          initialIsCash: initialIsCash,
          onConfirm: onConfirm,
        ),
      ),
    );
  }

  @override
  ConsumerState<PinEntryAndPaymentModeSheet> createState() =>
      _PinEntryAndPaymentModeSheetState();
}

class _PinEntryAndPaymentModeSheetState
    extends ConsumerState<PinEntryAndPaymentModeSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _pin = '';
  late bool _isCash;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isCash = widget.initialIsCash;
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
    if (_pin.length != 4 || _isLoading) return;

    if (widget.onConfirm != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final success = await widget.onConfirm!(ref, _pin, _isCash);
        if (success && mounted) {
          Navigator.of(
            context,
          ).pop((_pin, widget.showPaymentMode ? _isCash : null));
        }
      } catch (e, st) {
        debugLog('Error in PIN sheet onConfirm: $e\n$st');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      Navigator.of(
        context,
      ).pop((_pin, widget.showPaymentMode ? _isCash : null));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle Indicator
          Container(
            width: 48.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          // Icon Badge
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: AppColors.primary,
                size: 30.r,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Text(
            widget.title,
            style: AppTextStyles.h2.copyWith(fontSize: 20.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),

          // Subtitle
          Text(
            widget.subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
              fontSize: 13.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 28.h),

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
                      width: 60.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isCurrentFocus
                              ? AppColors.primary
                              : (isFilled
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : AppColors.border),
                          width: isCurrentFocus ? 2.r : 1.r,
                        ),
                        boxShadow: isCurrentFocus
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 10.r,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          char,
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 26.sp,
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
          if (widget.showPaymentMode) ...[
            SizedBox(height: 24.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Payment Settlement Mode',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _PaymentModeCard(
                    title: 'Cash',
                    subtitle: 'Direct cash',
                    icon: Icons.payments_outlined,
                    isSelected: _isCash,
                    onTap: () => setState(() => _isCash = true),
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _PaymentModeCard(
                    title: 'Online',
                    subtitle: 'Electronic',
                    icon: Icons.credit_card_rounded,
                    isSelected: !_isCash,
                    onTap: () => setState(() => _isCash = false),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 32.h),

          // Submit Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _pin.length == 4 && !_isLoading ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.35),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                elevation: _pin.length == 4 ? 4 : 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20.r,
                      height: 20.r,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.confirmButtonText,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _PaymentModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : AppColors.border;
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
        : (isDark
            ? Colors.white.withValues(alpha: 0.03)
            : const Color(0xFFF8FAFC));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.r : 1.r,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : (isDark ? Colors.white10 : Colors.grey.shade200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 18.r,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.textPrimary
                              : const Color(0xFF0F172A)),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10.sp,
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
