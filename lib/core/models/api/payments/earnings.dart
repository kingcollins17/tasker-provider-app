import 'package:json_annotation/json_annotation.dart';

part 'earnings.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Earnings {
  final double? totalEarnings;

  Earnings({
    this.totalEarnings,
  });

  factory Earnings.fromJson(Map<String, dynamic> json) =>
      _$EarningsFromJson(json);

  Map<String, dynamic> toJson() => _$EarningsToJson(this);
}
