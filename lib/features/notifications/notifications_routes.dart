import 'package:go_router/go_router.dart';
import '../../core/router/navigator_keys.dart';
import 'presentation/notifications_screen.dart';

class NotificationsRoutes {
  static const String notificationsRoute = 'notifications';

  static final routes = [
    GoRoute(
      parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
      path: '/notifications',
      name: notificationsRoute,
      builder: (context, state) => const NotificationsScreen(),
    ),
  ];
}
