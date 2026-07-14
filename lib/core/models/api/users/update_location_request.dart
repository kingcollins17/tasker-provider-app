import 'package:json_annotation/json_annotation.dart';

part 'update_location_request.g.dart';

@JsonSerializable()
class UpdateLocationRequest {
  final double latitude;
  final double longitude;
  @JsonKey(name: 'address_line')
  final String? addressLine;
  @JsonKey(name: 'region_id')
  final String? regionId;

  UpdateLocationRequest({
    required this.latitude,
    required this.longitude,
    this.addressLine,
    this.regionId,
  });

  factory UpdateLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateLocationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateLocationRequestToJson(this);
}
