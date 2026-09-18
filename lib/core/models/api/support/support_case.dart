import 'package:json_annotation/json_annotation.dart';

part 'support_case.g.dart';

enum CaseType {
  @JsonValue('GENERAL')
  general,
  @JsonValue('DISPUTE')
  dispute,
  @JsonValue('PAYMENT')
  payment,
  @JsonValue('TASK_ISSUE')
  taskIssue,
  @JsonValue('ACCOUNT')
  account,
  @JsonValue('TECHNICAL')
  technical,
  @JsonValue('OTHER')
  other;

  String get apiValue {
    switch (this) {
      case CaseType.general:
        return 'GENERAL';
      case CaseType.dispute:
        return 'DISPUTE';
      case CaseType.payment:
        return 'PAYMENT';
      case CaseType.taskIssue:
        return 'TASK_ISSUE';
      case CaseType.account:
        return 'ACCOUNT';
      case CaseType.technical:
        return 'TECHNICAL';
      case CaseType.other:
        return 'OTHER';
    }
  }
}

enum CasePriority {
  @JsonValue('LOW')
  low,
  @JsonValue('NORMAL')
  normal,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent;

  String get apiValue {
    switch (this) {
      case CasePriority.low:
        return 'LOW';
      case CasePriority.normal:
        return 'NORMAL';
      case CasePriority.high:
        return 'HIGH';
      case CasePriority.urgent:
        return 'URGENT';
    }
  }
}

@JsonSerializable()
class SupportCase {
  final String? id;

  @JsonKey(name: 'case_number')
  final String? caseNumber;

  final String? type;
  final String? status;
  final String? priority;

  @JsonKey(name: 'customer_id')
  final String? customerId;

  @JsonKey(name: 'provider_id')
  final String? providerId;

  @JsonKey(name: 'task_id')
  final String? taskId;

  @JsonKey(name: 'assignment_id')
  final String? assignmentId;

  @JsonKey(name: 'payout_id')
  final String? payoutId;

  final String? subject;
  final String? description;

  @JsonKey(name: 'assigned_agent_id')
  final String? assignedAgentId;

  @JsonKey(name: 'reply_token')
  final String? replyToken;

  @JsonKey(name: 'first_response_due_at')
  final DateTime? firstResponseDueAt;

  @JsonKey(name: 'resolution_due_at')
  final DateTime? resolutionDueAt;

  @JsonKey(name: 'first_responded_at')
  final DateTime? firstRespondedAt;

  @JsonKey(name: 'resolved_at')
  final DateTime? resolvedAt;

  @JsonKey(name: 'closed_at')
  final DateTime? closedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  SupportCase({
    this.id,
    this.caseNumber,
    this.type,
    this.status,
    this.priority,
    this.customerId,
    this.providerId,
    this.taskId,
    this.assignmentId,
    this.payoutId,
    this.subject,
    this.description,
    this.assignedAgentId,
    this.replyToken,
    this.firstResponseDueAt,
    this.resolutionDueAt,
    this.firstRespondedAt,
    this.resolvedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isOpen => status?.toUpperCase().trim() == 'OPEN';
  bool get isClosed => status?.toUpperCase().trim() == 'CLOSED';
  bool get isResolved => status?.toUpperCase().trim() == 'RESOLVED';

  factory SupportCase.fromJson(Map<String, dynamic> json) =>
      _$SupportCaseFromJson(json);

  Map<String, dynamic> toJson() => _$SupportCaseToJson(this);
}
