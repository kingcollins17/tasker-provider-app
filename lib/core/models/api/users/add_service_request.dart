import 'package:json_annotation/json_annotation.dart';

part 'add_service_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AddServiceRequest {
  final String serviceId;

  AddServiceRequest({required this.serviceId});

  factory AddServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$AddServiceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddServiceRequestToJson(this);
}
