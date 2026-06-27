import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../designs/colors.dart';
import '../designs/text_styles.dart';

/// A custom, reusable form text input field for Tasker.
class AppTextField extends StatelessWidget {
  /// Controller for managing the input value.
  final TextEditingController? controller;

  /// Input label displayed above the field.
  final String? label;

  /// Placeholder hint text.
  final String hintText;

  /// Keyboard type (e.g. emailAddress, text, number).
  final TextInputType keyboardType;

  /// If true, hides the input text (for passwords).
  final bool obscureText;

  /// Optional icon displayed at the start of the field.
  final Widget? prefixIcon;

  /// Optional icon displayed at the end of the field.
  final Widget? suffixIcon;

  /// Optional validator callback function.
  final String? Function(String?)? validator;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Maximum length of characters.
  final int? maxLength;

  /// Optional prefix text to show before the input (e.g. +234).
  final String? prefixText;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fillColor = isDark ? AppColors.surface : Colors.white;
    final borderColor = isDark ? AppColors.border : const Color(0xFFE2E8F0);
    final focusedBorderColor = isDark ? AppColors.accent : AppColors.primary;
    final hintColor = isDark ? AppColors.textMuted : const Color(0xFF94A3B8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondary : const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
            prefixIcon: prefixIcon,
            prefixText: prefixText,
            prefixStyle: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: suffixIcon,
            counterText: "", // Hides character counter at bottom
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor, width: 1.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor, width: 1.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: focusedBorderColor, width: 1.5.r),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error, width: 1.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.error, width: 1.5.r),
            ),
          ),
        ),
      ],
    );
  }
}
