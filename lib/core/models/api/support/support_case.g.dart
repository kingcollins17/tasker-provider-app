// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_case.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportCase _$SupportCaseFromJson(Map<String, dynamic> json) => SupportCase(
  id: json['id'] as String?,
  caseNumber: json['case_number'] as String?,
  type: json['type'] as String?,
  status: json['status'] as String?,
  priority: json['priority'] as String?,
  customerId: json['customer_id'] as String?,
  providerId: json['provider_id'] as String?,
  taskId: json['task_id'] as String?,
  assignmentId: json['assignment_id'] as String?,
  payoutId: json['payout_id'] as String?,
  subject: json['subject'] as String?,
  description: json['description'] as String?,
  assignedAgentId: json['assigned_agent_id'] as String?,
  replyToken: json['reply_token'] as String?,
  firstResponseDueAt: json['first_response_due_at'] == null
      ? null
      : DateTime.parse(json['first_response_due_at'] as String),
  resolutionDueAt: json['resolution_due_at'] == null
      ? null
      : DateTime.parse(json['resolution_due_at'] as String),
  firstRespondedAt: json['first_responded_at'] == null
      ? null
      : DateTime.parse(json['first_responded_at'] as String),
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
  closedAt: json['closed_at'] == null
      ? null
      : DateTime.parse(json['closed_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SupportCaseToJson(SupportCase instance) =>
    <String, dynamic>{
      'id': instance.id,
      'case_number': instance.caseNumber,
      'type': instance.type,
      'status': instance.status,
      'priority': instance.priority,
      'customer_id': instance.customerId,
      'provider_id': instance.providerId,
      'task_id': instance.taskId,
      'assignment_id': instance.assignmentId,
      'payout_id': instance.payoutId,
      'subject': instance.subject,
      'description': instance.description,
      'assigned_agent_id': instance.assignedAgentId,
      'reply_token': instance.replyToken,
      'first_response_due_at': instance.firstResponseDueAt?.toIso8601String(),
      'resolution_due_at': instance.resolutionDueAt?.toIso8601String(),
      'first_responded_at': instance.firstRespondedAt?.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'closed_at': instance.closedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
