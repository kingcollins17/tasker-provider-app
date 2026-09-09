// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_price_adjustment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePriceAdjustmentRequest _$CreatePriceAdjustmentRequestFromJson(
  Map<String, dynamic> json,
) => CreatePriceAdjustmentRequest(
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$CreatePriceAdjustmentRequestToJson(
  CreatePriceAdjustmentRequest instance,
) => <String, dynamic>{
  'amount': instance.amount,
  'description': instance.description,
};
