// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_preferences_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePreferencesRequest _$UpdatePreferencesRequestFromJson(
  Map<String, dynamic> json,
) => UpdatePreferencesRequest(
  preferences: (json['preferences'] as List<dynamic>)
      .map((e) => NotificationPreference.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UpdatePreferencesRequestToJson(
  UpdatePreferencesRequest instance,
) => <String, dynamic>{'preferences': instance.preferences};
