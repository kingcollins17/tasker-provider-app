// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guarantor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Guarantor _$GuarantorFromJson(Map<String, dynamic> json) => Guarantor(
  id: json['id'] as String?,
  providerId: json['provider_id'] as String?,
  guarantorName: json['guarantor_name'] as String?,
  guarantorPhone: json['guarantor_phone'] as String?,
  relationship: json['relationship'] as String?,
  status: json['status'] as String?,
  metadata: json['meta_data'] as Map<String, dynamic>?,
  verifiedAt: json['verified_at'] == null
      ? null
      : DateTime.parse(json['verified_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GuarantorToJson(Guarantor instance) => <String, dynamic>{
  'id': instance.id,
  'provider_id': instance.providerId,
  'guarantor_name': instance.guarantorName,
  'guarantor_phone': instance.guarantorPhone,
  'relationship': instance.relationship,
  'status': instance.status,
  'meta_data': instance.metadata,
  'verified_at': instance.verifiedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
};
