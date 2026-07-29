// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Earnings _$EarningsFromJson(Map<String, dynamic> json) => Earnings(
  totalEarnings: (json['total_earnings'] as num?)?.toDouble(),
  percentageGrowth: (json['percentage_growth'] as num?)?.toDouble(),
);

Map<String, dynamic> _$EarningsToJson(Earnings instance) => <String, dynamic>{
  'total_earnings': instance.totalEarnings,
  'percentage_growth': instance.percentageGrowth,
};
