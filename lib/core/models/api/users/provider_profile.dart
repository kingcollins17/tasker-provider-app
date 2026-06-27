import 'package:json_annotation/json_annotation.dart';

part 'provider_profile.g.dart';

@JsonSerializable()
class ProviderProfile {
  final String? id;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'id_type')
  final String? idType;
  @JsonKey(name: 'id_number')
  final String? idNumber;
  @JsonKey(name: 'id_doc_url')
  final String? idDocUrl;
  @JsonKey(name: 'selfie_url')
  final String? selfieUrl;
  final String? gender;
  final String? status;
  @JsonKey(name: 'provider_reference')
  final String? providerReference;
  @JsonKey(name: 'liveness_score')
  final double? livenessScore;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @JsonKey(name: 'verified_at')
  final String? verifiedAt;
  @JsonKey(name: 'address_line')
  final String? addressLine;
  final List<dynamic>? services;

  ProviderProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.idType,
    this.idNumber,
    this.idDocUrl,
    this.selfieUrl,
    this.gender,
    this.status,
    this.providerReference,
    this.livenessScore,
    this.rejectionReason,
    this.verifiedAt,
    this.addressLine,
    this.services,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) =>
      _$ProviderProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderProfileToJson(this);
}
