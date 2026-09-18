// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_support_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendSupportMessageRequest _$SendSupportMessageRequestFromJson(
  Map<String, dynamic> json,
) => SendSupportMessageRequest(
  body: json['body'] as String,
  channel: json['channel'] as String? ?? 'IN_APP',
);

Map<String, dynamic> _$SendSupportMessageRequestToJson(
  SendSupportMessageRequest instance,
) => <String, dynamic>{'body': instance.body, 'channel': instance.channel};
