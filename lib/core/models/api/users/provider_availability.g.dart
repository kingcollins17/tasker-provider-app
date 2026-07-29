// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_availability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderAvailability _$ProviderAvailabilityFromJson(
  Map<String, dynamic> json,
) => ProviderAvailability(
  dayOfWeek: (json['day_of_week'] as num?)?.toInt(),
  startTime: json['start_time'] as String?,
  endTime: json['end_time'] as String?,
  isActive: json['is_active'] as bool?,
  id: json['id'] as String?,
  providerId: json['provider_id'] as String?,
);

Map<String, dynamic> _$ProviderAvailabilityToJson(
  ProviderAvailability instance,
) => <String, dynamic>{
  'day_of_week': instance.dayOfWeek,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'is_active': instance.isActive,
  'id': instance.id,
  'provider_id': instance.providerId,
};
