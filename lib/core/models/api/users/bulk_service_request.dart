import 'package:json_annotation/json_annotation.dart';

part 'bulk_service_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BulkServiceRequest {
  final List<String>? serviceIds;

  BulkServiceRequest({this.serviceIds});

  factory BulkServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$BulkServiceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BulkServiceRequestToJson(this);
}
