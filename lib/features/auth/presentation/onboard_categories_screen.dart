import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/providers/services_provider.dart';
import '../../../core/models/models.dart';
import '../../../app_routes.dart';

class OnboardCategoriesScreen extends ConsumerStatefulWidget {
  const OnboardCategoriesScreen({super.key});

  @override
  ConsumerState<OnboardCategoriesScreen> createState() =>
      _OnboardCategoriesScreenState();
}

class _OnboardCategoriesScreenState
    extends ConsumerState<OnboardCategoriesScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCategoryId;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider(null));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.hLg,

                // --- Step indicator ---
                _buildStepIndicator(step: 1),
                AppSpacing.hLg,

                // --- Header ---
                Text('Choose Your Category', style: AppTextStyles.h2),
                AppSpacing.hSm,
                Text(
                  'Select the category that best describes the services you offer.',
                  style: AppTextStyles.bodyMedium,
                ),
                AppSpacing.hLg,

                // --- Categories Grid ---
                Expanded(
                  child: categoriesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (error, _) => _buildErrorState(error),
                    data: (categories) => _buildCategoriesGrid(categories),
                  ),
                ),

                // --- Continue Button ---
                AppSpacing.hMd,
                PrimaryButton(
                  text: 'Continue',
                  onPressed: _selectedCategoryId != null ? _onContinue : null,
                ),
                AppSpacing.hLg,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required int step}) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index < step;
        final isCurrent = index == step - 1;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 4.h,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            decoration: BoxDecoration(
              borderRadius: AppDecorations.radiusSm,
              gradient: isActive || isCurrent
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    )
                  : null,
              color: !isActive && !isCurrent ? AppColors.border : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48.r),
          AppSpacing.hMd,
          Text('Failed to load categories', style: AppTextStyles.subtitle),
          AppSpacing.hSm,
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          AppSpacing.hMd,
          PrimaryButton(
            text: 'Retry',
            isFullWidth: false,
            onPressed: () => ref.invalidate(categoriesProvider(null)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List<Category> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'No categories available at the moment.',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategoryId == category.id;
        return _CategoryCard(
          category: category,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedCategoryId = _selectedCategoryId == category.id
                  ? null
                  : category.id;
            });
          },
          index: index,
        );
      },
    );
  }

  void _onContinue() {
    if (_selectedCategoryId == null) return;
    context.pushNamed(
      AppRoutes.onboardServicesRoute,
      queryParameters: {'categoryId': _selectedCategoryId},
    );
  }
}

// ---------------------------------------------------------------------------
// Category Card Widget
// ---------------------------------------------------------------------------

class _CategoryCard extends StatefulWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
        );

    // Stagger the entrance animation
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  IconData _iconForCategory(String? name) {
    final lower = (name ?? '').toLowerCase();
    if (lower.contains('clean')) return Icons.cleaning_services_rounded;
    if (lower.contains('plumb')) return Icons.plumbing_rounded;
    if (lower.contains('electric')) return Icons.electrical_services_rounded;
    if (lower.contains('paint')) return Icons.format_paint_rounded;
    if (lower.contains('tech') || lower.contains('it'))
      return Icons.computer_rounded;
    if (lower.contains('garden') || lower.contains('lawn'))
      return Icons.grass_rounded;
    if (lower.contains('car') || lower.contains('auto'))
      return Icons.directions_car_rounded;
    if (lower.contains('beauty') || lower.contains('hair'))
      return Icons.content_cut_rounded;
    if (lower.contains('cook') || lower.contains('cater'))
      return Icons.restaurant_rounded;
    if (lower.contains('move') || lower.contains('delivery'))
      return Icons.local_shipping_rounded;
    if (lower.contains('tutor') || lower.contains('teach'))
      return Icons.school_rounded;
    if (lower.contains('health') || lower.contains('fit'))
      return Icons.fitness_center_rounded;
    if (lower.contains('photo') || lower.contains('video'))
      return Icons.camera_alt_rounded;
    if (lower.contains('laundry')) return Icons.local_laundry_service_rounded;
    if (lower.contains('tailor') || lower.contains('fashion'))
      return Icons.checkroom_rounded;
    return Icons.handyman_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surface,
              borderRadius: AppDecorations.radiusMd,
              border: Border.all(
                color: widget.isSelected ? AppColors.primary : AppColors.border,
                width: widget.isSelected ? 2.r : 1.r,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 16.r,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.background,
                    border: Border.all(
                      color: widget.isSelected
                          ? AppColors.primaryLight
                          : AppColors.border,
                      width: 1.r,
                    ),
                  ),
                  child: Icon(
                    _iconForCategory(widget.category.name),
                    color: widget.isSelected
                        ? AppColors.primaryLight
                        : AppColors.textMuted,
                    size: 24.r,
                  ),
                ),
                AppSpacing.hSm,
                // Category name
                Padding(
                  padding: AppSpacing.pHorsSm,
                  child: Text(
                    widget.category.name ?? 'Unknown',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: widget.isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.category.description != null) ...[
                  SizedBox(height: 4.h),
                  Padding(
                    padding: AppSpacing.pHorsSm,
                    child: Text(
                      widget.category.description!,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
