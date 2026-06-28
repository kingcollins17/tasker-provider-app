// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_location_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateLocationRequest _$UpdateLocationRequestFromJson(
  Map<String, dynamic> json,
) => UpdateLocationRequest(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  addressLine: json['address_line'] as String?,
);

Map<String, dynamic> _$UpdateLocationRequestToJson(
  UpdateLocationRequest instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'address_line': instance.addressLine,
};
