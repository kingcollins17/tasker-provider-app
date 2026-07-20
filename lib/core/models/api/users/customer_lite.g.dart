// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_lite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerLite _$CustomerLiteFromJson(Map<String, dynamic> json) => CustomerLite(
  id: json['id'] as String?,
  fullname: json['fullname'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  averageRatings: (json['average_ratings'] as num?)?.toDouble(),
  credibilityScore: (json['credibility_score'] as num?)?.toDouble(),
  gender: json['gender'] as String?,
);

Map<String, dynamic> _$CustomerLiteToJson(CustomerLite instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'average_ratings': instance.averageRatings,
      'credibility_score': instance.credibilityScore,
      'gender': instance.gender,
    };
