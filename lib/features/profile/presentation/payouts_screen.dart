import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/payments_provider.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/app_error_widget.dart';
import '../../../core/utils/extensions/num_ext.dart';

/// Main screen listing the user's provider payouts with filter chips,
/// pull-to-refresh, shimmer loading states, and infinite scrolling.
class PayoutsScreen extends ConsumerStatefulWidget {
  const PayoutsScreen({super.key});

  @override
  ConsumerState<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends ConsumerState<PayoutsScreen> {
  late final ScrollController _scrollController;
  String? _selectedStatus; // null for All

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(providerPayoutsProvider(_selectedStatus).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final payoutsAsync = ref.watch(providerPayoutsProvider(_selectedStatus));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          'Payouts',
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(providerEarningsStatsProvider(null));
          await ref
              .read(providerPayoutsProvider(_selectedStatus).notifier)
              .refresh();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Balance Card
              _HeroBalanceCard(isDark: isDark),
              SizedBox(height: 20.h),

              // Status Filter Chips
              _FilterChips(
                selectedStatus: _selectedStatus,
                isDark: isDark,
                onSelected: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
              ),
              SizedBox(height: 24.h),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Payouts',
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (payoutsAsync.value != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${payoutsAsync.value!.length} Items',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),

              // Content Area
              payoutsAsync.when(
                data: (payouts) {
                  if (payouts.isEmpty) {
                    return _EmptyState(
                      selectedStatus: _selectedStatus,
                      isDark: isDark,
                    );
                  }

                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: payouts.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 4.h),
                        itemBuilder: (context, index) {
                          final payout = payouts[index];
                          return _PayoutTile(
                            payout: payout,
                            isDark: isDark,
                            onTap: () => _PayoutDetailSheet.show(
                              context,
                              payout: payout,
                            ),
                          );
                        },
                      ),
                      if (payoutsAsync.isLoading) ...[
                        SizedBox(height: 20.h),
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => _ShimmerLoading(isDark: isDark),
                error: (error, stack) => _ErrorState(
                  error: error,
                  onRetry: () {
                    ref
                        .read(providerPayoutsProvider(_selectedStatus).notifier)
                        .refresh();
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ── HERO BALANCE CARD WIDGET ────────────────────────────────────────

class _HeroBalanceCard extends ConsumerWidget {
  final bool isDark;

  const _HeroBalanceCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(providerEarningsStatsProvider(null));

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: AppDecorations.radiusLg,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0F382B), const Color(0xFF00241B)]
              : [const Color(0xFFD8F3E5), const Color(0xFFB7EAD0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF007D5A)).withValues(
              alpha: 0.1,
            ),
            blurRadius: 16.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL PAYOUTS',
            style: AppTextStyles.labelUppercase.copyWith(
              color: isDark ? AppColors.textSecondary : const Color(0xFF1E523F),
              fontSize: 11.sp,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          earningsAsync.when(
            data: (earnings) => Text(
              (earnings.totalEarnings ?? 0.0).toNaira(2),
              style: AppTextStyles.h1.copyWith(
                color: isDark ? Colors.white : const Color(0xFF063828),
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => Shimmer.fromColors(
              baseColor: isDark ? const Color(0xFF0F382B) : Colors.white30,
              highlightColor: isDark ? Colors.white12 : Colors.white60,
              child: Container(
                width: 160.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            error: (e, st) => Text(
              0.0.toNaira(2),
              style: AppTextStyles.h1.copyWith(
                color: isDark ? Colors.white : const Color(0xFF063828),
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14.r,
                color: isDark
                    ? AppColors.primaryLight
                    : const Color(0xFF007D5A),
              ),
              SizedBox(width: 4.w),
              Text(
                'Direct Provider Settlement Queue',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : const Color(0xFF1E523F),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── FILTER CHIPS WIDGET ─────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final String? selectedStatus;
  final bool isDark;
  final ValueChanged<String?> onSelected;

  const _FilterChips({
    required this.selectedStatus,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {'label': 'All', 'value': null},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Processing', 'value': 'processing'},
      {'label': 'Failed', 'value': 'failed'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: statuses.map((item) {
          final value = item['value'];
          final label = item['label'] as String;
          final isSelected = selectedStatus == value;

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSelected(value);
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: isDark
                  ? AppColors.surface
                  : Colors.grey.shade100,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? AppColors.textSecondary
                          : const Color(0xFF475569)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.border : Colors.grey.shade300),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── PAYOUT TILE WIDGET (Transparent List Items) ─────────────────────

class _PayoutTile extends StatelessWidget {
  final Payout payout;
  final bool isDark;
  final VoidCallback onTap;

  const _PayoutTile({
    required this.payout,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amount = payout.payoutAmount ?? 0.0;
    final dateStr = payout.createdAt != null
        ? DateFormat('dd MMM yyyy').format(payout.createdAt!)
        : 'Recent';

    final titleText =
        payout.task?.title ??
        payout.description ??
        'Payout #${payout.reference ?? payout.id?.substring(0, 6) ?? ''}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDecorations.radiusLg,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h),
          child: Row(
            children: [
              // Icon Avatar Indicator
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(payout.status),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(payout.status),
                  color: _getIconColor(payout.status),
                  size: 20.r,
                ),
              ),
              SizedBox(width: 14.w),

              // Title and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: isDark
                            ? AppColors.textPrimary
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          dateStr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _StatusBadge(status: payout.status),
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                '+${amount.toNaira(2)}',
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'paid':
        return AppColors.success.withValues(alpha: 0.15);
      case 'pending':
      case 'processing':
        return AppColors.warning.withValues(alpha: 0.15);
      case 'failed':
        return AppColors.error.withValues(alpha: 0.15);
      default:
        return AppColors.primary.withValues(alpha: 0.15);
    }
  }

  Color _getIconColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'paid':
        return AppColors.success;
      case 'pending':
      case 'processing':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Icons.arrow_downward_rounded;
      case 'pending':
      case 'processing':
        return Icons.access_time_rounded;
      case 'failed':
        return Icons.warning_amber_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}

// ── STATUS BADGE WIDGET ─────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String? status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final statusText = status ?? 'Pending';
    Color bg = AppColors.warning.withValues(alpha: 0.15);
    Color text = AppColors.warning;

    switch (statusText.toLowerCase()) {
      case 'completed':
      case 'paid':
        bg = AppColors.success.withValues(alpha: 0.15);
        text = AppColors.success;
        break;
      case 'failed':
        bg = AppColors.error.withValues(alpha: 0.15);
        text = AppColors.error;
        break;
      case 'pending':
      case 'processing':
      default:
        bg = AppColors.warning.withValues(alpha: 0.15);
        text = AppColors.warning;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        statusText.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: text,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── SHIMMER LOADING WIDGET ──────────────────────────────────────────

class _ShimmerLoading extends StatelessWidget {
  final bool isDark;

  const _ShimmerLoading({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.surface : Colors.grey.shade300,
      highlightColor: isDark ? AppColors.border : Colors.grey.shade100,
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Container(
              height: 54.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.radiusLg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── EMPTY STATE WIDGET ──────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String? selectedStatus;
  final bool isDark;

  const _EmptyState({required this.selectedStatus, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 48.r,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Payouts Found',
              style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              selectedStatus != null
                  ? 'There are no $selectedStatus payouts in your queue.'
                  : 'You do not have any payout transactions yet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ERROR STATE WIDGET ──────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget.small(
      error: error,
      title: 'Failed to load payouts',
      onRetry: onRetry,
    );
  }
}

// ── PAYOUT DETAIL BOTTOM SHEET ──────────────────────────────────────

class _PayoutDetailSheet extends StatelessWidget {
  final Payout payout;

  const _PayoutDetailSheet({required this.payout});

  /// Presents the Payout Detail bottom sheet.
  static Future<void> show(BuildContext? context, {required Payout payout}) {
    final targetContext =
        context ?? NavigatorKeys.rootNavigatorKey.currentContext;
    if (targetContext == null) return Future.value();

    return showModalBottomSheet(
      context: targetContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PayoutDetailSheet(payout: payout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedDate = payout.createdAt != null
        ? DateFormat('MMM dd, yyyy · hh:mm a').format(payout.createdAt!)
        : 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.background : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DragHandle(),
          SizedBox(height: 20.h),

          // Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payout Details',
                style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
              ),
              _StatusBadge(status: payout.status),
            ],
          ),
          SizedBox(height: 20.h),

          // Hero Amount Card
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : const Color(0xFFF8FAFC),
              borderRadius: AppDecorations.radiusLg,
              border: Border.all(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAYOUT AMOUNT',
                      style: AppTextStyles.labelUppercase.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      (payout.payoutAmount ?? 0.0).toNaira(2),
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primary,
                  size: 32.r,
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Details Card Breakdown
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : Colors.white,
              borderRadius: AppDecorations.radiusLg,
              border: Border.all(
                color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _BottomSheetDetailRow(
                  label: 'Reference',
                  value: payout.reference ?? payout.id ?? 'N/A',
                  isDark: isDark,
                ),
                _divider(isDark),
                _BottomSheetDetailRow(
                  label: 'Task Title',
                  value: payout.task?.title ?? 'Service Task',
                  isDark: isDark,
                ),
                _divider(isDark),
                _BottomSheetDetailRow(
                  label: 'Customer Payment',
                  value: (payout.customerPaymentAmount ?? 0.0).toNaira(2),
                  isDark: isDark,
                ),
                _divider(isDark),
                _BottomSheetDetailRow(
                  label: 'Created At',
                  value: formattedDate,
                  isDark: isDark,
                ),
                if (payout.description != null &&
                    payout.description!.isNotEmpty) ...[
                  _divider(isDark),
                  _BottomSheetDetailRow(
                    label: 'Description',
                    value: payout.description!,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Close / Done Button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Close',
              style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Divider(
        height: 1.h,
        thickness: 1.h,
        color: isDark ? AppColors.border : const Color(0xFFF1F5F9),
      ),
    );
  }
}

// ── DRAG HANDLE WIDGET ──────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.border : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

// ── BOTTOM SHEET DETAIL ROW ────────────────────────────────────────

class _BottomSheetDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _BottomSheetDetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.textMuted : AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
