import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? password;
  final String? type;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? gender;
  @JsonKey(name: 'region_id')
  final String? regionId;

  RegisterRequest({
    this.email,
    this.phoneNumber,
    this.password,
    this.type = 'provider',
    this.firstName,
    this.lastName,
    this.gender,
    this.regionId,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
