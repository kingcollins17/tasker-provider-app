import 'package:json_annotation/json_annotation.dart';

part 'update_region_request.g.dart';

@JsonSerializable()
class UpdateRegionRequest {
  @JsonKey(name: 'region_id')
  final String regionId;

  UpdateRegionRequest({
    required this.regionId,
  });

  factory UpdateRegionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateRegionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateRegionRequestToJson(this);
}
