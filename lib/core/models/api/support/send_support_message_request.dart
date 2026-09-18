import 'package:json_annotation/json_annotation.dart';

part 'send_support_message_request.g.dart';

@JsonSerializable()
class SendSupportMessageRequest {
  final String body;
  final String? channel;

  SendSupportMessageRequest({
    required this.body,
    this.channel = 'IN_APP',
  });

  factory SendSupportMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendSupportMessageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SendSupportMessageRequestToJson(this);
}
