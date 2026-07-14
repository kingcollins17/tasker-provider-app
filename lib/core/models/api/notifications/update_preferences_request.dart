import 'package:json_annotation/json_annotation.dart';
import 'notification_preference.dart';

part 'update_preferences_request.g.dart';

@JsonSerializable()
class UpdatePreferencesRequest {
  final List<NotificationPreference> preferences;

  UpdatePreferencesRequest({
    required this.preferences,
  });

  factory UpdatePreferencesRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePreferencesRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePreferencesRequestToJson(this);
}
