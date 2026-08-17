import 'package:json_annotation/json_annotation.dart';

part 'update_cloud_messaging_token_request.g.dart';

@JsonSerializable()
class UpdateCloudMessagingTokenRequest {
  final String? token;
  final String? platform;

  UpdateCloudMessagingTokenRequest({this.token, this.platform});

  factory UpdateCloudMessagingTokenRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateCloudMessagingTokenRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateCloudMessagingTokenRequestToJson(this);
}
