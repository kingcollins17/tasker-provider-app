import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api/api.dart';
import '../services/network_service.dart';
import '../services/local_storage_service.dart';
import '../services/web_socket_connection_handler.dart';
import '../services/device_tray.dart';
import 'notifications_provider.dart';

/// StreamProvider that maintains a WebSocket connection for notifications.
final notificationsWebSocketProvider = StreamProvider<NotificationItem>((
  ref,
) async* {
  final environments = ref.watch(environmentsProvider);
  final token = await appStorage.get<String>(HiveKeys.accessToken.name);

  if (token == null || token.isEmpty) {
    // If there is no token, we cannot connect to the websocket.
    return;
  }

  // Creating the connection handler.
  final handler = WebSocketConnectionHandler(
    url: 'wss://${environments.domain}/api/v1/notifications/ws?token=$token',
  );

  // Start the connection
  handler.connect();

  // Ensure we close and dispose the connection when the provider is disposed
  ref.onDispose(() {
    handler.dispose();
  });

  // Yield all incoming messages from the WebSocket
  await for (final message in handler.messageStream) {
    yield NotificationItem.fromJson(message);
  }
});

/// Provider that listens to the notifications websocket and shows device tray notifications.
final deviceTrayNotificationProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<NotificationItem>>(notificationsWebSocketProvider, (
    previous,
    next,
  ) {
    if (next.hasValue && next.value != null) {
      final item = next.value!;
      if (item.body != null && item.body!.isNotEmpty) {
        DeviceTray.instance.showNotification(
          title: item.title ?? 'Taska',
          body: item.body!,
          id: item.notificationId.hashCode,
        );
        ref.invalidate(notificationsProvider);
      }
    }
  });
});
