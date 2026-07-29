import 'package:json_annotation/json_annotation.dart';
import '../tasks/task_lite.dart';

part 'payout.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Payout {
  final String? id;
  final String? providerId;
  final String? customerId;
  final String? taskId;
  final double? payoutAmount;
  final double? customerPaymentAmount;
  final String? status;
  final String? description;
  final String? paymentUrl;
  final DateTime? urlGeneratedAt;
  final String? reference;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TaskLite? task;

  Payout({
    this.id,
    this.providerId,
    this.customerId,
    this.taskId,
    this.payoutAmount,
    this.customerPaymentAmount,
    this.status,
    this.description,
    this.paymentUrl,
    this.urlGeneratedAt,
    this.reference,
    this.createdAt,
    this.updatedAt,
    this.task,
  });

  factory Payout.fromJson(Map<String, dynamic> json) => _$PayoutFromJson(json);

  Map<String, dynamic> toJson() => _$PayoutToJson(this);
}
