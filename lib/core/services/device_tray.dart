import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level callback for notification actions triggered while the app is in
/// the background or terminated. Must be a top-level or static function and
/// annotated with `@pragma('vm:entry-point')` so tree-shaking does not remove
/// it.
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(
  NotificationResponse notificationResponse,
) {
  debugPrint(
    'Background notification action: '
    'id=${notificationResponse.id}, '
    'actionId=${notificationResponse.actionId}, '
    'payload=${notificationResponse.payload}',
  );
}

class DeviceTray {
  static final DeviceTray _instance = DeviceTray._internal();

  factory DeviceTray() {
    return _instance;
  }

  DeviceTray._internal();

  static DeviceTray get instance => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initializes the local notification service.
  /// Ensure this is called early in the app lifecycle (e.g., main.dart)
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize native android notification
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize native iOS notification.
    // Defer permission requests to [requestPermissions] so the prompt appears
    // at a more appropriate point in the user experience.
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onForegroundNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    _isInitialized = true;
  }

  /// Requests notification permissions from the user on platforms that require
  /// an explicit grant (Android 13+ and iOS).
  ///
  /// Call this at a point in your UX where the user expects to be asked —
  /// for example after tapping an "Enable Notifications" button.
  ///
  /// Returns `true` if permission was granted, `false` otherwise.
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    if (Platform.isAndroid) {
      final android = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }

    if (Platform.isIOS) {
      final ios = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  /// Callback for notifications tapped while the app is in the foreground.
  void _onForegroundNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Shows an instant notification in the device tray.
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0, // Unique ID for the notification
    String channelId = 'instant_notifications',
    String channelName = 'Instant Notifications',
    String channelDescription = 'Shows instant notifications from the app',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}
