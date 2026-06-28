import 'package:json_annotation/json_annotation.dart';
import 'category.dart';

part 'service.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Service {
  final String? id;
  final String? name;
  final String? imageUrl;
  final double? takeRate;
  final bool? isActive;
  final String? categoryId;
  final Category? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Service({
    this.id,
    this.name,
    this.imageUrl,
    this.takeRate,
    this.isActive,
    this.categoryId,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
