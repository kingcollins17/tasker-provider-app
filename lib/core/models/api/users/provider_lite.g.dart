// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_lite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProviderLite _$ProviderLiteFromJson(Map<String, dynamic> json) => ProviderLite(
  id: json['id'] as String?,
  fullname: json['fullname'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  averageRatings: (json['average_ratings'] as num?)?.toDouble(),
  credibilityScore: (json['credibility_score'] as num?)?.toDouble(),
  gender: json['gender'] as String?,
  profilePictureUrl: json['profile_picture_url'] as String?,
  selfieUrl: json['selfie_url'] as String?,
  totalTasksCompleted: (json['total_tasks_completed'] as num?)?.toInt(),
  location: json['location'] == null
      ? null
      : UserLocation.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProviderLiteToJson(ProviderLite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'average_ratings': instance.averageRatings,
      'credibility_score': instance.credibilityScore,
      'gender': instance.gender,
      'profile_picture_url': instance.profilePictureUrl,
      'selfie_url': instance.selfieUrl,
      'total_tasks_completed': instance.totalTasksCompleted,
      'location': instance.location,
    };
