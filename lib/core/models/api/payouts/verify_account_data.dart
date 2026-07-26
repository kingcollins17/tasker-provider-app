import 'package:json_annotation/json_annotation.dart';

part 'verify_account_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VerifyAccountData {
  final String? accountNumber;
  final String? accountName;
  final String? bankName;
  final String? bankCode;

  VerifyAccountData({
    this.accountNumber,
    this.accountName,
    this.bankName,
    this.bankCode,
  });

  factory VerifyAccountData.fromJson(Map<String, dynamic> json) =>
      _$VerifyAccountDataFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyAccountDataToJson(this);
}
