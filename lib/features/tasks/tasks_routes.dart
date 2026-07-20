import 'package:go_router/go_router.dart';
import 'presentation/tasks_screen.dart';
import 'presentation/task_detail_screen.dart';

class TasksRoutes {
  static const String tasksRoute = 'tasks';
  static const String taskDetailRoute = 'task-detail';

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
  ];
}
