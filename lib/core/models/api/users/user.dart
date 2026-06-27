import 'package:json_annotation/json_annotation.dart';
import 'provider_profile.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String? id;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? type;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @JsonKey(name: 'phone_verified')
  final bool? phoneVerified;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'region_id')
  final String? regionId;
  @JsonKey(name: 'provider_profile')
  final ProviderProfile? providerProfile;

  User({
    this.id,
    this.email,
    this.phoneNumber,
    this.type,
    this.isActive,
    this.emailVerified,
    this.phoneVerified,
    this.createdAt,
    this.updatedAt,
    this.regionId,
    this.providerProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
