// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_support_case_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSupportCaseRequest _$CreateSupportCaseRequestFromJson(
  Map<String, dynamic> json,
) => CreateSupportCaseRequest(
  subject: json['subject'] as String,
  description: json['description'] as String,
  type: json['type'] as String? ?? 'GENERAL',
  priority: json['priority'] as String? ?? 'NORMAL',
  taskId: json['task_id'] as String?,
  assignmentId: json['assignment_id'] as String?,
  payoutId: json['payout_id'] as String?,
);

Map<String, dynamic> _$CreateSupportCaseRequestToJson(
  CreateSupportCaseRequest instance,
) => <String, dynamic>{
  'subject': instance.subject,
  'description': instance.description,
  'type': instance.type,
  'priority': instance.priority,
  'task_id': instance.taskId,
  'assignment_id': instance.assignmentId,
  'payout_id': instance.payoutId,
};
