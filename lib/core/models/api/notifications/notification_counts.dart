import 'package:json_annotation/json_annotation.dart';

part 'notification_counts.g.dart';

@JsonSerializable()
class NotificationCounts {
  final int? read;
  final int? unread;

  NotificationCounts({
    this.read,
    this.unread,
  });

  factory NotificationCounts.fromJson(Map<String, dynamic> json) =>
      _$NotificationCountsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationCountsToJson(this);
}
