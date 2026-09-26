import 'dart:math' as math;
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    // Welcoming Animated Profile Graphic
                    const Center(
                      child: _WelcomingRegisterGraphic(),
                    ),
                    SizedBox(height: 16.h),

                    // Create Account Title
                    Text(
                      'Create Account',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),

                    // Subtitle
                    Text(
                      'Sign up to get started with your dashboard.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.sp,
                        color: isDark
                            ? AppColors.textSecondary
                            : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),

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
                    SizedBox(height: 14.h),

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
                    SizedBox(height: 14.h),

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
                    SizedBox(height: 14.h),

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
                    SizedBox(height: 24.h),

                    // Create Account Button
                    PrimaryButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                    ),
                    SizedBox(height: 8.h),

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
                    SizedBox(height: 16.h),
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
      type: 'PROVIDER', // capitalize for api compatibility
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

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED WELCOMING REGISTER GRAPHIC (CUSTOM PAINT)
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomingRegisterGraphic extends StatefulWidget {
  const _WelcomingRegisterGraphic();

  @override
  State<_WelcomingRegisterGraphic> createState() =>
      _WelcomingRegisterGraphicState();
}

class _WelcomingRegisterGraphicState extends State<_WelcomingRegisterGraphic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 100.r,
          height: 100.r,
          child: CustomPaint(
            painter: _RegisterBadgePainter(
              progress: _controller.value,
              isDark: isDark,
            ),
            child: Center(
              child: Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 14.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 26.r,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RegisterBadgePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _RegisterBadgePainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Ambient pulsing glow background
    final pulseScale = 0.82 + 0.08 * math.sin(progress * 2 * math.pi);
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.2),
          AppColors.primary.withValues(alpha: 0.0),
        ],
        stops: const [0.2, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius * pulseScale, auraPaint);

    // 2. Rotating Dash Orbit Ring
    final ringRadius = radius * 0.76;
    final ringPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: isDark ? 0.45 : 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    const dashCount = 8;
    final sweepAngle = (2 * math.pi) / dashCount;
    final rotationAngle = progress * 2 * math.pi;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = rotationAngle + i * sweepAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        startAngle,
        sweepAngle * 0.45,
        false,
        ringPaint,
      );
    }

    // 3. Orbiting illuminated node
    final particleAngle = -rotationAngle * 1.2;
    final particleOffset = Offset(
      center.dx + ringRadius * math.cos(particleAngle),
      center.dy + ringRadius * math.sin(particleAngle),
    );

    final nodeGlow = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(particleOffset, 5.r, nodeGlow);

    final nodePaint = Paint()..color = Colors.white;
    canvas.drawCircle(particleOffset, 2.5.r, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _RegisterBadgePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
