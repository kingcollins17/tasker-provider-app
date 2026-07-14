// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_provider_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProviderProfileRequest _$UpdateProviderProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProviderProfileRequest(
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  gender: json['gender'] as String?,
  phoneNumber: json['phone_number'] as String?,
);

Map<String, dynamic> _$UpdateProviderProfileRequestToJson(
  UpdateProviderProfileRequest instance,
) => <String, dynamic>{
  'first_name': ?instance.firstName,
  'last_name': ?instance.lastName,
  'gender': ?instance.gender,
  'phone_number': ?instance.phoneNumber,
};
