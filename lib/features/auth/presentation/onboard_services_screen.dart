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
                _buildStepIndicator(step: 2),
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
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.r,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textSecondary,
                          size: 20.r,
                        ),
                      ),
                    ),
                    AppSpacing.wMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Services', style: AppTextStyles.h3),
                          SizedBox(height: 2.h),
                          Text(
                            'Choose up to $_maxSelections services you provide.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.hMd,

                // --- Selection counter chip ---
                _buildSelectionCounter(),
                AppSpacing.hMd,

                // --- Services List ---
                Expanded(
                  child: servicesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                    error: (error, _) => _buildErrorState(error),
                    data: (services) => _buildServicesList(services),
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

  Widget _buildSelectionCounter() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _selectedServiceIds.isNotEmpty
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: AppDecorations.radiusXl,
        border: Border.all(
          color: _selectedServiceIds.isNotEmpty
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.border,
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

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48.r),
          AppSpacing.hMd,
          Text('Failed to load services', style: AppTextStyles.subtitle),
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
            onPressed: () => ref.invalidate(
              servicesProvider((search: null, categoryId: widget.categoryId)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<Service> services) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, color: AppColors.textMuted, size: 48.r),
            AppSpacing.hMd,
            Text(
              'No services found in this category.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: services.length,
      separatorBuilder: (_, _) => AppSpacing.hSm,
      itemBuilder: (context, index) {
        final service = services[index];
        final isSelected = _selectedServiceIds.contains(service.id);
        final isDisabled =
            _selectedServiceIds.length >= _maxSelections && !isSelected;

        return _ServiceTile(
          service: service,
          isSelected: isSelected,
          isDisabled: isDisabled,
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

    int successCount = 0;
    String? lastError;

    for (final serviceId in _selectedServiceIds) {
      await ref
          .read(userProvider.notifier)
          .addService(
            serviceId,
            onSuccess: () => successCount++,
            onError: (error) => lastError = error,
          );
    }

    if (!mounted) return;
    context.hideLoading();
    setState(() => _isSubmitting = false);

    if (successCount == _selectedServiceIds.length) {
      context.showToast('Services added successfully!');
      // Navigate to home / dashboard
      context.go('/');
    } else if (lastError != null) {
      context.showError(lastError!, title: 'Some services could not be added');
    }
  }
}

// ---------------------------------------------------------------------------
// Service Tile Widget
// ---------------------------------------------------------------------------

class _ServiceTile extends StatefulWidget {
  final Service service;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;
  final int index;

  const _ServiceTile({
    required this.service,
    required this.isSelected,
    required this.isDisabled,
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

    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
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
        child: GestureDetector(
          onTap: widget.isDisabled ? null : widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: AppSpacing.pAllMd,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : widget.isDisabled
                  ? AppColors.surface.withValues(alpha: 0.5)
                  : AppColors.surface,
              borderRadius: AppDecorations.radiusMd,
              border: Border.all(
                color: widget.isSelected ? AppColors.primary : AppColors.border,
                width: widget.isSelected ? 1.5.r : 1.r,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Service icon
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : AppColors.background,
                    borderRadius: AppDecorations.radiusSm,
                    border: Border.all(
                      color: widget.isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.4)
                          : AppColors.border,
                      width: 1.r,
                    ),
                  ),
                  child: Icon(
                    Icons.build_circle_outlined,
                    color: widget.isSelected
                        ? AppColors.primaryLight
                        : AppColors.textMuted,
                    size: 22.r,
                  ),
                ),
                AppSpacing.wMd,

                // Service details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name ?? 'Unnamed Service',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: widget.isDisabled
                              ? AppColors.textMuted
                              : widget.isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.service.category?.name != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          widget.service.category!.name!,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
