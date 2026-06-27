// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderProfile _$ProviderProfileFromJson(Map<String, dynamic> json) =>
    ProviderProfile(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      idType: json['id_type'] as String?,
      idNumber: json['id_number'] as String?,
      idDocUrl: json['id_doc_url'] as String?,
      selfieUrl: json['selfie_url'] as String?,
      gender: json['gender'] as String?,
      status: json['status'] as String?,
      providerReference: json['provider_reference'] as String?,
      livenessScore: (json['liveness_score'] as num?)?.toDouble(),
      rejectionReason: json['rejection_reason'] as String?,
      verifiedAt: json['verified_at'] as String?,
      addressLine: json['address_line'] as String?,
      services: json['services'] as List<dynamic>?,
    );

Map<String, dynamic> _$ProviderProfileToJson(ProviderProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'id_type': instance.idType,
      'id_number': instance.idNumber,
      'id_doc_url': instance.idDocUrl,
      'selfie_url': instance.selfieUrl,
      'gender': instance.gender,
      'status': instance.status,
      'provider_reference': instance.providerReference,
      'liveness_score': instance.livenessScore,
      'rejection_reason': instance.rejectionReason,
      'verified_at': instance.verifiedAt,
      'address_line': instance.addressLine,
      'services': instance.services,
    };
