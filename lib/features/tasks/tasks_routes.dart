import 'package:go_router/go_router.dart';
import 'presentation/tasks_screen.dart';
import 'presentation/task_detail_screen.dart';
import 'presentation/pin_entry_screen.dart';

class TasksRoutes {
  static const String tasksRoute = 'tasks';
  static const String taskDetailRoute = 'task-detail';
  static const String pinEntryRoute = 'pin-entry';

  static final routes = [
    GoRoute(
      path: '/tasks',
      name: tasksRoute,
      builder: (context, state) => const TasksScreen(),
    ),
  ];

  /// Top-level routes (outside the shell) for full-screen task detail.
  static final detailRoutes = [
    GoRoute(
      path: '/tasks/:taskId',
      name: taskDetailRoute,
      builder: (context, state) {
        final taskId = state.pathParameters['taskId']!;
        final distance = state.uri.queryParameters['distance'];
        return TaskDetailScreen(taskId: taskId, distance: distance);
      },
    ),
    GoRoute(
      path: '/tasks/:taskId/pin-entry',
      name: pinEntryRoute,
      builder: (context, state) {
        final taskId = state.pathParameters['taskId'] ?? state.uri.queryParameters['taskId'];
        final mode = state.uri.queryParameters['mode'];
        final isInitialCashStr = state.uri.queryParameters['isInitialCash'];
        final isInitialCash = isInitialCashStr != 'false';

        return PinEntryScreen(
          taskId: taskId,
          mode: mode,
          isInitialCash: isInitialCash,
        );
      },
    ),
  ];
}
