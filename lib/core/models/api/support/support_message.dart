import 'package:json_annotation/json_annotation.dart';

part 'support_message.g.dart';

@JsonSerializable()
class SupportMessage {
  final String? id;

  @JsonKey(name: 'case_id')
  final String? caseId;

  @JsonKey(name: 'sender_type')
  final String? senderType;

  @JsonKey(name: 'sender_id')
  final String? senderId;

  final String? channel;
  final String? visibility;
  final String? body;

  @JsonKey(name: 'email_message_id')
  final String? emailMessageId;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  SupportMessage({
    this.id,
    this.caseId,
    this.senderType,
    this.senderId,
    this.channel,
    this.visibility,
    this.body,
    this.emailMessageId,
    this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) =>
      _$SupportMessageFromJson(json);

  Map<String, dynamic> toJson() => _$SupportMessageToJson(this);
}
