// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_location_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PingLocationRequest _$PingLocationRequestFromJson(Map<String, dynamic> json) =>
    PingLocationRequest(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$PingLocationRequestToJson(
  PingLocationRequest instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
