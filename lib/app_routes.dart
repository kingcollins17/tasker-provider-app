import 'package:go_router/go_router.dart';
import 'core/router/navigator_keys.dart';
import 'features/home/home_routes.dart';
import 'features/tasks/tasks_routes.dart';
import 'features/profile/profile_routes.dart';
import 'features/shell/presentation/shell_screen.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/onboard_categories_screen.dart';
import 'features/auth/presentation/onboard_services_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String welcomeRoute = 'welcome';
  static const String loginRoute = 'login';
  static const String registerRoute = 'register';
  static const String onboardCategoriesRoute = 'onboard-categories';
  static const String onboardServicesRoute = 'onboard-services';

  static final router = GoRouter(
    navigatorKey: NavigatorKeys.rootNavigatorKey,
    initialLocation: '/welcome',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: NavigatorKeys.shellNavigatorKey,
            routes: HomeRoutes.routes,
          ),
          StatefulShellBranch(routes: TasksRoutes.routes),
          StatefulShellBranch(routes: ProfileRoutes.routes),
        ],
      ),
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
      GoRoute(
        path: '/onboard-categories',
        name: onboardCategoriesRoute,
        builder: (context, state) => const OnboardCategoriesScreen(),
      ),
      GoRoute(
        path: '/onboard-services',
        name: onboardServicesRoute,
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['categoryId']
              ?.toString();
          return OnboardServicesScreen(categoryId: categoryId);
        },
      ),
    ],
  );
}
