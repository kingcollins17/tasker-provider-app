// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_account_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyAccountData _$VerifyAccountDataFromJson(Map<String, dynamic> json) =>
    VerifyAccountData(
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      bankName: json['bank_name'] as String?,
      bankCode: json['bank_code'] as String?,
    );

Map<String, dynamic> _$VerifyAccountDataToJson(VerifyAccountData instance) =>
    <String, dynamic>{
      'account_number': instance.accountNumber,
      'account_name': instance.accountName,
      'bank_name': instance.bankName,
      'bank_code': instance.bankCode,
    };
