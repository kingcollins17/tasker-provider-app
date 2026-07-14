// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreference _$NotificationPreferenceFromJson(
  Map<String, dynamic> json,
) => NotificationPreference(
  notificationType: json['notification_type'] as String?,
  channel: json['channel'] as String?,
  enabled: json['enabled'] as bool?,
);

Map<String, dynamic> _$NotificationPreferenceToJson(
  NotificationPreference instance,
) => <String, dynamic>{
  'notification_type': instance.notificationType,
  'channel': instance.channel,
  'enabled': instance.enabled,
};
