import 'package:json_annotation/json_annotation.dart';

part 'support_timeline_item.g.dart';

@JsonSerializable()
class SupportTimelineItem {
  final String? id;

  @JsonKey(name: 'item_type')
  final String? itemType;

  final DateTime? timestamp;
  final String? title;
  final String? description;

  @JsonKey(name: 'actor_type')
  final String? actorType;

  @JsonKey(name: 'actor_id')
  final String? actorId;

  final Map<String, dynamic>? metadata;

  SupportTimelineItem({
    this.id,
    this.itemType,
    this.timestamp,
    this.title,
    this.description,
    this.actorType,
    this.actorId,
    this.metadata,
  });

  factory SupportTimelineItem.fromJson(Map<String, dynamic> json) =>
      _$SupportTimelineItemFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTimelineItemToJson(this);
}
