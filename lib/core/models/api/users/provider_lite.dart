import 'package:json_annotation/json_annotation.dart';
import 'user_location.dart';

part 'provider_lite.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ProviderLite {
  final String? id;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final double? averageRatings;
  final double? credibilityScore;
  final String? gender;
  final String? profilePictureUrl;
  final String? selfieUrl;
  final int? totalTasksCompleted;
  final UserLocation? location;

  ProviderLite({
    this.id,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.averageRatings,
    this.credibilityScore,
    this.gender,
    this.profilePictureUrl,
    this.selfieUrl,
    this.totalTasksCompleted,
    this.location,
  });

  factory ProviderLite.fromJson(Map<String, dynamic> json) =>
      _$ProviderLiteFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderLiteToJson(this);
}
