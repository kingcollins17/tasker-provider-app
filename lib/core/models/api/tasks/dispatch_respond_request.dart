import 'package:json_annotation/json_annotation.dart';

part 'dispatch_respond_request.g.dart';

/// Request body for `POST /api/v1/tasks/{task_id}/dispatch/respond`.
///
/// Allowed provider-initiated values for [status]: `accepted`, `declined`.
@JsonSerializable(fieldRename: FieldRename.snake)
class DispatchRespondRequest {
  final String status;

  DispatchRespondRequest({required this.status});

  factory DispatchRespondRequest.fromJson(Map<String, dynamic> json) =>
      _$DispatchRespondRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DispatchRespondRequestToJson(this);
}
