import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:tasker_app/app_startup_binding.dart';
import 'package:tasker_app/tasker_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await bootstrap(); // Run startup bindings
    runApp(
      ProviderScope(
        child: DevicePreview(
          enabled: !kReleaseMode,
          builder: (context) => const TaskerApp(),
        ),
      ),
    );
  } catch (e, st) {
    runApp(
      ProviderScope(
        child: StartupErrorWidget(error: e, trace: st),
      ),
    );
  }
}

