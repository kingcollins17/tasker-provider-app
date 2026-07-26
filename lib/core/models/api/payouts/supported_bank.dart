import 'package:json_annotation/json_annotation.dart';

part 'supported_bank.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SupportedBank {
  final String? id;
  final String? bankCode;
  final String? name;
  final String? logoUrl;

  SupportedBank({
    this.id,
    this.bankCode,
    this.name,
    this.logoUrl,
  });

  factory SupportedBank.fromJson(Map<String, dynamic> json) =>
      _$SupportedBankFromJson(json);

  Map<String, dynamic> toJson() => _$SupportedBankToJson(this);
}
