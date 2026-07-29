// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_availability_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAvailabilityRequest _$UpdateAvailabilityRequestFromJson(
  Map<String, dynamic> json,
) => UpdateAvailabilityRequest(
  startTime: json['start_time'] as String?,
  endTime: json['end_time'] as String?,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$UpdateAvailabilityRequestToJson(
  UpdateAvailabilityRequest instance,
) => <String, dynamic>{
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'is_active': instance.isActive,
};
