import 'package:flutter/material.dart';

extension TimeOfDayExt on TimeOfDay {
  /// Formats [TimeOfDay] to an API time string format e.g. "14:15:22" (HH:mm:ss).
  String toApiTimeString({int second = 0}) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    final s = second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

extension TimeOfDayStringExt on String {
  /// Parses a time string like "14:15:22" or "14:15:22Z" into a Flutter [TimeOfDay].
  TimeOfDay? toTimeOfDay() {
    try {
      final parts = split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0].trim());
        final minuteIntStr = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        final minute = int.parse(minuteIntStr);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }
}
