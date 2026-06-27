import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> bootstrap() async {
  await dotenv.load();
  await Hive.initFlutter();
  unawaited(_bootstrapDeferred());
}

Future<void> _bootstrapDeferred() async {}
