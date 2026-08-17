// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_service_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BulkServiceRequest _$BulkServiceRequestFromJson(Map<String, dynamic> json) =>
    BulkServiceRequest(
      serviceIds: (json['service_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BulkServiceRequestToJson(BulkServiceRequest instance) =>
    <String, dynamic>{'service_ids': instance.serviceIds};
