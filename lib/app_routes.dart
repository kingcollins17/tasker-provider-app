import 'package:go_router/go_router.dart';
import 'features/home/home_routes.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String welcomeRoute = 'welcome';
  static const String loginRoute = 'login';
  static const String registerRoute = 'register';

  static final router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      ...HomeRoutes.routes,
      GoRoute(
        path: '/welcome',
        name: welcomeRoute,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: registerRoute,
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
}
