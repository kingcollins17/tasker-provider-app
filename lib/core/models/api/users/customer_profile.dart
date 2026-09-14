import 'package:json_annotation/json_annotation.dart';

part 'customer_profile.g.dart';

@JsonSerializable()
class CustomerProfile {
  final String? id;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'address_line')
  final String? addressLine;

  CustomerProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.addressLine,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerProfileToJson(this);
}
