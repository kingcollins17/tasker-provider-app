import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> bootstrap() async {
  await dotenv.load();
  unawaited(_bootstrapDeferred());
}

Future<void> _bootstrapDeferred() async {}
