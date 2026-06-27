// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Region _$RegionFromJson(Map<String, dynamic> json) => Region(
  id: json['id'] as String?,
  addressLine: json['address_line'] as String?,
  state: json['state'] as String?,
  isActive: json['is_active'] as bool?,
  totalProviders: (json['total_providers'] as num?)?.toInt(),
  totalCustomers: (json['total_customers'] as num?)?.toInt(),
  totalTasks: (json['total_tasks'] as num?)?.toInt(),
  totalStaff: (json['total_staff'] as num?)?.toInt(),
  location: json['location'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$RegionToJson(Region instance) => <String, dynamic>{
  'id': instance.id,
  'address_line': instance.addressLine,
  'state': instance.state,
  'is_active': instance.isActive,
  'total_providers': instance.totalProviders,
  'total_customers': instance.totalCustomers,
  'total_tasks': instance.totalTasks,
  'total_staff': instance.totalStaff,
  'location': instance.location,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
