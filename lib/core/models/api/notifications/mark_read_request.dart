import 'package:json_annotation/json_annotation.dart';

part 'mark_read_request.g.dart';

@JsonSerializable()
class MarkReadRequest {
  @JsonKey(name: 'notification_ids')
  final List<String> notificationIds;

  MarkReadRequest({
    required this.notificationIds,
  });

  factory MarkReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MarkReadRequestFromJson(json);
  Map<String, dynamic> toJson() => _$MarkReadRequestToJson(this);
}
