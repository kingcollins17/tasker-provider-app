import 'package:json_annotation/json_annotation.dart';
import 'task.dart';

part 'offer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Offer {
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
  final Task? task;

  Offer({
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
    this.task,
  });

  factory Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

  Map<String, dynamic> toJson() => _$OfferToJson(this);
}
