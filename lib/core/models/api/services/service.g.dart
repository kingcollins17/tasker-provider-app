// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
  id: json['id'] as String?,
  name: json['name'] as String?,
  imageUrl: json['image_url'] as String?,
  takeRate: (json['take_rate'] as num?)?.toDouble(),
  isActive: json['is_active'] as bool?,
  categoryId: json['category_id'] as String?,
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image_url': instance.imageUrl,
  'take_rate': instance.takeRate,
  'is_active': instance.isActive,
  'category_id': instance.categoryId,
  'category': instance.category,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
