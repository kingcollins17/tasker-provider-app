import 'package:json_annotation/json_annotation.dart';

part 'update_online_status_request.g.dart';

@JsonSerializable()
class UpdateOnlineStatusRequest {
  @JsonKey(name: 'is_online')
  final bool isOnline;

  UpdateOnlineStatusRequest({required this.isOnline});

  factory UpdateOnlineStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateOnlineStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateOnlineStatusRequestToJson(this);
}
