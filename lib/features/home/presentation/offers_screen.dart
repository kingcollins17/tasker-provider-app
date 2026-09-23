import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tasker_app/core/utils/extensions/error_ext.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/ui/designs/colors.dart';
import '../../../core/ui/designs/text_styles.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/utils/extensions/num_ext.dart';
import '../../../features/tasks/presentation/widgets/offer_ping_bottom_sheet.dart';

/// Screen displaying active and pending task dispatch offers for the provider.
class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll - 200)) {
      ref.read(offersNotifierProvider.notifier).fetchMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(offersNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final offersAsync = ref.watch(offersNotifierProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: context.canPop() ? const BackButton() : null,
        centerTitle: false,
        title: Text(
          'Offers',
          style: AppTextStyles.h3.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: AppTextField(
                controller: _searchController,
                hintText: 'Search offers...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                  size: 20.r,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.cancel_rounded,
                          color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
                          size: 18.r,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),

            // Content Area
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _onRefresh,
                child: offersAsync.when(
                  loading: () => _ShimmerList(isDark: isDark),
                  error: (err, _) => _buildErrorState(isDark, err.toString()),
                  data: (rawOffers) {
                    final offers = _searchQuery.isEmpty
                        ? rawOffers
                        : rawOffers.where((offer) {
                            final title = offer.task?.title?.toLowerCase() ?? '';
                            final catName =
                                offer.task?.category?.name?.toLowerCase() ?? '';
                            final serviceName =
                                offer.task?.service?.name?.toLowerCase() ?? '';
                            final desc =
                                offer.task?.description?.toLowerCase() ?? '';
                            final id = offer.id?.toLowerCase() ?? '';
                            return title.contains(_searchQuery) ||
                                catName.contains(_searchQuery) ||
                                serviceName.contains(_searchQuery) ||
                                desc.contains(_searchQuery) ||
                                id.contains(_searchQuery);
                          }).toList();

                    if (offers.isEmpty) {
                      return _buildEmptyState(
                        isDark,
                        isSearching: _searchQuery.isNotEmpty,
                      );
                    }

                    final isLoadingMore = ref
                        .read(offersNotifierProvider.notifier)
                        .isLoadingMore;

                    final totalCount = offers.length + (isLoadingMore ? 1 : 0);

                    return ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemCount: totalCount * 2 - 1,
                      itemBuilder: (context, index) {
                        if (index.isOdd) {
                          return Divider(
                            height: 1,
                            thickness: 1,
                            indent: 16.w,
                            endIndent: 16.w,
                            color: isDark
                                ? AppColors.border
                                : Colors.grey.withValues(alpha: 0.12),
                          );
                        }

                        final itemIndex = index ~/ 2;
                        if (itemIndex == offers.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        }

                        final offer = offers[itemIndex];
                        return _OfferTile(
                          offer: offer,
                          isDark: isDark,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, {bool isSearching = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76.r,
                      height: 76.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: isSearching
                              ? HugeIcons.strokeRoundedSearch01
                              : HugeIcons.strokeRoundedTag01,
                          color: AppColors.primary,
                          size: 38.r,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      isSearching ? 'No Matching Offers' : 'No Active Offers',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isSearching
                          ? 'No task dispatches match "$_searchQuery". Try searching with a different term.'
                          : 'New task dispatches and exclusive provider offers will appear here automatically when available.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.sp,
                        color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(bool isDark, String error) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48.r,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Failed to load offers',
                      style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      error.toFriendlyString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton.icon(
                      onPressed: _onRefresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OfferTile extends ConsumerWidget {
  final Offer offer;
  final bool isDark;

  const _OfferTile({
    required this.offer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = offer.task;
    final title = task?.title ?? 'Job Offer #${offer.id?.substring(0, 6) ?? ''}';
    final payout = offer.offeredPayout ?? task?.providerPayout ?? task?.customerTotalPrice;
    final payoutStr = payout != null ? payout.toNaira(2) : '—';
    final categoryName = task?.category?.name ?? task?.service?.name ?? 'Task Offer';
    final expiresAt = offer.expiresAt;
    final expiryText = _formatExpiry(expiresAt);
    final avatarProps = _getAvatarProps(title, categoryName);

    return InkWell(
      onTap: () async {
        if (offer.taskId != null) {
          final res = await OfferPingBottomSheet.show(
            offer.taskId!,
            expiresAt: offer.expiresAt,
          );
          if (res == true) {
            ref.invalidate(offersNotifierProvider);
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Category / Service Avatar
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: isDark
                    ? avatarProps.bgColor.withValues(alpha: 0.16)
                    : avatarProps.bgColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  avatarProps.icon,
                  size: 18.r,
                  color: avatarProps.bgColor,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Title & Category/Expiry Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: isDark ? AppColors.textPrimary : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          categoryName,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (expiryText != null) ...[
                        SizedBox(width: 6.w),
                        Container(
                          width: 3.r,
                          height: 3.r,
                          decoration: const BoxDecoration(
                            color: AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.timer_outlined,
                          size: 13.r,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          expiryText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),

            // Payout & View Offer
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  payoutStr,
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: const Color(0xFF00B368),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5.sp,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14.r,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _AvatarProps _getAvatarProps(String title, String category) {
    final lower = '$title $category'.toLowerCase().trim();
    if (lower.contains('carpet') || lower.contains('upholstery') || lower.contains('clean')) {
      return const _AvatarProps(
        bgColor: Color(0xFF627EEA),
        icon: Icons.cleaning_services_rounded,
      );
    } else if (lower.contains('office') || lower.contains('commercial')) {
      return const _AvatarProps(
        bgColor: Color(0xFF8B5CF6),
        icon: Icons.business_center_rounded,
      );
    } else if (lower.contains('home') || lower.contains('house') || lower.contains('standard')) {
      return const _AvatarProps(
        bgColor: Color(0xFF26A17B),
        icon: Icons.home_repair_service_rounded,
      );
    } else if (lower.contains('plumb')) {
      return const _AvatarProps(
        bgColor: Color(0xFF0EA5E9),
        icon: Icons.plumbing_rounded,
      );
    } else if (lower.contains('electric')) {
      return const _AvatarProps(
        bgColor: Color(0xFF007D5A),
        icon: Icons.electrical_services_rounded,
      );
    } else if (lower.contains('handyman') || lower.contains('fix') || lower.contains('repair')) {
      return const _AvatarProps(
        bgColor: Color(0xFFF7931A),
        icon: Icons.build_rounded,
      );
    }

    final palette = const [
      (Color(0xFF627EEA), Icons.cleaning_services_rounded),
      (Color(0xFF8B5CF6), Icons.business_center_rounded),
      (Color(0xFF26A17B), Icons.home_repair_service_rounded),
      (Color(0xFF007D5A), Icons.electrical_services_rounded),
      (Color(0xFF0EA5E9), Icons.plumbing_rounded),
      (Color(0xFFF7931A), Icons.build_rounded),
      (Color(0xFFF3BA2F), Icons.work_rounded),
    ];
    final selected = palette[lower.hashCode.abs() % palette.length];
    return _AvatarProps(
      bgColor: selected.$1,
      icon: selected.$2,
    );
  }

  String? _formatExpiry(DateTime? expiresAt) {
    if (expiresAt == null) return null;
    final diff = expiresAt.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    }
    return '${diff.inMinutes}m left';
  }
}

class _AvatarProps {
  final Color bgColor;
  final IconData icon;

  const _AvatarProps({
    required this.bgColor,
    required this.icon,
  });
}

class _ShimmerList extends StatelessWidget {
  final bool isDark;

  const _ShimmerList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(bottom: 20.h),
        itemCount: 8 * 2 - 1,
        itemBuilder: (_, index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              thickness: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: isDark
                  ? AppColors.border
                  : Colors.grey.withValues(alpha: 0.12),
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 130.w,
                        height: 14.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 80.w,
                        height: 10.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 60.w,
                      height: 14.h,
                      color: Colors.white,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 40.w,
                      height: 12.h,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
