import 'package:go_router/go_router.dart';
import 'presentation/profile_screen.dart';

class ProfileRoutes {
  static const String profileRoute = 'profile';

  static final routes = [
    GoRoute(
      path: '/profile',
      name: profileRoute,
      builder: (context, state) => const ProfileScreen(),
    ),
  ];
}
