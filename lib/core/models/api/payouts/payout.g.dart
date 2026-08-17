// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payout _$PayoutFromJson(Map<String, dynamic> json) => Payout(
  id: json['id'] as String?,
  providerId: json['provider_id'] as String?,
  customerId: json['customer_id'] as String?,
  taskId: json['task_id'] as String?,
  payoutAmount: (json['payout_amount'] as num?)?.toDouble(),
  customerPaymentAmount: (json['customer_payment_amount'] as num?)?.toDouble(),
  status: json['status'] as String?,
  description: json['description'] as String?,
  paymentUrl: json['payment_url'] as String?,
  urlGeneratedAt: json['url_generated_at'] == null
      ? null
      : DateTime.parse(json['url_generated_at'] as String),
  reference: json['reference'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  task: json['task'] == null
      ? null
      : TaskLite.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PayoutToJson(Payout instance) => <String, dynamic>{
  'id': instance.id,
  'provider_id': instance.providerId,
  'customer_id': instance.customerId,
  'task_id': instance.taskId,
  'payout_amount': instance.payoutAmount,
  'customer_payment_amount': instance.customerPaymentAmount,
  'status': instance.status,
  'description': instance.description,
  'payment_url': instance.paymentUrl,
  'url_generated_at': instance.urlGeneratedAt?.toIso8601String(),
  'reference': instance.reference,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'task': instance.task,
};
