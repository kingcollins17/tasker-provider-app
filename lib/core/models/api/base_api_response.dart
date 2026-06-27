import 'package:json_annotation/json_annotation.dart';

part 'base_api_response.g.dart';

/// A generic envelope class representing api responses.
@JsonSerializable(genericArgumentFactories: true)
class BaseApiResponse<T> {
  final String? detail;
  final int? statusCode;
  final T? data;

  BaseApiResponse({required this.detail, required this.statusCode, this.data});

  factory BaseApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$BaseApiResponseToJson(this, toJsonT);

  /// Helper getter to check if the response is successful (status code 200-299).
  bool get isSuccessful =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Helper getter to check if the response is an error.
  bool get isError => !isSuccessful;

  /// Helper getter to check if response contains data.
  bool get hasData => data != null;
}
