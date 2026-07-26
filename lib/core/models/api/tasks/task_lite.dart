import 'package:json_annotation/json_annotation.dart';
import '../services/category.dart';

part 'task_lite.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskLite {
  final String? id;
  final String? customerId;
  final String? title;
  final String? categoryId;
  final String? serviceId;
  final double? basePrice;
  final double? distanceFee;
  final double? timeFee;
  final double? urgencyFee;
  final double? complexityFee;
  final double? surgeMultiplier;
  final double? customerTotalPrice;
  final double? platformFee;
  final double? providerPayout;
  final String? status;
  final DateTime? createdAt;
  final DateTime? scheduledStartAt;
  final double? distanceKm;
  final Category? category;

  TaskLite({
    this.id,
    this.customerId,
    this.title,
    this.categoryId,
    this.serviceId,
    this.basePrice,
    this.distanceFee,
    this.timeFee,
    this.urgencyFee,
    this.complexityFee,
    this.surgeMultiplier,
    this.customerTotalPrice,
    this.platformFee,
    this.providerPayout,
    this.status,
    this.createdAt,
    this.scheduledStartAt,
    this.distanceKm,
    this.category,
  });

  factory TaskLite.fromJson(Map<String, dynamic> json) => _$TaskLiteFromJson(json);

  Map<String, dynamic> toJson() => _$TaskLiteToJson(this);
}
