// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  grantType: json['grant_type'] as String?,
  username: json['username'] as String?,
  password: json['password'] as String?,
  scope: json['scope'] as String? ?? '',
  clientId: json['client_id'] as String?,
  clientSecret: json['client_secret'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'grant_type': instance.grantType,
      'username': instance.username,
      'password': instance.password,
      'scope': instance.scope,
      'client_id': instance.clientId,
      'client_secret': instance.clientSecret,
    };
