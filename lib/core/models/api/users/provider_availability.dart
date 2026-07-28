import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../utils/extensions/time_of_day_ext.dart';

part 'provider_availability.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProviderAvailability {
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? id;
  final String? providerId;

  ProviderAvailability({
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.id,
    this.providerId,
  });

  /// Helper getter to convert [startTime] string into Flutter [TimeOfDay].
  TimeOfDay? get startTimeOfDay => startTime?.toTimeOfDay();

  /// Helper getter to convert [endTime] string into Flutter [TimeOfDay].
  TimeOfDay? get endTimeOfDay => endTime?.toTimeOfDay();

  factory ProviderAvailability.fromJson(Map<String, dynamic> json) =>
      _$ProviderAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderAvailabilityToJson(this);
}
