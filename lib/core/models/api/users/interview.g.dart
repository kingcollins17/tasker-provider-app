// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Interview _$InterviewFromJson(Map<String, dynamic> json) => Interview(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  adminId: json['admin_id'] as String?,
  scheduledAt: json['scheduled_at'] == null
      ? null
      : DateTime.parse(json['scheduled_at'] as String),
  meetingLink: json['meeting_link'] as String?,
  status: json['status'] as String?,
  notes: json['notes'] as String?,
  passedAt: json['passed_at'] == null
      ? null
      : DateTime.parse(json['passed_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  metaData: json['meta_data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$InterviewToJson(Interview instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'admin_id': instance.adminId,
  'scheduled_at': instance.scheduledAt?.toIso8601String(),
  'meeting_link': instance.meetingLink,
  'status': instance.status,
  'notes': instance.notes,
  'passed_at': instance.passedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'meta_data': instance.metaData,
};
