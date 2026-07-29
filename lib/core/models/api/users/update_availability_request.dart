import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../utils/extensions/time_of_day_ext.dart';

part 'update_availability_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UpdateAvailabilityRequest {
  final String? startTime;
  final String? endTime;
  final bool? isActive;

  UpdateAvailabilityRequest({
    this.startTime,
    this.endTime,
    this.isActive,
  });

  /// Helper factory constructor from [TimeOfDay] objects.
  factory UpdateAvailabilityRequest.fromTimeOfDay({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isActive,
  }) {
    return UpdateAvailabilityRequest(
      startTime: startTime?.toApiTimeString(),
      endTime: endTime?.toApiTimeString(),
      isActive: isActive,
    );
  }

  factory UpdateAvailabilityRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAvailabilityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAvailabilityRequestToJson(this);
}
