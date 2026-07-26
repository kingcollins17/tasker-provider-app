// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_account_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentAccountRequest _$CreatePaymentAccountRequestFromJson(
  Map<String, dynamic> json,
) => CreatePaymentAccountRequest(
  bankCode: json['bank_code'] as String?,
  bankName: json['bank_name'] as String?,
  accountName: json['account_name'] as String?,
  accountNumber: json['account_number'] as String?,
);

Map<String, dynamic> _$CreatePaymentAccountRequestToJson(
  CreatePaymentAccountRequest instance,
) => <String, dynamic>{
  'bank_code': instance.bankCode,
  'bank_name': instance.bankName,
  'account_name': instance.accountName,
  'account_number': instance.accountNumber,
};
