import 'package:json_annotation/json_annotation.dart';

part 'create_support_case_request.g.dart';

@JsonSerializable()
class CreateSupportCaseRequest {
  final String subject;
  final String description;
  final String? type;
  final String? priority;

  @JsonKey(name: 'task_id')
  final String? taskId;

  @JsonKey(name: 'assignment_id')
  final String? assignmentId;

  @JsonKey(name: 'payout_id')
  final String? payoutId;

  CreateSupportCaseRequest({
    required this.subject,
    required this.description,
    this.type = 'GENERAL',
    this.priority = 'NORMAL',
    this.taskId,
    this.assignmentId,
    this.payoutId,
  });

  factory CreateSupportCaseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSupportCaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSupportCaseRequestToJson(this);
}
