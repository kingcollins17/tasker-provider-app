import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../api/users_client.dart';
import '../../models/models.dart';
import '../../utils/extensions/flushbar_context_ext.dart';
import '../../utils/extensions/loading_context_ext.dart';
import '../designs/designs.dart';
import '../widgets/primary_button.dart';

/// A premium page to verify OTP code for a target channel.
class VerifyOTPPage extends ConsumerStatefulWidget {
  final String target;
  final String channel;

  const VerifyOTPPage({
    super.key,
    required this.target,
    required this.channel,
  });

  /// Pushes the OTP verification screen and returns a record of success and the code.
  static Future<({bool isVerified, String otp})?> verify(
    BuildContext context, {
    required String target,
    required String channel,
  }) async {
    return await Navigator.push<({bool isVerified, String otp})>(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyOTPPage(target: target, channel: channel),
      ),
    );
  }

  @override
  ConsumerState<VerifyOTPPage> createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends ConsumerState<VerifyOTPPage> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      context.showError('Please enter the full 6-digit code.');
      return;
    }

    context.showLoading();

    try {
      final response = await ref.read(usersClientProvider).verifyOtp(
            VerifyOtpRequest(
              target: widget.target,
              channel: widget.channel,
              code: code,
            ),
          );

      if (!mounted) return;
      context.hideLoading();

      if (response.isSuccessful) {
        Navigator.pop(context, (isVerified: true, otp: code));
      } else {
        context.showError(response.detail ?? 'Failed to verify OTP. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      context.hideLoading();
      context.showError('An error occurred during verification. Please check your connection.');
    }
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            size: 20.r,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Verification Code',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                ) ?? AppTextStyles.h2.copyWith(fontSize: 28.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                'We have sent a 6-digit verification code to ${widget.target}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                ) ?? AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 48.h),

              // 6 OTP Code input cells
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48.w,
                    height: 56.h,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppTextStyles.h3.copyWith(
                        color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: isDark ? AppColors.surface : Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                            width: 1.r,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
                            width: 1.r,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5.r,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                            _verifyOtp();
                          }
                        } else {
                          if (index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              SizedBox(height: 48.h),

              PrimaryButton(
                text: 'Verify Code',
                onPressed: _verifyOtp,
              ),
              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.showInfo('Resending code is currently mock-integrated.');
                    },
                    child: Text(
                      'Resend',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
