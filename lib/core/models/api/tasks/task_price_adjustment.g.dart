// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_price_adjustment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskPriceAdjustment _$TaskPriceAdjustmentFromJson(Map<String, dynamic> json) =>
    TaskPriceAdjustment(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      requestedBy: json['requested_by'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TaskPriceAdjustmentToJson(
  TaskPriceAdjustment instance,
) => <String, dynamic>{
  'id': instance.id,
  'task_id': instance.taskId,
  'description': instance.description,
  'amount': instance.amount,
  'requested_by': instance.requestedBy,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
};
