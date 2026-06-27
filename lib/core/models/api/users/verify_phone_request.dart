import 'package:json_annotation/json_annotation.dart';

part 'verify_phone_request.g.dart';

@JsonSerializable()
class VerifyPhoneRequest {
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? code;

  VerifyPhoneRequest({this.phoneNumber, this.code});

  factory VerifyPhoneRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyPhoneRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPhoneRequestToJson(this);
}
