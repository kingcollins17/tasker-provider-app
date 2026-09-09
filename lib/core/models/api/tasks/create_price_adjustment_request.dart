import 'package:json_annotation/json_annotation.dart';

part 'create_price_adjustment_request.g.dart';

/// Request body for `POST /api/v1/tasks/{task_id}/price-adjustments`.
@JsonSerializable(fieldRename: FieldRename.snake)
class CreatePriceAdjustmentRequest {
  final double amount;
  final String? description;

  CreatePriceAdjustmentRequest({
    required this.amount,
    this.description,
  });

  factory CreatePriceAdjustmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePriceAdjustmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePriceAdjustmentRequestToJson(this);
}
