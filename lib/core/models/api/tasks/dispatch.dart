import 'package:json_annotation/json_annotation.dart';
import 'assignment.dart';

part 'dispatch.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Dispatch {
  final String? id;
  final String? taskId;
  final String? providerId;
  final int? sequenceOrder;
  final double? matchScore;
  final double? offeredPayout;
  final DateTime? pingedAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;
  final String? status;
  final AssignmentProvider? provider;

  Dispatch({
    this.id,
    this.taskId,
    this.providerId,
    this.sequenceOrder,
    this.matchScore,
    this.offeredPayout,
    this.pingedAt,
    this.expiresAt,
    this.respondedAt,
    this.status,
    this.provider,
  });

  factory Dispatch.fromJson(Map<String, dynamic> json) =>
      _$DispatchFromJson(json);

  Map<String, dynamic> toJson() => _$DispatchToJson(this);
}
