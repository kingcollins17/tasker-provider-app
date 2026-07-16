# flutter_local_notifications 22.0.1

> A cross platform plugin for displaying local notifications.
>
> **Publisher:** [dexterx.dev](https://pub.dev/publishers/dexterx.dev)
> **Platforms:** Android, iOS, Linux, macOS, Web, Windows
> **License:** BSD-3-Clause

> [!IMPORTANT]
> Given how quickly the Flutter ecosystem evolves, the minimum Flutter SDK version will be bumped occasionally to make it easier to maintain the plugin. If this affects your applications (e.g., you need to support an older OS version), you may need to consider maintaining your own fork.

---

## Table of Contents

- [📱 Supported Platforms](#-supported-platforms)
- [✨ Features](#-features)
- [⚠ Caveats and Limitations](#-caveats-and-limitations)
- [🔧 Android Setup](#-android-setup)
- [🔧 iOS Setup](#-ios-setup)
- [🌐 Web Setup](#-web-setup)
- [❓ Usage](#-usage)
- [📈 Testing](#-testing)

---

## 📱 Supported Platforms

| Platform | Implementation |
|----------|---------------|
| Android  | Uses the NotificationCompat APIs so it can run on older Android devices |
| iOS      | Uses the UserNotification APIs (aka the User Notifications Framework) |
| macOS    | Uses the UserNotification APIs (aka the User Notifications Framework) |
| Linux    | Uses the Desktop Notifications Specification |
| Windows  | Uses the C++/WinRT implementation of Toast Notifications |
| Web      | Uses the Notifications API |

> [!NOTE]
> The plugin requires **Flutter SDK 3.38.1** at a minimum.

---

## ✨ Features

### Cross-Platform

- Mockable (plugin and API methods aren't static)
- Display basic notifications
- Scheduling when notifications should appear
- Periodically show a notification (interval based)
- Schedule a notification to be shown daily at a specified time
- Schedule a notification to be shown weekly on a specified day and time
- Retrieve a list of pending notification requests that have been scheduled to be shown in the future
- Cancelling/removing notification by id or all of them
- Specify a custom notification sound
- Ability to handle when a user has tapped on a notification, when the app is in the foreground, background or is terminated
- Determine if an app was launched due to tapping on a notification

### Android

- Request permission to show notifications
- Configuring the importance level
- Configuring the priority
- Customising the vibration pattern for notifications
- Configure the default icon for all notifications
- Configure the icon for each notification (overrides the default when specified)
- Configure the large icon for each notification (drawable or file)
- Formatting notification content via HTML markup
- Support for notification styles: Big picture, Big text, Inbox, Messaging, Media
- Group notifications
- Show progress notifications
- Configure notification visibility on the lockscreen
- Ability to create and delete notification channels
- Retrieve the list of active notifications
- Full-screen intent notifications
- Start a foreground service
- Ability to check if notifications are enabled

### iOS & macOS

- Request notification permissions and customise the permissions being requested
- [iOS 10+] Request CarPlay notification permissions
- [iOS 10+ / macOS 10.14+] Display notifications with attachments
- [iOS 12.0+] Support for custom notification settings UI
- Ability to check if notifications are enabled with specific type check

### Linux

- Ability to use themed/Flutter Assets icons and sound
- Ability to set the category
- Configuring the urgency
- Configuring the timeout (depends on system implementation)
- Ability to set custom notification location (depends on system implementation)
- Ability to set custom hints
- Ability to suppress sound
- Resident and transient notifications

### Windows

- Can show raw XML (see the Notifications Visualizer)
- A full Dart API for all the options supported by toast notifications
- Can configure images, buttons, dropdowns, text input, and launch behavior
- Can dynamically update notifications after they've been shown

---

## ⚠ Caveats and Limitations

The cross-platform facing API exposed by the `FlutterLocalNotificationsPlugin` class doesn't expose platform-specific methods as its goal is to provide an abstraction for all platforms. Platform-specific implementations can be obtained by calling `resolvePlatformSpecificImplementation`.

### Compatibility with firebase_messaging

Previously, there were issues that prevented this plugin working properly with the `firebase_messaging` plugin. This has been resolved since **version 6.0.13** of `firebase_messaging` — make sure you are using a recent version.

### Scheduled Android Notifications

Some Android OEMs have customised Android OS that can prevent applications from running in the background. Consequently, scheduled notifications may not work when the application is in the background on certain devices (e.g. Xiaomi, Huawei). See [dontkillmyapp.com](https://dontkillmyapp.com) for device-specific workarounds.

> [!WARNING]
> Samsung's implementation of Android has imposed a maximum of **500 alarms** that can be scheduled via the Alarm Manager API. Exceptions can occur when going over the limit.

### iOS Pending Notifications Limit

There is a limit imposed by iOS where it will only keep the **64 notifications** that were last set on any iOS versions newer than 9.

### Scheduled Notifications and Daylight Saving Time

The notification APIs used on iOS versions older than 10 (aka the `UILocalNotification` APIs) have limited support for time zones.

### Updating Application Badge

This plugin doesn't provide APIs for directly setting the badge count. Use other plugins such as `flutter_app_badger` if needed.

### Custom Notification Sounds

iOS and macOS restrictions apply (e.g. supported file formats).

### macOS Differences

- `getNotificationAppLaunchDetails` will return `null` on macOS versions older than 10.14.
- The deprecated `schedule`, `showDailyAtTime`, and `showWeeklyAtDayAndTime` methods aren't implemented on macOS.

### Linux Limitations

- Capabilities depend on the system notification server implementation. Use `LinuxFlutterLocalNotificationsPlugin.getCapabilities()` to check.
- Scheduled/pending notifications are **not supported** due to the lack of a scheduler API.
- The `onDidReceiveNotificationResponse` callback runs on the main isolate and cannot be launched in the background if the application is not running.

### Windows Limitations

- Windows does **not** support repeating notifications (`periodicallyShow` and `periodicallyShowWithDuration` will throw `UnsupportedError`).
- Only apps with package identity (MSIX) can retrieve previously shown notifications. Without MSIX, `cancel` does nothing and `getActiveNotifications` returns an empty list.

### Web Limitations

> [!CAUTION]
> You must request notification permissions **only in response to a user interaction**. If you try to request permissions automatically (e.g., on page load), the browser may automatically deny and block all future prompts.

- Notification actions are supported by Chrome and Edge, but not Firefox or Safari.
- Browsers don't support scheduled or repeating notifications.
- Browsers on Android do not support custom vibration.

### Notification Payload

Due to iOS limitations with null values in dictionaries, a `null` notification payload is coalesced to an **empty string** on all platforms for consistency.

---

## 🔧 Android Setup

> [!IMPORTANT]
> Make sure you are using the **latest version** of the plugin. Applications that schedule notifications should pay close attention to the AndroidManifest.xml setup section since Android 14 has brought about behavioural changes.

### Gradle Setup

Version 10+ of the plugin relies on **desugaring** to support scheduled notifications with backwards compatibility. You **must** enable desugaring even if you don't use scheduled notifications.

The plugin uses **AGP 8.11.1** — your application should aim to use the same version at a minimum.

For the **Plugin DSL syntax** (`settings.gradle.kts`):

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}
```

Enable desugaring in your app's `build.gradle.kts`:

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

> [!TIP]
> If you experience crashes on Android 12L and above after enabling desugaring, try adding the WindowManager library as a dependency. See [Flutter issue #110658](https://github.com/flutter/flutter/issues/110658).

The `compileSdk` must be set to **35** at a minimum.

### AndroidManifest.xml Setup

Since version 16, the plugin only specifies `POST_NOTIFICATIONS` and `VIBRATE` permissions. You need to add additional permissions yourself.

#### Scheduling Notifications

Add between `<manifest>` tags:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

For **exact alarms**, choose one of:

```xml
<!-- Option 1: User must grant permission -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />

<!-- Option 2: No prompt, but subject to store review (requires API 33+) -->
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

Add between `<application>` tags:

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />

<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

#### Full-Screen Intent Notifications

```xml
<!-- Between <manifest> tags -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```

#### Notification Actions

```xml
<!-- Between <application> tags -->
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
```

#### Foreground Services

```xml
<!-- Between <application> tags -->
<service
    android:name="com.dexterous.flutterlocalnotifications.ForegroundService"
    android:exported="false"
    android:stopWithTask="false"
    android:foregroundServiceType="<foreground service types>">
</service>
```

#### Bypassing Do Not Disturb

```xml
<!-- Between <manifest> tags -->
<uses-permission android:name="android.permission.ACCESS_NOTIFICATION_POLICY" />
```

### Requesting Permissions on Android 13+

From Android 13 (API level 33) onwards, apps can display a permission prompt:

```dart
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
```

### Custom Notification Icons and Sounds

- Notification icons should be added as a **drawable resource**. It is possible to use `@mipmap/ic_launcher` but the official Android guidance recommends drawable resources.
- Custom notification sounds should be added as a **raw resource**.

> [!WARNING]
> For Android 8.0+, sounds and vibrations are associated with **notification channels** and can only be configured when they are **first created**. Changing the sound/vibration of an existing channel has no effect.

### Full-Screen Intent Notifications

Add these attributes to your `FlutterActivity`:

```xml
<activity
    android:showWhenLocked="true"
    android:turnScreenOn="true">
```

### Bypassing Do Not Disturb (DnD)

Call `requestNotificationPolicyAccess()` on `AndroidFlutterNotificationsPlugin` before creating a channel with `bypassDnd: true`.

> [!NOTE]
> This does **not** ignore the device's silent mode. For emergency notifications, consider using a package like `sound_mode` to control the `RingerMode`.

### Release Build Configuration

> [!CAUTION]
> Ensure you have configured a `keep.xml` file so that resources like notification icons aren't discarded by the R8 compiler. Without this, notifications might silently fail or show incorrect icons.

Example `res/raw/keep.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/*,@mipmap/*" />
```

### ProGuard Rules

For **v19 and higher**, ProGuard rules are automatically provided by GSON. For v18 and lower, you must manually add GSON-specific ProGuard rules.

---

## 🔧 iOS Setup

### General Setup

Add the following to `AppDelegate.swift` in `didFinishLaunchingWithOptions`:

**Swift:**

```swift
if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

**Objective-C:**

```objc
[UNUserNotificationCenter currentNotificationCenter].delegate =
    (id<UNUserNotificationCenterDelegate>) self;
```

### Handling Notifications in the Foreground

By design, iOS applications do not display notifications while the app is in the foreground unless configured to do so. For iOS 10+, use the presentation options to control this behaviour. The plugin's default settings will display notifications in the foreground.

### Notification Actions (iOS)

#### Non-UIScene Lifecycle

If your application has **not** been migrated to UIScene lifecycle, update `didFinishLaunchingWithOptions`:

```swift
import UIKit
import Flutter
import flutter_local_notifications

@UIApplicationMain
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    // ...
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

#### UIScene Lifecycle

If your application **has** been migrated to UIScene lifecycle, update `didInitializeImplicitFlutterEngine` instead:

```swift
import UIKit
import Flutter
import flutter_local_notifications

// ...
func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
}
```

> [!IMPORTANT]
> Apple have announced that after iOS 26, the next major release will enforce new requirements for applications. If your application uses the UIScene lifecycle, ensure `setPluginRegistrantCallback` is in `didInitializeImplicitFlutterEngine`.

### Notification Categories (iOS/macOS)

On iOS/macOS, notification actions need to be configured before the app is started using the `initialize` method:

```dart
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
  notificationCategories: [
    DarwinNotificationCategory(
      'demoCategory',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2', 'Action 2',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          'id_3', 'Action 3',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ],
);
```

---

## 🌐 Web Setup

No modifications to HTML or JavaScript are necessary. You must request permissions at runtime:

```dart
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

await flutterLocalNotificationsPlugin.initialize(
  const InitializationSettings(
    // ... platform-specific settings
  ),
);

final webPlugin = flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>();

if (webPlugin != null &&
    webPlugin.permissionStatus != WebNotificationPermission.granted) {
  // IMPORTANT: Only call this after a button press!
  await webPlugin.requestNotificationsPermission();
}
```

---

## ❓ Usage

> [!NOTE]
> Before copy-pasting code snippets, double-check you have configured your application correctly. Refer to the API docs and the sample code in the example directory before opening issues on GitHub.

### Initialisation

Create a new instance of the plugin class and initialise it with settings for each platform:

```dart
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// app_icon needs to be a drawable resource in the Android project
const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings();

final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(defaultActionName: 'Open notification');

final WindowsInitializationSettings initializationSettingsWindows =
    WindowsInitializationSettings(
        appName: 'Flutter Local Notifications Example',
        appUserModelId: 'Com.Dexterous.FlutterLocalNotificationsExample',
        guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb');

final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
    linux: initializationSettingsLinux,
    windows: initializationSettingsWindows);

await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
```

> [!NOTE]
> All settings are nullable — you only need to provide settings for platforms you target. You will get a runtime `ArgumentError` if you forget to pass settings for your target platform.

### iOS-Specific: Using IOSInitializationSettings

Starting from **version 17.3.0**, use `IOSInitializationSettings` instead of `DarwinInitializationSettings` for iOS-only features like CarPlay:

```dart
final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCarPlayPermission: true, // iOS-specific
    );

final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,    // iOS-specific settings
    macOS: initializationSettingsDarwin, // Keep Darwin for macOS
);
```

### Notification Response Callback

```dart
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  await Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
  );
}
```

> [!NOTE]
> This callback is only intended to work when the app is **running**. For launch-from-notification scenarios, use `getNotificationAppLaunchDetails`.

### Requesting Notification Permissions

To defer the permission prompt to a later point, set all permission flags to `false` during initialization, then call `requestPermissions` when appropriate.

**iOS:**

```dart
final bool? result = await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
```

**macOS:**

```dart
final bool? result = await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
```

### Notification Actions

#### Background Handler

Define a top-level or static function annotated with `@pragma('vm:entry-point')`:

```dart
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}
```

Register it in `initialize`:

```dart
await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // ...
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
);
```

> [!WARNING]
> This function runs in a **separate isolate** (except Linux). On Android, there is no access to the `Activity` context — some plugins (like `url_launcher`) will require additional flags.

#### Android Notification Actions

```dart
Future<void> _showNotificationWithActions() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    channelDescription: 'channel_description',
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('id_1', 'Action 1'),
      AndroidNotificationAction('id_2', 'Action 2'),
      AndroidNotificationAction('id_3', 'Action 3'),
    ],
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      id: 0, title: '...', body: '...', notificationDetails);
}
```

### Displaying a Notification

```dart
const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
  'your channel id',
  'your channel name',
  channelDescription: 'your channel description',
  importance: Importance.max,
  priority: Priority.high,
  ticker: 'ticker',
);
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

await flutterLocalNotificationsPlugin.show(
    0, 'plain title', 'plain body', notificationDetails,
    payload: 'item x');
```

### Scheduling a Notification

Scheduling requires a date and time relative to a specific time zone using the `timezone` package:

```dart
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Initialize the time zone database
tz.initializeTimeZones();

// Optionally set a default local location
tz.setLocalLocation(tz.getLocation(timeZoneName));

// Schedule a notification
await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    title: 'scheduled title',
    body: 'scheduled body',
    scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    const NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel description')),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
```

> [!NOTE]
> Use `flutter_timezone` to obtain the current device time zone. The optional `matchDateTimeComponents` parameter can be used for daily or weekly recurring notifications.

### Periodically Show a Notification

> **Note:** Not supported on Windows.

```dart
const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
  'repeating channel id',
  'repeating channel name',
  channelDescription: 'repeating description',
);
const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

await flutterLocalNotificationsPlugin.periodicallyShow(
  id: id++,
  title: 'repeating title',
  body: 'repeating body',
  repeatInterval: RepeatInterval.everyMinute,
  notificationDetails: notificationDetails,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
);
```

### Retrieving Pending Notification Requests

```dart
final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
```

### Retrieving Active Notifications

> **Note:** On Windows, your app must be packaged as MSIX. Supported on Android 6.0+, iOS 10.0+, macOS 10.14+.

```dart
final List<ActiveNotification> activeNotifications =
    await flutterLocalNotificationsPlugin.getActiveNotifications();

for (final ActiveNotification notification in activeNotifications) {
  print('Notification group/thread: ${notification.groupKey}');
}
```

### Grouping Notifications

#### iOS

```dart
const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(threadIdentifier: 'thread_id');
```

#### Android

```dart
const String groupKey = 'com.android.example.WORK_EMAIL';
const String groupChannelId = 'grouped channel id';
const String groupChannelName = 'grouped channel name';
const String groupChannelDescription = 'grouped channel description';

// Individual notifications
const AndroidNotificationDetails firstNotificationAndroidSpecifics =
    AndroidNotificationDetails(
  groupChannelId,
  groupChannelName,
  channelDescription: groupChannelDescription,
  importance: Importance.max,
  priority: Priority.high,
  groupKey: groupKey,
);

// Summary notification (recommended for pre-Android 7.0 compatibility)
const InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
  ['Alex Faarborg  Check this out', 'Jeff Chang    Launch Party'],
  contentTitle: '2 messages',
  summaryText: 'janedoe@example.com',
);
const AndroidNotificationDetails summaryNotificationDetails =
    AndroidNotificationDetails(
  groupChannelId,
  groupChannelName,
  channelDescription: groupChannelDescription,
  styleInformation: inboxStyleInformation,
  groupKey: groupKey,
  setAsGroupSummary: true,
);
```

### Cancelling/Deleting a Notification

```dart
// Cancel the notification with id value of zero
await flutterLocalNotificationsPlugin.cancel(id: 0);
```

### Cancelling/Deleting All Notifications

```dart
await flutterLocalNotificationsPlugin.cancelAll();
```

### Getting App Launch Details

```dart
final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
```

### iOS Only: Periodic Notifications After Reinstallation

If notifications were set to show periodically on older iOS versions (< 10) and the app was uninstalled without cancelling alarms, add this to `didFinishLaunchingWithOptions`:

**Swift:**

```swift
if !UserDefaults.standard.bool(forKey: "Notification") {
    UIApplication.shared.cancelAllLocalNotifications()
    UserDefaults.standard.set(true, forKey: "Notification")
}
```

**Objective-C:**

```objc
if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Notification"]) {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Notification"];
}
```

---

## 📈 Testing

As the plugin class is **not static**, it is possible to mock and verify its behaviour when writing tests. The source code includes a sample test suite (`test/flutter_local_notifications_test.dart`).

If you use the plugin class directly in tests, methods will be mostly **no-op** and methods that return data will return default values. This is because the plugin detects if you're running on a supported platform.

If a platform-specific implementation is required for tests, use the `debugDefaultTargetPlatformOverride` property provided by the Flutter framework.

---

## Metadata

| Field | Value |
|-------|-------|
| **Repository** | [GitHub](https://github.com/niclas-petermayer/flutter_local_notifications) |
| **License** | BSD-3-Clause |
| **Dependencies** | `clock`, `flutter`, `flutter_local_notifications_linux`, `flutter_local_notifications_platform_interface`, `flutter_local_notifications_web`, `flutter_local_notifications_windows`, `timezone` |
