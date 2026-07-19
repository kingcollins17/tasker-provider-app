// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_lite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskLite _$TaskLiteFromJson(Map<String, dynamic> json) => TaskLite(
  id: json['id'] as String?,
  customerId: json['customer_id'] as String?,
  title: json['title'] as String?,
  categoryId: json['category_id'] as String?,
  serviceId: json['service_id'] as String?,
  budgetMin: (json['budget_min'] as num?)?.toDouble(),
  budgetMax: (json['budget_max'] as num?)?.toDouble(),
  pricingModel: json['pricing_model'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  scheduledStartAt: json['scheduled_start_at'] == null
      ? null
      : DateTime.parse(json['scheduled_start_at'] as String),
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskLiteToJson(TaskLite instance) => <String, dynamic>{
  'id': instance.id,
  'customer_id': instance.customerId,
  'title': instance.title,
  'category_id': instance.categoryId,
  'service_id': instance.serviceId,
  'budget_min': instance.budgetMin,
  'budget_max': instance.budgetMax,
  'pricing_model': instance.pricingModel,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'scheduled_start_at': instance.scheduledStartAt?.toIso8601String(),
  'distance_km': instance.distanceKm,
  'category': instance.category,
};
