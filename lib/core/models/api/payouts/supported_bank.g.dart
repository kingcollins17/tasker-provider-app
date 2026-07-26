// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supported_bank.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportedBank _$SupportedBankFromJson(Map<String, dynamic> json) =>
    SupportedBank(
      id: json['id'] as String?,
      bankCode: json['bank_code'] as String?,
      name: json['name'] as String?,
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$SupportedBankToJson(SupportedBank instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_code': instance.bankCode,
      'name': instance.name,
      'logo_url': instance.logoUrl,
    };
