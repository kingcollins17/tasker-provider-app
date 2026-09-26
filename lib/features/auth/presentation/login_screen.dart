import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/designs/colors.dart';
import '../../../../core/ui/designs/text_styles.dart';
import '../../../../core/ui/widgets/app_text_field.dart';
import '../../../../core/ui/widgets/primary_button.dart';
import '../../../../core/utils/extensions/loading_context_ext.dart';
import '../../../../core/utils/extensions/flushbar_context_ext.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
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
                    SizedBox(height: 12.h),

                    // Welcoming Animated Security Graphic
                    const Center(
                      child: _WelcomingSecurityGraphic(),
                    ),
                    SizedBox(height: 24.h),

                    // Welcome Back Title
                    Text(
                      'Welcome Back',
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
                      'Log in to your account to continue.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 36.h),

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

                    // Password Input Section
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your password',
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
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // Sign In Button
                    PrimaryButton(text: 'Sign In', onPressed: _handleLogin),
                    SizedBox(height: 8.h),

                    // Don't have an account text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Sign Up',
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

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.showLoading();
      ref
          .read(authProvider.notifier)
          .login(
            _emailController.text.trim(),
            _passwordController.text,
            onSuccess: () {
              context.hideLoading();
              context.go('/');
            },
            onError: (error) {
              context.hideLoading();
              context.showError(error);
            },
          );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED WELCOMING SECURITY GRAPHIC (CUSTOM PAINT)
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomingSecurityGraphic extends StatefulWidget {
  const _WelcomingSecurityGraphic();

  @override
  State<_WelcomingSecurityGraphic> createState() =>
      _WelcomingSecurityGraphicState();
}

class _WelcomingSecurityGraphicState extends State<_WelcomingSecurityGraphic>
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
          width: 110.r,
          height: 110.r,
          child: CustomPaint(
            painter: _SecurityBadgePainter(
              progress: _controller.value,
              isDark: isDark,
            ),
            child: Center(
              child: Container(
                width: 56.r,
                height: 56.r,
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
                      blurRadius: 16.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 28.r,
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

class _SecurityBadgePainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SecurityBadgePainter({required this.progress, required this.isDark});

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
  bool shouldRepaint(covariant _SecurityBadgePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
