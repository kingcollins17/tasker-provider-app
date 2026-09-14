import 'package:json_annotation/json_annotation.dart';

part 'guarantor_request.g.dart';

@JsonSerializable()
class GuarantorRequest {
  @JsonKey(name: 'guarantor_name')
  final String guarantorName;

  @JsonKey(name: 'guarantor_phone')
  final String guarantorPhone;

  final String? relationship;

  GuarantorRequest({
    required this.guarantorName,
    required this.guarantorPhone,
    this.relationship,
  });

  factory GuarantorRequest.fromJson(Map<String, dynamic> json) =>
      _$GuarantorRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GuarantorRequestToJson(this);
}
