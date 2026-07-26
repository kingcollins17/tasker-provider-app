import 'package:json_annotation/json_annotation.dart';

part 'ping_location_request.g.dart';

@JsonSerializable()
class PingLocationRequest {
  final double latitude;
  final double longitude;

  PingLocationRequest({
    required this.latitude,
    required this.longitude,
  });

  factory PingLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$PingLocationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PingLocationRequestToJson(this);
}
