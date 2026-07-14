import 'package:go_router/go_router.dart';
import 'presentation/chats_screen.dart';

class ChatsRoutes {
  ChatsRoutes._();

  static const String chatsRoute = 'chats';

  static final routes = [
    GoRoute(
      path: '/chats',
      name: chatsRoute,
      builder: (context, state) => const ChatsScreen(),
    ),
  ];
}
