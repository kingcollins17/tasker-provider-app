import 'package:json_annotation/json_annotation.dart';

part 'verify_email_request.g.dart';

@JsonSerializable()
class VerifyEmailRequest {
  final String? email;
  final String? code;

  VerifyEmailRequest({this.email, this.code});

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}
