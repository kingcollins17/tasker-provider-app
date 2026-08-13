import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/providers/services_editor_provider.dart';
import '../../../core/providers/services_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';

class EditServicesScreen extends ConsumerStatefulWidget {
  const EditServicesScreen({super.key});

  @override
  ConsumerState<EditServicesScreen> createState() => _EditServicesScreenState();
}

class _EditServicesScreenState extends ConsumerState<EditServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userServices = await ref.read(userServicesProvider.future);
      final initialIds = userServices
          .map((s) => s.id)
          .whereType<String>()
          .toSet();
      ref
          .read(servicesEditorProvider.notifier)
          .initialize(selected: initialIds);
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final editorState = ref.watch(servicesEditorProvider);

    final categoriesAsync = ref.watch(categoriesProvider(null));
    final servicesAsync = ref.watch(
      servicesProvider((
        search: _searchQuery.isEmpty ? null : _searchQuery,
        categoryId: _selectedCategoryId,
      )),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: Text(
          'Edit My Services',

          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search & Filter Section ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Column(
                children: [
                  // Search TextField
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surface
                          : theme.cardColor,
                      borderRadius: AppDecorations.radiusMd,
                      border: Border.all(
                        color: isDark
                            ? AppColors.border
                            : AppColors.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search services...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 20.r,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  size: 18.r,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Category Filter Chips
                  categoriesAsync.maybeWhen(
                    data: (categories) => SizedBox(
                      height: 36.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryChip(
                            label: 'All Categories',
                            isSelected: _selectedCategoryId == null,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                            },
                            isDark: isDark,
                          ),
                          ...categories.map((cat) {
                            if (cat.id == null) return const SizedBox.shrink();
                            return _buildCategoryChip(
                              label: cat.name ?? 'Category',
                              isSelected: _selectedCategoryId == cat.id,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId =
                                      _selectedCategoryId == cat.id
                                      ? null
                                      : cat.id;
                                });
                              },
                              isDark: isDark,
                            );
                          }),
                        ],
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // ── Selected Counter Bar ─────────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppDecorations.radiusMd,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '${editorState.selected.length} service${editorState.selected.length == 1 ? '' : 's'} selected',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (editorState.selected.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        ref.read(servicesEditorProvider.notifier).reset();
                      },
                      child: Text(
                        'Clear All',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Services List ───────────────────────────────────────────
            Expanded(
              child: !_initialized
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : servicesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                      error: (err, _) => Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.r),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.error,
                                size: 40.r,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Failed to load services',
                                style: AppTextStyles.subtitle.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                err.toString(),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 16.h),
                              PrimaryButton(
                                text: 'Retry',
                                isFullWidth: false,
                                onPressed: () {
                                  ref.invalidate(
                                    servicesProvider((
                                      search: _searchQuery.isEmpty
                                          ? null
                                          : _searchQuery,
                                      categoryId: _selectedCategoryId,
                                    )),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (services) {
                        if (services.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  color: AppColors.textMuted,
                                  size: 48.r,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'No services found',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Try adjusting your search or filter',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          physics: const BouncingScrollPhysics(),
                          itemCount: services.length,
                          separatorBuilder: (_, _) => SizedBox(height: 6.h),
                          itemBuilder: (context, index) {
                            final service = services[index];
                            final serviceId = service.id;
                            if (serviceId == null)
                              return const SizedBox.shrink();

                            final isSelected = editorState.isSelected(
                              serviceId,
                            );

                            return _ServiceSelectionCard(
                              service: service,
                              isSelected: isSelected,
                              isDark: isDark,
                              onToggle: () {
                                ref
                                    .read(servicesEditorProvider.notifier)
                                    .toggle(serviceId);
                              },
                            );
                          },
                        );
                      },
                    ),
            ),

            // ── Save Button ─────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: 'Save Changes',
                onPressed: () => _onSaveChanges(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.label.copyWith(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.textMuted : AppColors.textSecondary),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: isDark
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).cardColor,
        side: isSelected
            ? const BorderSide(color: AppColors.primary)
            : BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: AppDecorations.radiusXl),
      ),
    );
  }

  Future<void> _onSaveChanges(BuildContext context) async {
    context.showLoading();
    await ref
        .read(servicesEditorProvider.notifier)
        .saveChanges(
          onSuccess: () {
            ref.invalidate(userProvider);
            if (!context.mounted) return;
            context.hideLoading();

            context.pop();
          },
          onError: (err) {
            if (!context.mounted) return;
            context.hideLoading();
            context.showError(err);
          },
        );
  }
}

class _ServiceSelectionCard extends StatelessWidget {
  final Service service;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onToggle;

  const _ServiceSelectionCard({
    required this.service,
    required this.isSelected,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: AppDecorations.radiusMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.08)
                : theme.colorScheme.surface,
            borderRadius: AppDecorations.radiusMd,
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1.5.r)
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.r),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : (isDark
                            ? AppColors.border.withValues(alpha: 0.3)
                            : AppColors.border.withValues(alpha: 0.1)),
                  borderRadius: AppDecorations.radiusSm,
                ),
                child: Icon(
                  Icons.build_circle_outlined,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 18.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name ?? 'Unnamed Service',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    if (service.category?.name != null) ...[
                      SizedBox(height: 1.h),
                      Text(
                        service.category!.name!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10.5.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Checkbox(
                value: isSelected,
                activeColor: AppColors.primary,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
