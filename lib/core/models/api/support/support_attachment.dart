import 'package:json_annotation/json_annotation.dart';

part 'support_attachment.g.dart';

@JsonSerializable()
class SupportAttachment {
  final String? id;

  @JsonKey(name: 'case_id')
  final String? caseId;

  @JsonKey(name: 'message_id')
  final String? messageId;

  @JsonKey(name: 'uploaded_by')
  final String? uploadedBy;

  @JsonKey(name: 'storage_key')
  final String? storageKey;

  final String? filename;

  @JsonKey(name: 'mime_type')
  final String? mimeType;

  final int? size;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  SupportAttachment({
    this.id,
    this.caseId,
    this.messageId,
    this.uploadedBy,
    this.storageKey,
    this.filename,
    this.mimeType,
    this.size,
    this.createdAt,
  });

  factory SupportAttachment.fromJson(Map<String, dynamic> json) =>
      _$SupportAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$SupportAttachmentToJson(this);
}
