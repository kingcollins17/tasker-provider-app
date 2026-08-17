// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dispatch _$DispatchFromJson(Map<String, dynamic> json) => Dispatch(
  id: json['id'] as String?,
  taskId: json['task_id'] as String?,
  providerId: json['provider_id'] as String?,
  sequenceOrder: (json['sequence_order'] as num?)?.toInt(),
  matchScore: (json['match_score'] as num?)?.toDouble(),
  offeredPayout: (json['offered_payout'] as num?)?.toDouble(),
  pingedAt: json['pinged_at'] == null
      ? null
      : DateTime.parse(json['pinged_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  respondedAt: json['responded_at'] == null
      ? null
      : DateTime.parse(json['responded_at'] as String),
  status: json['status'] as String?,
  provider: json['provider'] == null
      ? null
      : AssignmentProvider.fromJson(json['provider'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DispatchToJson(Dispatch instance) => <String, dynamic>{
  'id': instance.id,
  'task_id': instance.taskId,
  'provider_id': instance.providerId,
  'sequence_order': instance.sequenceOrder,
  'match_score': instance.matchScore,
  'offered_payout': instance.offeredPayout,
  'pinged_at': instance.pingedAt?.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
  'responded_at': instance.respondedAt?.toIso8601String(),
  'status': instance.status,
  'provider': instance.provider,
};
