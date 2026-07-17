import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:badges/badges.dart' as badges;
import '../../../../core/ui/designs/colors.dart';
import '../../../../core/providers/notifications_provider.dart';
import '../../notifications_routes.dart';

class NotificationIcon extends ConsumerWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final unreadCount = state.value?.counts?.unread ?? 0;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.pushNamed(NotificationsRoutes.notificationsRoute),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: badges.Badge(
            showBadge: unreadCount > 0,
            badgeContent: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            badgeStyle: badges.BadgeStyle(
              badgeColor: AppColors.error,
              padding: EdgeInsets.all(4.r),
            ),
            position: badges.BadgePosition.topEnd(top: -8, end: -6),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedNotification01,
              color: theme.colorScheme.onSurface,
              size: 24.r,
            ),
          ),
        ),
      ),
    );
  }
}
