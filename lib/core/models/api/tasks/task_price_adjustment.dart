import 'package:json_annotation/json_annotation.dart';

part 'task_price_adjustment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskPriceAdjustment {
  final String? id;
  final String? taskId;
  final String? description;
  final double? amount;
  final String? requestedBy;
  final String? status;
  final DateTime? createdAt;

  TaskPriceAdjustment({
    this.id,
    this.taskId,
    this.description,
    this.amount,
    this.requestedBy,
    this.status,
    this.createdAt,
  });

  factory TaskPriceAdjustment.fromJson(Map<String, dynamic> json) =>
      _$TaskPriceAdjustmentFromJson(json);

  Map<String, dynamic> toJson() => _$TaskPriceAdjustmentToJson(this);
}
