import 'package:go_router/go_router.dart';
import 'presentation/tasks_screen.dart';

class TasksRoutes {
  static const String tasksRoute = 'tasks';

  static final routes = [
    GoRoute(
      path: '/tasks',
      name: tasksRoute,
      builder: (context, state) => const TasksScreen(),
    ),
  ];
}
