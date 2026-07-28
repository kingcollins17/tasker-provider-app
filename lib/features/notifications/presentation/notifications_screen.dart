import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/utils/extensions/flushbar_context_ext.dart';
import 'package:tasker_app/core/utils/extensions/loading_context_ext.dart';
import 'package:tasker_app/core/providers/notifications_provider.dart';

import '../../../../core/models/api/notifications/notification_item.dart';
import '../../../../core/ui/designs/designs.dart';


enum NotificationFilter { all, unread }

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationFilter _filter = NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final items = state.value?.paginatedData?.items ?? [];

    // Filter items
    final filteredItems = _filter == NotificationFilter.unread
        ? items.where((item) => !item.isRead).toList()
        : items;

    // Group items by date
    final groupedItems = _groupNotifications(filteredItems);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Notifications', style: AppTextStyles.h2),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filters row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filter == NotificationFilter.all,
                  onTap: () => setState(() => _filter = NotificationFilter.all),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'Unread',
                  isSelected: _filter == NotificationFilter.unread,
                  onTap: () =>
                      setState(() => _filter = NotificationFilter.unread),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final unreadIds = items
                        .where((i) => !i.isRead && i.notificationId != null)
                        .map((i) => i.notificationId!)
                        .toList();
                    if (unreadIds.isNotEmpty) {
                      context.showLoading();
                      await ref
                          .read(notificationsProvider.notifier)
                          .markAsRead(
                            unreadIds,
                            onError: (err) {
                              context.showError(err);
                            },
                          );
                      context.hideLoading();
                    }
                  },
                  child: Text(
                    'Mark all as read',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: state.isLoading && items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No notifications',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 8.h,
                    ),
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final group = groupedItems[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16.h, bottom: 12.h),
                            child: Text(
                              group.key,
                              style: AppTextStyles.subtitle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...group.value.map(
                            (item) => _NotificationTile(item: item),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, List<NotificationItem>>> _groupNotifications(
    List<NotificationItem> items,
  ) {
    final Map<String, List<NotificationItem>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final date = item.createdAt ?? DateTime.now();
      final itemDay = DateTime(date.year, date.month, date.day);

      String key;
      if (itemDay == today) {
        key = 'Today';
      } else if (itemDay == yesterday) {
        key = 'Yesterday';
      } else {
        key = '${date.day}/${date.month}/${date.year}';
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(item);
    }

    return groups.entries.toList();
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const _NotificationTile({required this.item});

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60)
      return '${diff.inSeconds} sec${diff.inSeconds == 1 ? '' : 's'} ago';
    if (diff.inMinutes < 60)
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    if (diff.inHours < 24)
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return '1 day ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    // Generate an icon and color based on type or fallback
    IconData iconData = Icons.notifications_rounded;
    Color iconColor = AppColors.primary;

    final title = item.title?.toLowerCase() ?? '';
    if (title.contains('prescription') || title.contains('medical')) {
      iconData = Icons.medical_information_outlined;
      iconColor = AppColors.success;
    } else if (title.contains('priority') || title.contains('urgent')) {
      iconData = Icons.flag_outlined;
      iconColor = AppColors.error;
    } else if (title.contains('payment') || title.contains('invoice')) {
      iconData = Icons.payment_outlined;
      iconColor = AppColors.primaryLight;
    } else if (title.contains('welcome')) {
      iconData = Icons.person_outline_rounded;
      iconColor = Colors.blue;
    } else if (title.contains('otp') ||
        title.contains('verification') ||
        title.contains('password')) {
      iconData = Icons.lock_outline_rounded;
      iconColor = AppColors.primary;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 24.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              item.title ?? 'Notification',
                              style: AppTextStyles.subtitle.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!item.isRead) ...[
                            SizedBox(width: 6.w),
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      item.createdAt != null
                          ? _formatTimeAgo(item.createdAt!)
                          : '',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.body ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
