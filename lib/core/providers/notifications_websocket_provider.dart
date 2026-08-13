import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasker_app/core/utils/debug_logger.dart';
import '../services/network_service.dart';
import '../services/local_storage_service.dart';
import '../services/web_socket_connection_handler.dart';
import '../services/device_tray.dart';
import 'notifications_provider.dart';
import 'package:tasker_app/features/tasks/presentation/widgets/offer_ping_bottom_sheet.dart';

/// AsyncNotifierProvider that maintains a WebSocket connection and exposes a broadcast stream.
class NotificationsWebSocketNotifier extends AsyncNotifier<Stream<dynamic>> {
  WebSocketConnectionHandler? _handler;

  @override
  Future<Stream<dynamic>> build() async {
    final environments = ref.watch(environmentsProvider);
    final token = await appStorage.get<String>(HiveKeys.accessToken.name);

    if (token == null || token.isEmpty) {
      return const Stream.empty();
    }

    _handler = WebSocketConnectionHandler(
      url: 'wss://${environments.domain}/api/v1/notifications/ws?token=$token',
    );

    _handler!.connect();

    ref.onDispose(() {
      _handler?.dispose();
    });

    return _handler!.messageStream;
  }

  void send(dynamic data) {
    if (_handler != null && !_handler!.isDisposed) {
      _handler!.send(data);
    }
  }
}

final notificationsWebSocketProvider =
    AsyncNotifierProvider<NotificationsWebSocketNotifier, Stream<dynamic>>(() {
      return NotificationsWebSocketNotifier();
    });

/// Provider that listens to the typed notification events stream and shows device tray notifications.
final deviceTrayNotificationProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<NotificationEvent>>(notificationEventsStream, (
    previous,
    next,
  ) {
    debugLog(next.value ?? 'No Value');
    if (next.hasValue && next.value != null) {
      final event = next.value!;
      if (event.type != NotificationEventType.notification) return;

      final raw = event.data;
      if (raw is! Map<String, dynamic>) return;

      Map<String, dynamic> payload = raw;

      final title = payload['title'] as String?;
      final body = payload['body'] as String?;
      final id =
          payload['notificationId'] ??
          payload['id'] ??
          DateTime.now().millisecondsSinceEpoch;

      if (body != null && body.isNotEmpty) {
        DeviceTray.instance.showNotification(
          title: title ?? 'Taska',
          body: body,
          id: id.hashCode,
        );
        ref.invalidate(notificationsProvider);
      }
    }
  });
});

/// Represents the type of notification received over the WebSocket.
enum NotificationEventType {
  /// A general system or user notification.
  notification,

  /// A direct chat message event.
  message,

  /// A heartbeat or real-time offer ping for jobs.
  offerPing,
}

/// A structured event model containing both the categorized [type]
/// and the raw [data] payload delivered via WebSocket.
class NotificationEvent {
  /// The specific category of the websocket event.
  final NotificationEventType type;

  /// The raw payload delivered in the event, typically a Map<String, dynamic>.
  final dynamic data;

  NotificationEvent({required this.type, required this.data});
}

/// A provider that exposes a stream of typed [NotificationEvent]s.
///
/// This provider listens to the raw [notificationsWebSocketProvider] via
/// [ref.listen] and forwards parsed events into a [StreamController]. This
/// avoids the pitfalls of using `ref.watch` inside an `async*` generator
/// (stale streams on rebuild) and the event-dropping behaviour of
/// `.asBroadcastStream()` when there are zero listeners.
final notificationEventsStream = StreamProvider<NotificationEvent>((ref) {
  final controller = StreamController<NotificationEvent>();
  StreamSubscription<dynamic>? innerSub;

  void subscribeToRawStream(Stream<dynamic> rawStream) {
    innerSub?.cancel();
    innerSub = rawStream.listen((raw) {
      final type = _parseRaw(raw);
      if (type != null) {
        controller.add(NotificationEvent(type: type, data: raw));
      }
    });
  }

  // React to changes in the WebSocket provider (token refresh, env change, etc.)
  ref.listen<AsyncValue<Stream<dynamic>>>(notificationsWebSocketProvider, (
    previous,
    next,
  ) {
    next.whenData((rawStream) {
      debugLog('notificationEventsStream: subscribing to raw WebSocket stream');
      subscribeToRawStream(rawStream);
    });
  }, fireImmediately: true);

  ref.onDispose(() {
    innerSub?.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Parses a raw WebSocket payload to determine the [NotificationEventType].
///
/// It first attempts to look for a definitive `'type'` key. If absent,
/// it attempts to infer the event type based on the presence of expected
/// keys (e.g., 'title' and 'body' for notifications).
///
/// Returns `null` if the raw payload doesn't match any known pattern,
/// allowing the system to safely ignore malformed or unrecognized events.
NotificationEventType? _parseRaw(dynamic raw) {
  if (raw is! Map<String, dynamic>) {
    // We expect the websocket parser to emit decoded maps (JSON).
    return null;
  }

  String? typeString;

  // 1. Primary classification using explicit 'type' field
  if (raw['type'] != null) {
    typeString = raw['type'].toString().toLowerCase().trim();
  } else if (raw['data'] is Map<String, dynamic> &&
      raw['data']['type'] != null) {
    typeString = raw['data']['type'].toString().toLowerCase().trim();
  } else if (raw['metadata'] is Map<String, dynamic> &&
      raw['metadata']['type'] != null) {
    typeString = raw['metadata']['type'].toString().toLowerCase().trim();
  } else {
    // Scan all map values for a nested 'type' field if not found yet
    for (final value in raw.values) {
      if (value is Map<String, dynamic> && value['type'] != null) {
        typeString = value['type'].toString().toLowerCase().trim();
        break;
      }
    }
  }

  if (typeString != null) {
    final type = switch (typeString) {
      'notification' ||
      'test' ||
      'payment_received' => NotificationEventType.notification,
      'message' || 'chat' || 'chat_message' => NotificationEventType.message,
      'offerping' ||
      'offer_ping' ||
      'ping' ||
      'job_ping' => NotificationEventType.offerPing,
      _ => null,
    };
    if (type != null) return type;
  }

  // 2. Fallback inference based on the data structure (duck typing).
  //    Only prefer a nested map when it actually contains useful keys;
  //    an empty 'data' or 'metadata' map should not shadow the root.
  Map<String, dynamic> payload = raw;
  if (raw['data'] is Map<String, dynamic> && (raw['data'] as Map).isNotEmpty) {
    payload = raw['data'];
  } else if (raw['metadata'] is Map<String, dynamic> &&
      (raw['metadata'] as Map).isNotEmpty) {
    payload = raw['metadata'];
  }

  if (payload.containsKey('title') && payload.containsKey('body')) {
    return NotificationEventType.notification;
  }

  if (payload.containsKey('message_id') ||
      payload.containsKey('text') ||
      payload.containsKey('sender_id')) {
    return NotificationEventType.message;
  }

  if (payload.containsKey('offer_id') ||
      payload.containsKey('job_id') ||
      payload.containsKey('ping_id')) {
    return NotificationEventType.offerPing;
  }

  // Unrecognized payload structure
  return null;
}

/// Provider that listens for [NotificationEventType.offerPing] events and
/// shows the [OfferPingBottomSheet] when one arrives with a valid `task_id`.
final offerPingListenerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<NotificationEvent>>(notificationEventsStream, (
    previous,
    next,
  ) {
    if (!next.hasValue || next.value == null) return;

    final event = next.value!;
    if (event.type != NotificationEventType.offerPing) return;

    final raw = event.data;
    if (raw is! Map<String, dynamic>) return;

    // Extract task_id from the payload — check root, then nested 'data'
    final taskId =
        raw['task_id'] as String? ??
        (raw['data'] is Map<String, dynamic>
            ? (raw['data'] as Map<String, dynamic>)['task_id'] as String?
            : null);

    if (taskId == null || taskId.isEmpty) {
      debugLog('offerPingListenerProvider: no task_id found in payload');
      return;
    }

    // Extract expires_at from payload (root or nested 'data') and ensure DateTime conversion
    final dynamic expiresAtRaw =
        raw['expires_at'] ??
        raw['expiresAt'] ??
        (raw['data'] is Map<String, dynamic>
            ? ((raw['data'] as Map<String, dynamic>)['expires_at'] ??
                (raw['data'] as Map<String, dynamic>)['expiresAt'])
            : null);

    DateTime? expiresAt;
    if (expiresAtRaw is DateTime) {
      expiresAt = expiresAtRaw;
    } else if (expiresAtRaw is String && expiresAtRaw.isNotEmpty) {
      expiresAt = DateTime.tryParse(expiresAtRaw);
    } else if (expiresAtRaw is int) {
      expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtRaw);
    }

    debugLog('offerPingListenerProvider: showing offer ping for task $taskId (expiresAt: $expiresAt)');
    OfferPingBottomSheet.show(taskId, expiresAt: expiresAt);
  });
});
