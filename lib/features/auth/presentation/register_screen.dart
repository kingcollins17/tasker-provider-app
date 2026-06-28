import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tasker_app/core/providers/region_provider.dart';
import '../../../../core/ui/designs/colors.dart';
import '../../../../core/ui/designs/text_styles.dart';
import '../../../../core/ui/widgets/app_text_field.dart';
import '../../../../core/ui/widgets/primary_button.dart';
import '../../../../core/ui/pages/pages.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/extensions/loading_context_ext.dart';
import '../../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../../app_routes.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10.h),
                    // Profile Icon Badge with Plus
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 80.r,
                            height: 80.r,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surface
                                  : const Color(0xFFF1F5F9), // Slate 100/800
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.border
                                    : const Color(0xFFE2E8F0),
                                width: 2.r,
                              ),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: AppColors.textMuted,
                              size: 40.r,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24.r,
                              height: 24.r,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16.r,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Create Account Title
                    Text(
                      'Create Account',
                      style:
                          theme.textTheme.titleLarge?.copyWith(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                          ) ??
                          AppTextStyles.h2.copyWith(fontSize: 28.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),

                    // Subtitle
                    Text(
                      'Sign up to get started with your dashboard.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // Full Name Input Section
                    AppTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.textMuted,
                        size: 20.r,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Email Input Section
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.textMuted,
                        size: 20.r,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Phone Number Input Section
                    AppTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hintText: '8012345678',
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 16.w, right: 12.w),
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
                              color: isDark
                                  ? AppColors.border
                                  : const Color(0xFFE2E8F0),
                            ),
                          ],
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Phone number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Password Input Section
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Create a password',
                      obscureText: _obscurePassword,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.textMuted,
                        size: 20.r,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                          size: 20.r,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),

                    // Create Account Button
                    PrimaryButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                    ),
                    SizedBox(height: 32.h),

                    // Already have an account text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Sign In',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _getRegionId() async {
    return ref.read(currentRegionProvider.future).then((res) => res?.id);
  }

  void _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final names = _nameController.text.trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : '';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    final request = RegisterRequest(
      email: email,
      phoneNumber: '+234$phone',
      password: password,
      firstName: firstName,
      lastName: lastName,
      type: 'provider',

      regionId: await _getRegionId(),
    );

    if (!mounted) return;

    context.showLoading();
    ref
        .read(authProvider.notifier)
        .signup(
          request,
          onSuccess: () => _onSignupSuccess(email, password),
          onError: _onError,
        );
  }

  void _onSignupSuccess(String email, String password) {
    ref
        .read(authProvider.notifier)
        .requestEmailOtp(
          email,
          onSuccess: () => _onOtpRequested(email, password),
          onError: _onError,
        );
  }

  Future<void> _onOtpRequested(String email, String password) async {
    context.hideLoading();

    final result = await VerifyOTPPage.verify(
      context,
      target: email,
      channel: 'email',
      verifier: (otp, target) => ref
          .read(authProvider.notifier)
          .verifyEmail(
            target,
            otp,
            onError: (err) {
              context.showError(err);
            },
          ),
    );

    if (result != null && result.isVerified && context.mounted) {
      _loginAfterVerification(email, password);
    }
  }

  void _loginAfterVerification(String email, String password) {
    context.showLoading();
    ref
        .read(authProvider.notifier)
        .login(
          email,
          password,
          onSuccess: () {
            context.hideLoading();
            context.showToast('Account verified! Welcome aboard.');
            context.goNamed(AppRoutes.onboardCategoriesRoute);
          },
          onError: _onError,
        );
  }

  void _onError(String error) {
    context.hideLoading();
    context.showError(error);
  }
}
