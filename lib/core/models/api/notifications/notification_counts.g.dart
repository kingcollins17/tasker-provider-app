// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_counts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationCounts _$NotificationCountsFromJson(Map<String, dynamic> json) =>
    NotificationCounts(
      read: (json['read'] as num?)?.toInt(),
      unread: (json['unread'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NotificationCountsToJson(NotificationCounts instance) =>
    <String, dynamic>{'read': instance.read, 'unread': instance.unread};
