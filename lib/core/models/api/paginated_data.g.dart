// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedData<T> _$PaginatedDataFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedData<T>(
  items: (json['items'] as List<dynamic>?)?.map(fromJsonT).toList(),
  total: (json['total'] as num?)?.toInt(),
  page: (json['page'] as num?)?.toInt(),
  perPage: (json['per_page'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaginatedDataToJson<T>(
  PaginatedData<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items?.map(toJsonT).toList(),
  'total': instance.total,
  'page': instance.page,
  'per_page': instance.perPage,
};
