import 'package:json_annotation/json_annotation.dart';

part 'customer_lite.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CustomerLite {
  final String? id;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final double? averageRatings;
  final double? credibilityScore;
  final String? gender;

  CustomerLite({
    this.id,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.averageRatings,
    this.credibilityScore,
    this.gender,
  });

  factory CustomerLite.fromJson(Map<String, dynamic> json) =>
      _$CustomerLiteFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerLiteToJson(this);
}
