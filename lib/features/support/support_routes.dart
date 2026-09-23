import 'package:go_router/go_router.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'presentation/create_support_case_screen.dart';
import 'presentation/support_case_chat_screen.dart';
import 'presentation/support_case_detail_screen.dart';
import 'presentation/support_cases_screen.dart';

/// Route definitions for support feature screens.
class SupportRoutes {
  SupportRoutes._();

  static const String supportCasesRoute = 'support-cases';
  static const String createCaseRoute = 'create-support-case';
  static const String caseDetailsRoute = 'case-details';
  static const String caseChatRoute = 'case-chat';

  static final routes = <GoRoute>[
    GoRoute(
      parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
      path: '/support',
      name: supportCasesRoute,
      builder: (context, state) => const SupportCasesScreen(),
      routes: [
        GoRoute(
          parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
          path: 'create',
          name: createCaseRoute,
          builder: (context, state) {
            final params = state.uri.queryParameters;
            return CreateSupportCaseScreen(
              taskId: params['taskId'] ?? params['task_id'],
              assignmentId: params['assignmentId'] ?? params['assignment_id'],
              payoutId: params['payoutId'] ?? params['payout_id'],
              initialType: params['type'],
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
          path: ':caseId',
          name: caseDetailsRoute,
          builder: (context, state) {
            final caseId = state.pathParameters['caseId'] ?? '';
            return SupportCaseDetailScreen(caseId: caseId);
          },
          routes: [
            GoRoute(
              parentNavigatorKey: NavigatorKeys.rootNavigatorKey,
              path: 'chat',
              name: caseChatRoute,
              builder: (context, state) {
                final caseId = state.pathParameters['caseId'] ?? '';
                return SupportCaseChatScreen(caseId: caseId);
              },
            ),
          ],
        ),
      ],
    ),
  ];
}
