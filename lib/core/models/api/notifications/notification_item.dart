import 'package:json_annotation/json_annotation.dart';

part 'notification_item.g.dart';

@JsonSerializable()
class NotificationItem {
  @JsonKey(name: 'notification_id')
  final String? notificationId;
  @JsonKey(name: 'recipient_record_id')
  final String? recipientRecordId;
  final String? type;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? priority;
  final String? status;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  NotificationItem({
    this.notificationId,
    this.recipientRecordId,
    this.type,
    this.title,
    this.body,
    this.data,
    this.priority,
    this.status,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null;
  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}
