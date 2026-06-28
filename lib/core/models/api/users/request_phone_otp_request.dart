import 'package:json_annotation/json_annotation.dart';

part 'request_phone_otp_request.g.dart';

@JsonSerializable()
class RequestPhoneOtpRequest {
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  RequestPhoneOtpRequest({this.phoneNumber});

  factory RequestPhoneOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestPhoneOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestPhoneOtpRequestToJson(this);
}
