// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KycDocument _$KycDocumentFromJson(Map<String, dynamic> json) => KycDocument(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  providerProfileId: json['provider_profile_id'] as String?,
  idType: json['id_type'] as String?,
  idNumber: json['id_number'] as String?,
  idDocUrl: json['id_doc_url'] as String?,
  status: json['status'] as String?,
  rejectionReason: json['rejection_reason'] as String?,
  attemptNumber: (json['attempt_number'] as num?)?.toInt(),
  metaData: json['meta_data'] as Map<String, dynamic>?,
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  reviewedAt: json['reviewed_at'] == null
      ? null
      : DateTime.parse(json['reviewed_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$KycDocumentToJson(KycDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'provider_profile_id': instance.providerProfileId,
      'id_type': instance.idType,
      'id_number': instance.idNumber,
      'id_doc_url': instance.idDocUrl,
      'status': instance.status,
      'rejection_reason': instance.rejectionReason,
      'attempt_number': instance.attemptNumber,
      'meta_data': instance.metaData,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'reviewed_at': instance.reviewedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
