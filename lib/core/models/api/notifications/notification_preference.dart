import 'package:json_annotation/json_annotation.dart';

part 'notification_preference.g.dart';

@JsonSerializable()
class NotificationPreference {
  @JsonKey(name: 'notification_type')
  final String? notificationType;
  final String? channel;
  final bool? enabled;

  NotificationPreference({
    this.notificationType,
    this.channel,
    this.enabled,
  });

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferenceFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationPreferenceToJson(this);
}
