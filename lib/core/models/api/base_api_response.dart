import 'package:json_annotation/json_annotation.dart';

part 'base_api_response.g.dart';

/// A generic envelope class representing api responses.
@JsonSerializable(
  genericArgumentFactories: true,
  fieldRename: FieldRename.snake,
  explicitToJson: true,
)
class BaseApiResponse<T> {
  final dynamic detail;
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
      hasData ||
      (statusCode != null && statusCode! >= 200 && statusCode! < 300);

  /// Helper getter to check if the response is an error.
  bool get isError => !isSuccessful;

  /// Helper getter to check if response contains data.
  bool get hasData => data != null;

  /// Parses [detail] to return the exact error message.
  String? get errorMessage {
    if (detail == null) return null;
    if (detail is String) return detail as String;

    if (detail is List) {
      for (final item in (detail as List)) {
        final extracted = _parseMessageFromElement(item);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    if (detail is Map) {
      final extracted = _parseMessageFromElement(detail);
      if (extracted != null && extracted.isNotEmpty) {
        return extracted;
      }
    }

    return null;
  }

  /// Alias for [errorMessage].
  String? get detailMessage => errorMessage;

  static String? _parseMessageFromElement(dynamic element) {
    if (element == null) return null;
    if (element is String) return element;
    if (element is Map) {
      const keys = ['msg', 'message', 'error', 'errorMessage', 'detail'];
      for (final key in keys) {
        final val = element[key];
        if (val is String && val.isNotEmpty) {
          return val;
        }
      }
    }
    if (element is List) {
      for (final sub in element) {
        final res = _parseMessageFromElement(sub);
        if (res != null && res.isNotEmpty) return res;
      }
    }
    return null;
  }
}
