// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_timeline_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportTimelineItem _$SupportTimelineItemFromJson(Map<String, dynamic> json) =>
    SupportTimelineItem(
      id: json['id'] as String?,
      itemType: json['item_type'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      title: json['title'] as String?,
      description: json['description'] as String?,
      actorType: json['actor_type'] as String?,
      actorId: json['actor_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SupportTimelineItemToJson(
  SupportTimelineItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'item_type': instance.itemType,
  'timestamp': instance.timestamp?.toIso8601String(),
  'title': instance.title,
  'description': instance.description,
  'actor_type': instance.actorType,
  'actor_id': instance.actorId,
  'metadata': instance.metadata,
};
