// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportAttachment _$SupportAttachmentFromJson(Map<String, dynamic> json) =>
    SupportAttachment(
      id: json['id'] as String?,
      caseId: json['case_id'] as String?,
      messageId: json['message_id'] as String?,
      uploadedBy: json['uploaded_by'] as String?,
      storageKey: json['storage_key'] as String?,
      filename: json['filename'] as String?,
      mimeType: json['mime_type'] as String?,
      size: (json['size'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SupportAttachmentToJson(SupportAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'case_id': instance.caseId,
      'message_id': instance.messageId,
      'uploaded_by': instance.uploadedBy,
      'storage_key': instance.storageKey,
      'filename': instance.filename,
      'mime_type': instance.mimeType,
      'size': instance.size,
      'created_at': instance.createdAt?.toIso8601String(),
    };
