// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guarantor_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GuarantorRequest _$GuarantorRequestFromJson(Map<String, dynamic> json) =>
    GuarantorRequest(
      guarantorName: json['guarantor_name'] as String,
      guarantorPhone: json['guarantor_phone'] as String,
      relationship: json['relationship'] as String?,
    );

Map<String, dynamic> _$GuarantorRequestToJson(GuarantorRequest instance) =>
    <String, dynamic>{
      'guarantor_name': instance.guarantorName,
      'guarantor_phone': instance.guarantorPhone,
      'relationship': instance.relationship,
    };
