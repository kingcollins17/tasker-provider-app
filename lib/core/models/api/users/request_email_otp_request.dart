import 'package:json_annotation/json_annotation.dart';

part 'request_email_otp_request.g.dart';

@JsonSerializable()
class RequestEmailOtpRequest {
  final String? email;

  RequestEmailOtpRequest({this.email});

  factory RequestEmailOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestEmailOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestEmailOtpRequestToJson(this);
}
