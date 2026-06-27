// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  type: json['type'] as String?,
  isActive: json['is_active'] as bool?,
  emailVerified: json['email_verified'] as bool?,
  phoneVerified: json['phone_verified'] as bool?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  regionId: json['region_id'] as String?,
  providerProfile: json['provider_profile'] == null
      ? null
      : ProviderProfile.fromJson(
          json['provider_profile'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'type': instance.type,
  'is_active': instance.isActive,
  'email_verified': instance.emailVerified,
  'phone_verified': instance.phoneVerified,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'region_id': instance.regionId,
  'provider_profile': instance.providerProfile,
};
