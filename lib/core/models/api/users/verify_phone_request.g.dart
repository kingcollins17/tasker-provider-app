// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_phone_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyPhoneRequest _$VerifyPhoneRequestFromJson(Map<String, dynamic> json) =>
    VerifyPhoneRequest(
      phoneNumber: json['phone_number'] as String?,
      code: json['code'] as String?,
    );

Map<String, dynamic> _$VerifyPhoneRequestToJson(VerifyPhoneRequest instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'code': instance.code,
    };
