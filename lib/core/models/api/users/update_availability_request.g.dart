// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_availability_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailabilityBlock _$AvailabilityBlockFromJson(Map<String, dynamic> json) =>
    AvailabilityBlock(
      dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );

Map<String, dynamic> _$AvailabilityBlockToJson(AvailabilityBlock instance) =>
    <String, dynamic>{
      'day_of_week': instance.dayOfWeek,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
    };

UpdateAvailabilityRequest _$UpdateAvailabilityRequestFromJson(
  Map<String, dynamic> json,
) => UpdateAvailabilityRequest(
  availabilityBlocks: (json['availability_blocks'] as List<dynamic>?)
      ?.map((e) => AvailabilityBlock.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UpdateAvailabilityRequestToJson(
  UpdateAvailabilityRequest instance,
) => <String, dynamic>{'availability_blocks': instance.availabilityBlocks};
