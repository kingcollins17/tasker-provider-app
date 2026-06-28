import 'package:go_router/go_router.dart';
import 'presentation/home_screen.dart';

class HomeRoutes {
  static const String homeRoute = 'home';

  static final routes = [
    GoRoute(
      path: '/',
      name: homeRoute,
      builder: (context, state) => const HomeScreen(),
    ),
  ];
}
