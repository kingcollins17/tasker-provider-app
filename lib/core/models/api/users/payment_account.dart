import 'package:json_annotation/json_annotation.dart';

part 'payment_account.g.dart';

@JsonSerializable()
class PaymentAccount {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  final String? provider;
  @JsonKey(name: 'external_account_id')
  final String? externalAccountId;
  @JsonKey(name: 'account_name')
  final String? accountName;
  @JsonKey(name: 'account_metadata')
  final Map<String, dynamic>? accountMetadata;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  PaymentAccount({
    this.id,
    this.userId,
    this.provider,
    this.externalAccountId,
    this.accountName,
    this.accountMetadata,
    this.isActive,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) =>
      _$PaymentAccountFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAccountToJson(this);
}
