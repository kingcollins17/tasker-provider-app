import 'package:json_annotation/json_annotation.dart';

part 'paginated_data.g.dart';

@JsonSerializable(
  genericArgumentFactories: true,
  fieldRename: FieldRename.snake,
)
class PaginatedData<T> {
  final List<T>? items;
  final int? total;
  final int? page;
  final int? perPage;

  PaginatedData({
    this.items,
    this.total,
    this.page,
    this.perPage,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedDataFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedDataToJson(this, toJsonT);
}
