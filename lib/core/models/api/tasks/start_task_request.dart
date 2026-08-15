import 'package:json_annotation/json_annotation.dart';

part 'start_task_request.g.dart';

/// Request body for `POST /api/v1/tasks/{task_id}/start`.
@JsonSerializable(fieldRename: FieldRename.snake)
class StartTaskRequest {
  final String pin;

  StartTaskRequest({required this.pin});

  factory StartTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$StartTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$StartTaskRequestToJson(this);
}
