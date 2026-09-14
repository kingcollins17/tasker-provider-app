import 'package:json_annotation/json_annotation.dart';

part 'interview.g.dart';

@JsonSerializable()
class Interview {
  final String? id;

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'admin_id')
  final String? adminId;

  @JsonKey(name: 'scheduled_at')
  final DateTime? scheduledAt;

  @JsonKey(name: 'meeting_link')
  final String? meetingLink;

  final String? status;

  final String? notes;

  @JsonKey(name: 'passed_at')
  final DateTime? passedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'meta_data')
  final Map<String, dynamic>? metaData;

  Interview({
    this.id,
    this.userId,
    this.adminId,
    this.scheduledAt,
    this.meetingLink,
    this.status,
    this.notes,
    this.passedAt,
    this.createdAt,
    this.updatedAt,
    this.metaData,
  });

  factory Interview.fromJson(Map<String, dynamic> json) =>
      _$InterviewFromJson(json);

  Map<String, dynamic> toJson() => _$InterviewToJson(this);
}
