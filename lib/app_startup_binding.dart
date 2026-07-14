import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasker_app/core/services/local_storage_service.dart';

Future<void> bootstrap() async {
  await dotenv.load();
  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.appStorage.name);
  unawaited(_bootstrapDeferred());
}

Future<void> _bootstrapDeferred() async {}
