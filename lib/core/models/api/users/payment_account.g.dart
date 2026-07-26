// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentAccount _$PaymentAccountFromJson(Map<String, dynamic> json) =>
    PaymentAccount(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      provider: json['provider'] as String?,
      externalAccountId: json['external_account_id'] as String?,
      accountName: json['account_name'] as String?,
      accountMetadata: json['account_metadata'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$PaymentAccountToJson(PaymentAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'provider': instance.provider,
      'external_account_id': instance.externalAccountId,
      'account_name': instance.accountName,
      'account_metadata': instance.accountMetadata,
      'is_active': instance.isActive,
    };
