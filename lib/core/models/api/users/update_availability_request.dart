import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../utils/extensions/time_of_day_ext.dart';

part 'update_availability_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AvailabilityBlock {
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;

  AvailabilityBlock({
    this.dayOfWeek,
    this.startTime,
    this.endTime,
  });

  /// Helper factory constructor from [TimeOfDay] objects.
  factory AvailabilityBlock.fromTimeOfDay({
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return AvailabilityBlock(
      dayOfWeek: dayOfWeek,
      startTime: startTime?.toApiTimeString(),
      endTime: endTime?.toApiTimeString(),
    );
  }

  /// Helper getter to convert [startTime] string into Flutter [TimeOfDay].
  TimeOfDay? get startTimeOfDay => startTime?.toTimeOfDay();

  /// Helper getter to convert [endTime] string into Flutter [TimeOfDay].
  TimeOfDay? get endTimeOfDay => endTime?.toTimeOfDay();

  factory AvailabilityBlock.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityBlockFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityBlockToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateAvailabilityRequest {
  final List<AvailabilityBlock>? availabilityBlocks;

  UpdateAvailabilityRequest({
    this.availabilityBlocks,
  });

  factory UpdateAvailabilityRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAvailabilityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAvailabilityRequestToJson(this);
}
