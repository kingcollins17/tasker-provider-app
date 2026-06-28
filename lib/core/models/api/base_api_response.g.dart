// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseApiResponse<T> _$BaseApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => BaseApiResponse<T>(
  detail: json['detail'] as String?,
  statusCode: (json['status_code'] as num?)?.toInt(),
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
);

Map<String, dynamic> _$BaseApiResponseToJson<T>(
  BaseApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'detail': instance.detail,
  'status_code': instance.statusCode,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
