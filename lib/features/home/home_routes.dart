import 'package:go_router/go_router.dart';
import 'presentation/home_screen.dart';
import 'presentation/offers_screen.dart';

class HomeRoutes {
  static const String homeRoute = 'home';
  static const String offersRoute = 'offers';

  static final routes = [
    GoRoute(
      path: '/',
      name: homeRoute,
      builder: (context, state) => const HomeScreen(),
    ),
  ];

  static final offersRoutes = [
    GoRoute(
      path: '/offers',
      name: offersRoute,
      builder: (context, state) => const OffersScreen(),
    ),
  ];
}

