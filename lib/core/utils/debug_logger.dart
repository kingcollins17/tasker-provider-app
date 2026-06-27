import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Logs an object to the console in a formatted JSON structure if possible, falling back to standard string representation.
void debugLog(Object? object) {
  if (!kDebugMode) return;

  String output;
  try {
    const encoder = JsonEncoder.withIndent('     ');
    output = encoder.convert(object);
  } catch (_) {
    try {
      if (object != null) {
        // Attempt to call toJson() dynamically if the object provides it
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

  debugPrint(output);
}
