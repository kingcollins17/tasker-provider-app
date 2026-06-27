import 'package:dio/dio.dart';

/// Extension on [Object] to convert any caught exception or error to a user-friendly message.
extension ErrorExt on Object {
  String toFriendlyString() {
    final error = this;
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection and try again.';
        case DioExceptionType.badResponse:
          final response = error.response;
          if (response != null && response.data is Map) {
            final data = response.data as Map;
            if (data.containsKey('detail')) {
              return data['detail']?.toString() ?? 'Server returned an invalid error format.';
            }
          }
          return 'Server error (status code: ${response?.statusCode ?? "unknown"}).';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network connection and try again.';
        case DioExceptionType.cancel:
          return 'The request was cancelled.';
        default:
          return 'A network error occurred. Please try again.';
      }
    }
    return error.toString();
  }
}
