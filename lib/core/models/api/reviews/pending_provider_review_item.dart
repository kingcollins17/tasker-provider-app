import 'package:json_annotation/json_annotation.dart';
import '../users/customer_lite.dart';
import '../users/provider_lite.dart';

part 'pending_provider_review_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PendingProviderReviewItem {
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
  final CustomerLite? customer;
  final ProviderLite? provider;

  PendingProviderReviewItem({
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
    this.customer,
    this.provider,
  });

  factory PendingProviderReviewItem.fromJson(Map<String, dynamic> json) =>
      _$PendingProviderReviewItemFromJson(json);

  Map<String, dynamic> toJson() => _$PendingProviderReviewItemToJson(this);
}
