import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/ui/designs/designs.dart';
import '../support_routes.dart';

class SupportCasesScreen extends ConsumerStatefulWidget {
  const SupportCasesScreen({super.key});

  @override
  ConsumerState<SupportCasesScreen> createState() => _SupportCasesScreenState();
}

class _SupportCasesScreenState extends ConsumerState<SupportCasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          'Support Tickets',
          style: AppTextStyles.h3.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(42.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 36.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.grey[100]!,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: isDark ? 0.3 : 0.6),
                  width: 1.r,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                dividerHeight: 0,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor:
                    isDark ? AppColors.textMuted : Colors.grey[600]!,
                labelStyle: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5.sp,
                ),
                unselectedLabelStyle: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 11.5.sp,
                ),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Open'),
                  Tab(text: 'Closed'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _SupportCasesTabList(statusFilter: null),
            _SupportCasesTabList(statusFilter: 'open'),
            _SupportCasesTabList(statusFilter: 'closed'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(SupportRoutes.createCaseRoute),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.edit_note_rounded, color: Colors.white, size: 18.r),
        label: Text(
          'New Ticket',
          style: AppTextStyles.buttonMedium.copyWith(
            color: Colors.white,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}

class _SupportCasesTabList extends ConsumerStatefulWidget {
  final String? statusFilter;

  const _SupportCasesTabList({this.statusFilter});

  @override
  ConsumerState<_SupportCasesTabList> createState() =>
      __SupportCasesTabListState();
}

class __SupportCasesTabListState extends ConsumerState<_SupportCasesTabList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(customerSupportNotifierProvider(widget.statusFilter).notifier)
          .fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final casesAsync =
        ref.watch(customerSupportNotifierProvider(widget.statusFilter));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await ref
            .read(
              customerSupportNotifierProvider(widget.statusFilter).notifier,
            )
            .refresh();
      },
      child: casesAsync.when(
        data: (cases) {
          if (cases.isEmpty) {
            return _buildEmptyState(isDark);
          }

          final notifier = ref.read(
            customerSupportNotifierProvider(widget.statusFilter).notifier,
          );
          final isLoadingMore = notifier.isLoadingMore;

          return ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
            itemCount: cases.length + (isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              if (index >= cases.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final item = cases[index];
              return _buildCaseCard(context, item, isDark);
            },
          );
        },
        loading: () => _buildShimmerList(isDark),
        error: (err, st) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(32.r),
            height: 400.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 40.r,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Failed to load tickets',
                    style: AppTextStyles.h3.copyWith(fontSize: 15.sp),
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(customerSupportNotifierProvider(
                                  widget.statusFilter)
                              .notifier)
                          .refresh();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, SupportCase item, bool isDark) {
    final theme = Theme.of(context);
    final statusStr = (item.status ?? 'OPEN').toUpperCase().trim();
    final isClosed = statusStr == 'CLOSED' || statusStr == 'RESOLVED';

    final statusColor = isClosed
        ? Colors.grey
        : statusStr == 'IN_PROGRESS' || statusStr == 'PENDING'
            ? AppColors.warning
            : AppColors.primary;

    final formattedDate = item.createdAt != null
        ? DateFormat.yMMMd().add_jm().format(item.createdAt!)
        : 'Recently';

    return GestureDetector(
      onTap: () {
        if (item.id != null) {
          context.pushNamed(
            SupportRoutes.caseDetailsRoute,
            pathParameters: {'caseId': item.id!},
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(
            color: isClosed
                ? AppColors.border
                : statusColor.withValues(alpha: 0.3),
            width: 1.r,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: isDark ? 0.08 : 0.04),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    (item.type ?? 'GENERAL').replaceAll('_', ' '),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5.sp,
                    ),
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    statusStr,
                    style: AppTextStyles.label.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              item.subject ?? 'No Subject',
              style: AppTextStyles.h3.copyWith(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (item.description != null &&
                item.description!.trim().isNotEmpty) ...[
              SizedBox(height: 3.h),
              Text(
                item.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11.5.sp,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12.r,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      formattedDate,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 18.r,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: EdgeInsets.all(32.r),
        height: 450.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70.r,
                height: 70.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  size: 36.r,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No Tickets Found',
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                'You have no ${widget.statusFilter ?? ''} support tickets at the moment.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList(bool isDark) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surface;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) => Container(
          height: 110.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: AppDecorations.radiusLg,
            border: Border.all(color: AppColors.border, width: 1.r),
          ),
        ),
      ),
    );
  }
}
