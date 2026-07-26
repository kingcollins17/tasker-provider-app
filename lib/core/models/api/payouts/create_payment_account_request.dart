import 'package:json_annotation/json_annotation.dart';

part 'create_payment_account_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CreatePaymentAccountRequest {
  final String? bankCode;
  final String? bankName;
  final String? accountName;
  final String? accountNumber;

  CreatePaymentAccountRequest({
    this.bankCode,
    this.bankName,
    this.accountName,
    this.accountNumber,
  });

  factory CreatePaymentAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentAccountRequestToJson(this);
}
