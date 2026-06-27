import 'package:json_annotation/json_annotation.dart';

part 'region.g.dart';

@JsonSerializable()
class Region {
  final String? id;
  @JsonKey(name: 'address_line')
  final String? addressLine;
  final String? state;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'total_providers')
  final int? totalProviders;
  @JsonKey(name: 'total_customers')
  final int? totalCustomers;
  @JsonKey(name: 'total_tasks')
  final int? totalTasks;
  @JsonKey(name: 'total_staff')
  final int? totalStaff;
  final String? location;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Region({
    this.id,
    this.addressLine,
    this.state,
    this.isActive,
    this.totalProviders,
    this.totalCustomers,
    this.totalTasks,
    this.totalStaff,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Region.fromJson(Map<String, dynamic> json) =>
      _$RegionFromJson(json);

  Map<String, dynamic> toJson() => _$RegionToJson(this);
}
