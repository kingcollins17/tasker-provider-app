import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/ui/designs/colors.dart';
import '../../../core/ui/designs/text_styles.dart';
import '../../../core/ui/designs/decorations.dart';
import '../../../core/ui/designs/spacing.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/providers/region_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressAsync = ref.watch(userAddressProvider);
    final regionAsync = ref.watch(currentRegionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),

              // ── Greeting header ──
              Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 24.r,
                    ),
                  ),
                  AppSpacing.wMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back 👋', style: AppTextStyles.bodySmall),
                        SizedBox(height: 2.h),
                        Text(
                          'Dashboard',
                          style: AppTextStyles.h3,
                        ),
                      ],
                    ),
                  ),
                  // Notification bell placeholder
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.r),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textSecondary,
                      size: 20.r,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              // ── Your Location section ──
              Text(
                'YOUR LOCATION',
                style: AppTextStyles.labelUppercase.copyWith(
                  color: AppColors.primaryLight,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 12.h),

              // Address card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: AppDecorations.containerElevated,
                child: addressAsync.when(
                  loading: () => _buildLoadingTile(
                    icon: Icons.location_on_outlined,
                    label: 'Fetching your address…',
                  ),
                  error: (err, _) => _buildErrorTile(
                    icon: Icons.location_off_outlined,
                    message: err.toString(),
                    onRetry: () => ref.invalidate(userAddressProvider),
                  ),
                  data: (address) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: AppDecorations.radiusSm,
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primaryLight,
                              size: 22.r,
                            ),
                          ),
                          AppSpacing.wMd,
                          Expanded(
                            child: Text(
                              'Current Address',
                              style: AppTextStyles.subtitle.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _InfoRow(
                        label: 'Street',
                        value: address.street ?? '—',
                      ),
                      _InfoRow(
                        label: 'City',
                        value: address.locality ?? '—',
                      ),
                      _InfoRow(
                        label: 'State',
                        value: address.administrativeArea ?? '—',
                      ),
                      _InfoRow(
                        label: 'Postal Code',
                        value: address.postalCode ?? '—',
                      ),
                      _InfoRow(
                        label: 'Country',
                        value: address.country ?? '—',
                        showDivider: false,
                      ),
                      if (address.coordinates != null) ...[
                        SizedBox(height: 12.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppDecorations.radiusSm,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.gps_fixed_rounded,
                                color: AppColors.textMuted,
                                size: 14.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  '${address.coordinates!.latitude?.toStringAsFixed(6)}, '
                                  '${address.coordinates!.longitude?.toStringAsFixed(6)}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontFamily: 'monospace',
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // ── Current Region section ──
              Text(
                'MATCHED REGION',
                style: AppTextStyles.labelUppercase.copyWith(
                  color: AppColors.primaryLight,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 12.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: AppDecorations.containerElevated,
                child: regionAsync.when(
                  loading: () => _buildLoadingTile(
                    icon: Icons.map_outlined,
                    label: 'Resolving your region…',
                  ),
                  error: (err, _) => _buildErrorTile(
                    icon: Icons.map_outlined,
                    message: err.toString(),
                    onRetry: () => ref.invalidate(currentRegionProvider),
                  ),
                  data: (region) {
                    if (region == null) {
                      return _buildEmptyTile(
                        icon: Icons.wrong_location_outlined,
                        message:
                            'No matching region found for your current location.',
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.12),
                                borderRadius: AppDecorations.radiusSm,
                              ),
                              child: Icon(
                                Icons.map_rounded,
                                color: AppColors.success,
                                size: 22.r,
                              ),
                            ),
                            AppSpacing.wMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    region.state ?? 'Unknown Region',
                                    style: AppTextStyles.subtitle.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (region.isActive == true)
                                    SizedBox(height: 4.h),
                                  if (region.isActive == true)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        'ACTIVE',
                                        style:
                                            AppTextStyles.labelUppercase
                                                .copyWith(
                                                  color: AppColors.success,
                                                  fontSize: 9.sp,
                                                ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _InfoRow(
                          label: 'Address',
                          value: region.addressLine ?? '—',
                        ),
                        _InfoRow(
                          label: 'Region ID',
                          value: region.id ?? '—',
                        ),
                        _InfoRow(
                          label: 'Providers',
                          value: '${region.totalProviders ?? 0}',
                        ),
                        _InfoRow(
                          label: 'Customers',
                          value: '${region.totalCustomers ?? 0}',
                        ),
                        _InfoRow(
                          label: 'Tasks',
                          value: '${region.totalTasks ?? 0}',
                          showDivider: false,
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 24.h),

              // ── Refresh button ──
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ref.invalidate(userCoordinatesProvider);
                    ref.invalidate(userAddressProvider);
                    ref.invalidate(currentRegionProvider);
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 18.r,
                    color: AppColors.primaryLight,
                  ),
                  label: Text(
                    'Refresh Location',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Shared tile builders ──

  Widget _buildLoadingTile({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20.r,
          height: 20.r,
          child: CircularProgressIndicator(
            strokeWidth: 2.r,
            color: AppColors.primaryLight,
          ),
        ),
        SizedBox(width: 12.w),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildErrorTile({
    required IconData icon,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.error, size: 20.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (onRetry != null) ...[
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'Tap to retry',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyTile({
    required IconData icon,
    required String message,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.warning, size: 22.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable info row widget ──

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.w,
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1.h,
            color: AppColors.border.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
