import 'dart:convert';
import 'package:flutter/foundation.dart';

enum DebugLevel { info, warn, error, network }

class DebugData {
  final DebugLevel level;
  final String data;
  final DateTime timestamp;

  DebugData({
    required this.level,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Singleton class storing debug logs in memory and extending [ChangeNotifier].
class DebugLogger extends ChangeNotifier {
  DebugLogger._internal();
  static final DebugLogger instance = DebugLogger._internal();

  final List<DebugData> _logs = [];

  List<DebugData> get logs => List.unmodifiable(_logs);

  void addLog(DebugData data) {
    _logs.add(data);
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}

/// Logs an object to console and appends it to [DebugLogger.instance].
void debugLog(Object? object, {DebugLevel level = DebugLevel.info}) {
  // if (!kDebugMode) return;

  String output;
  try {
    const encoder = JsonEncoder.withIndent('     ');
    output = encoder.convert(object);
  } catch (_) {
    try {
      if (object != null) {
        final dynamic dynamicObj = object;
        final jsonVal = dynamicObj.toJson();
        const encoder = JsonEncoder.withIndent('     ');
        output = encoder.convert(jsonVal);
      } else {
        output = 'null';
      }
    } catch (_) {
      output = object?.toString() ?? 'null';
    }
  }

  DebugLogger.instance.addLog(
    DebugData(
      level: level,
      data: output,
      timestamp: DateTime.now(),
    ),
  );

  debugPrint(output);
}
