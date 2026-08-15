import 'package:json_annotation/json_annotation.dart';

part 'complete_task_request.g.dart';

/// Request body for `POST /api/v1/tasks/{task_id}/complete`.
@JsonSerializable(fieldRename: FieldRename.snake)
class CompleteTaskRequest {
  final String pin;
  final String paymentMode;

  CompleteTaskRequest({
    required this.pin,
    this.paymentMode = 'cash',
  });

  factory CompleteTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CompleteTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CompleteTaskRequestToJson(this);
}
