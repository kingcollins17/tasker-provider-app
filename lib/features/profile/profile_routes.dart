import 'package:go_router/go_router.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'presentation/profile_screen.dart';
import 'presentation/profile_update_screen.dart';
import 'presentation/update_availability_screen.dart';
import 'presentation/update_payout_account_screen.dart';
import 'presentation/view_payout_account_screen.dart';

class ProfileRoutes {
  static const String profileRoute = 'profile';
  static const String updateProfileRoute = 'update-profile';
  static const String viewPayoutAccountRoute = 'view-payout-account';
  static const String updatePayoutAccountRoute = 'update-payout-account';
  static const String updateAvailabilityRoute = 'update-availability';

  static final routes = [
    GoRoute(
      path: '/profile',
      name: profileRoute,
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
          path: 'update',
          name: updateProfileRoute,
          builder: (context, state) {
            final params = state.uri.queryParameters;
            return ProfileUpdateScreen(
              firstName:
                  params['first_name'] ??
                  params['firstname'] ??
                  params['firstName'],
              lastName:
                  params['last_name'] ??
                  params['lastname'] ??
                  params['lastName'],
              phoneNumber:
                  params['phone_number'] ??
                  params['phonenumber'] ??
                  params['phoneNumber'],
              gender: params['gender'],
            );
          },
        ),

        GoRoute(
          parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
          path: 'view-payout-account',
          name: viewPayoutAccountRoute,
          builder: (context, state) => const ViewPayoutAccountScreen(),
        ),

        GoRoute(
          parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
          path: 'update-payout-account',
          name: updatePayoutAccountRoute,
          builder: (context, state) => const UpdatePayoutAccountScreen(),
        ),

        GoRoute(
          parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
          path: 'update-availability',
          name: updateAvailabilityRoute,
          builder: (context, state) => const UpdateAvailabilityScreen(),
        ),
      ],
    ),
  ];
}
