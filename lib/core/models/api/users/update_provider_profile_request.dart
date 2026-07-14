import 'package:json_annotation/json_annotation.dart';

part 'update_provider_profile_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateProviderProfileRequest {
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? gender;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  UpdateProviderProfileRequest({
    this.firstName,
    this.lastName,
    this.gender,
    this.phoneNumber,
  });

  factory UpdateProviderProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProviderProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProviderProfileRequestToJson(this);
}
