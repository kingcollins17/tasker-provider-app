import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ui/designs/designs.dart';
import '../../../../core/ui/widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                // Illustration
                Center(
                  child: Container(
                    width: 160.r,
                    height: 160.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.surface : const Color(0xFFF1F5F9), // Slate 100/800
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Head
                          Positioned(
                            bottom: 65.h,
                            child: Container(
                              width: 32.r,
                              height: 32.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFDBA74), // Skin tone
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Hair
                          Positioned(
                            bottom: 82.h,
                            child: Container(
                              width: 36.r,
                              height: 20.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E293B),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                              ),
                            ),
                          ),
                          // Body / Shirt
                          Positioned(
                            bottom: -10.h,
                            child: Container(
                              width: 80.w,
                              height: 65.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                              ),
                            ),
                          ),
                          // Arm waving
                          Positioned(
                            right: 28.w,
                            bottom: 45.h,
                            child: Transform.rotate(
                              angle: 0.3,
                              child: Container(
                                width: 14.w,
                                height: 35.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDBA74), // Skin tone
                                  borderRadius: BorderRadius.circular(7.r),
                                ),
                              ),
                            ),
                          ),
                          // Waving hand circle
                          Positioned(
                            right: 22.w,
                            bottom: 72.h,
                            child: Container(
                              width: 14.r,
                              height: 14.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFDBA74),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 48.h),

                // Welcome Title
                Text(
                  'Welcome to Tasker',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ) ?? AppTextStyles.h2.copyWith(fontSize: 28.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Tagline
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'Explore a modern experience built for speed and simplicity.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
                      height: 1.5,
                    ) ?? AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 48.h),
                // Get Started Button
                PrimaryButton(
                  text: 'Get Started',
                  onPressed: () => context.push('/register'),
                ),
                SizedBox(height: 32.h),

                // Already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark ? AppColors.textSecondary : const Color(0xFF64748B),
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
    );
  }
}
