import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/providers/services_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';

class OnboardServicesScreen extends ConsumerStatefulWidget {
  /// The category ID passed from the categories screen.
  final String? categoryId;

  const OnboardServicesScreen({super.key, this.categoryId});

  @override
  ConsumerState<OnboardServicesScreen> createState() =>
      _OnboardServicesScreenState();
}

class _OnboardServicesScreenState extends ConsumerState<OnboardServicesScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxSelections = 3;
  final Set<String> _selectedServiceIds = {};
  bool _isSubmitting = false;

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
    final servicesAsync = ref.watch(
      servicesProvider((search: null, categoryId: widget.categoryId)),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                _buildStepIndicator(step: 2, isDark: isDark),
                AppSpacing.hLg,

                // --- Back + Header ---
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Theme.of(context).colorScheme.surface
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.border
                                : const Color(0xFFE2E8F0),
                            width: 1.r,
                          ),
                        ),
                        child: Icon(Icons.arrow_back_rounded, size: 20.r),
                      ),
                    ),
                    AppSpacing.wMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Services',
                            style: AppTextStyles.h3.copyWith(),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Choose up to $_maxSelections services you provide.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textMuted
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.hMd,

                // --- Selection counter chip ---
                _buildSelectionCounter(isDark),
                AppSpacing.hMd,

                // --- Services List ---
                Expanded(
                  child: servicesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (error, _) => _buildErrorState(error, isDark),
                    data: (services) => _buildServicesList(services, isDark),
                  ),
                ),

                // --- Continue Button ---
                AppSpacing.hMd,
                PrimaryButton(
                  text: _isSubmitting ? 'Saving...' : 'Continue',
                  isLoading: _isSubmitting,
                  onPressed: _selectedServiceIds.isNotEmpty && !_isSubmitting
                      ? _onFinish
                      : null,
                ),
                AppSpacing.hLg,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required int step, required bool isDark}) {
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
              color: !isActive && !isCurrent
                  ? (isDark ? AppColors.border : AppColors.textSecondary)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSelectionCounter(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _selectedServiceIds.isNotEmpty
            ? AppColors.primary.withValues(alpha: 0.12)
            : (isDark
                  ? Theme.of(context).colorScheme.surface
                  : Colors.white),
        borderRadius: AppDecorations.radiusXl,
        border: Border.all(
          color: _selectedServiceIds.isNotEmpty
              ? AppColors.primary.withValues(alpha: 0.4)
              : (isDark ? AppColors.border : const Color(0xFFE2E8F0)),
          width: 1.r,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.checklist_rounded,
            color: _selectedServiceIds.isNotEmpty
                ? AppColors.primaryLight
                : AppColors.textMuted,
            size: 18.r,
          ),
          SizedBox(width: 8.w),
          Text(
            '${_selectedServiceIds.length} / $_maxSelections selected',
            style: AppTextStyles.label.copyWith(
              color: _selectedServiceIds.isNotEmpty
                  ? AppColors.primaryLight
                  : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48.r),
          AppSpacing.hMd,
          Text(
            'Failed to load services',
            style: AppTextStyles.subtitle.copyWith(),
          ),
          AppSpacing.hSm,
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textMuted : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.hMd,
          PrimaryButton(
            text: 'Retry',
            isFullWidth: false,
            onPressed: () => ref.invalidate(
              servicesProvider((search: null, categoryId: widget.categoryId)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<Service> services, bool isDark) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, color: AppColors.textMuted, size: 48.r),
            AppSpacing.hMd,
            Text(
              'No services found in this category.',
              style: AppTextStyles.bodyMedium.copyWith(),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (_, _) => SizedBox(height: 4.h),
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = _selectedServiceIds.contains(service.id);
        final isDisabled =
            _selectedServiceIds.length >= _maxSelections && !isSelected;

        return _ServiceTile(
          service: service,
          isSelected: isSelected,
          isDisabled: isDisabled,
          isDark: isDark,
          onTap: () => _toggleService(service),
          index: index,
        );
      },
    );
  }

  void _toggleService(Service service) {
    if (service.id == null) return;

    setState(() {
      if (_selectedServiceIds.contains(service.id)) {
        _selectedServiceIds.remove(service.id);
      } else {
        if (_selectedServiceIds.length < _maxSelections) {
          _selectedServiceIds.add(service.id!);
        } else {
          context.showInfo(
            'You can select up to $_maxSelections services.',
            title: 'Limit Reached',
          );
        }
      }
    });
  }

  Future<void> _onFinish() async {
    if (_selectedServiceIds.isEmpty) return;
    setState(() => _isSubmitting = true);
    context.showLoading();

    await ref
        .read(userProvider.notifier)
        .bulkAddServices(
          _selectedServiceIds.toList(),
          onSuccess: () {
            if (!mounted) return;
            context.hideLoading();
            setState(() => _isSubmitting = false);
            context.showToast('Services added successfully!');
            // Navigate to home / dashboard
            context.go('/');
          },
          onError: (error) {
            if (!mounted) return;
            context.hideLoading();
            setState(() => _isSubmitting = false);
            context.showError(error, title: 'Failed to add services');
          },
        );
  }
}

// ---------------------------------------------------------------------------
// Service Tile Widget
// ---------------------------------------------------------------------------

class _ServiceTile extends StatefulWidget {
  final Service service;
  final bool isSelected;
  final bool isDisabled;
  final bool isDark;
  final VoidCallback onTap;
  final int index;

  const _ServiceTile({
    required this.service,
    required this.isSelected,
    required this.isDisabled,
    required this.isDark,
    required this.onTap,
    required this.index,
  });

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
        );

    Future.delayed(Duration(milliseconds: 40 * widget.index), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Opacity(
          opacity: widget.isDisabled ? 0.4 : 1.0,
          child: GestureDetector(
            onTap: widget.isDisabled ? null : widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: AppDecorations.radiusMd,
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 1.5.r,
                ),
              ),
              child: Row(
                children: [
                  // Service icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : (widget.isDark
                              ? AppColors.surface
                              : const Color(0xFFF1F5F9)),
                      borderRadius: AppDecorations.radiusSm,
                      border: Border.all(
                        color: widget.isSelected
                            ? AppColors.primaryLight.withValues(alpha: 0.5)
                            : (widget.isDark
                                ? AppColors.border
                                : const Color(0xFFE2E8F0)),
                        width: 1.r,
                      ),
                    ),
                    child: Icon(
                      Icons.build_circle_outlined,
                      color: widget.isSelected
                          ? AppColors.primaryLight
                          : (widget.isDark
                              ? AppColors.textSecondary
                              : const Color(0xFF475569)),
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Service details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name ?? 'Unnamed Service',
                          style: AppTextStyles.buttonMedium.copyWith(
                            fontSize: 13.5.sp,
                            color: widget.isSelected
                                ? (widget.isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary)
                                : (widget.isDark
                                      ? AppColors.textPrimary
                                      : const Color(0xFF0F172A)),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.service.category?.name != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            widget.service.category!.name!,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11.5.sp,
                              color: widget.isSelected
                                  ? (widget.isDark
                                      ? AppColors.primaryLight.withValues(alpha: 0.8)
                                      : AppColors.primaryDark)
                                  : (widget.isDark
                                      ? AppColors.textMuted
                                      : const Color(0xFF64748B)),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Selection Checkmark indicator
                  if (widget.isSelected) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.check_circle_rounded,
                      color: widget.isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                      size: 20.r,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
