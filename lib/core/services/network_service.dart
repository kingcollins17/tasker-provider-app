import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'local_storage_service.dart';
import '../utils/debug_logger.dart';

/// Class containing variables mapped from the .env configuration.
class AppEnvironments {
  final String baseUrl;
  final String domain;
  final int maxRetries;
  final String enviroment; // staging or prod

  AppEnvironments({
    required this.baseUrl,
    required this.domain,
    required this.maxRetries,
    required this.enviroment,
  });

  /// Loads configuration values from the .env file.
  factory AppEnvironments.load() {
    return AppEnvironments(
      baseUrl: dotenv.get(
        'BASE_URL',
        fallback: 'https://stellar-prosperity-production.up.railway.app',
      ),
      domain: dotenv.get('DOMAIN', fallback: 'stellar-prosperity-production.up.railway.app'),
      maxRetries: int.tryParse(dotenv.get('MAX_RETRIES', fallback: '3')) ?? 3,
      enviroment: dotenv.get('ENVIRONMENT', fallback: 'staging'),
    );
  }
}

/// Provider that exposes parsed [AppEnvironments].
final environmentsProvider = Provider<AppEnvironments>((ref) {
  return AppEnvironments.load();
});

/// Provider that exposes a configured [Dio] HTTP client.
final dioProvider = Provider<Dio>((ref) {
  final environments = ref.watch(environmentsProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: environments.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      validateStatus: (_) => true,
      maxRedirects: 2,
      extra: <String, dynamic>{'maxRetries': environments.maxRetries},
    ),
  );
  dio.interceptors.add(DioAuthInterceptor());
  if (kDebugMode) {
    // customization
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      ),
    );
  }

  dio.interceptors.add(DioDebugLoggerInterceptor());

  // Inject HTTP status code into the JSON response so BaseApiResponse can read it
  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (response, handler) {
        if (response.data is Map<String, dynamic>) {
          response.data['status_code'] = response.statusCode;
        }
        handler.next(response);
      },
    ),
  );

  return dio;
});

/// Interceptor that attaches the cached access token to Dio request headers.
class DioAuthInterceptor extends QueuedInterceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await appStorage.get<String>(HiveKeys.accessToken.name);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}

dynamic _makeJsonEncodable(dynamic value) {
  if (value == null || value is num || value is bool || value is String) {
    return value;
  }
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _makeJsonEncodable(v)));
  }
  if (value is Iterable) {
    return value.map(_makeJsonEncodable).toList();
  }
  if (value is FormData) {
    return {
      'fields': value.fields
          .map((f) => {'name': f.key, 'value': f.value})
          .toList(),
      'files': value.files
          .map((f) => {'name': f.key, 'filename': f.value.filename})
          .toList(),
    };
  }
  try {
    final dynamic dynamicVal = value;
    return dynamicVal.toJson();
  } catch (_) {
    return value.toString();
  }
}

/// Interceptor that formats network requests, responses, and errors as JSON and logs directly to [DebugLogger].
class DioDebugLoggerInterceptor extends Interceptor {
  void _addNetworkLog(Map<String, dynamic> logMap) {
    try {
      const encoder = JsonEncoder.withIndent('     ');
      final output = encoder.convert(logMap);
      DebugLogger.instance.addLog(
        DebugData(
          level: DebugLevel.network,
          data: output,
          timestamp: DateTime.now(),
        ),
      );
    } catch (_) {}
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final logMap = <String, dynamic>{
        'type': 'HTTP_REQUEST',
        'method': options.method,
        'url': options.uri.toString(),
        'headers': _makeJsonEncodable(options.headers),
        if (options.queryParameters.isNotEmpty)
          'query_parameters': _makeJsonEncodable(options.queryParameters),
        if (options.data != null) 'body': _makeJsonEncodable(options.data),
      };
      _addNetworkLog(logMap);
    } catch (_) {}
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final logMap = <String, dynamic>{
        'type': 'HTTP_RESPONSE',
        'method': response.requestOptions.method,
        'url': response.requestOptions.uri.toString(),
        'status_code': response.statusCode,
        'status_message': response.statusMessage,
        if (response.data != null) 'data': _makeJsonEncodable(response.data),
      };
      _addNetworkLog(logMap);
    } catch (_) {}
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final logMap = <String, dynamic>{
        'type': 'HTTP_ERROR',
        'method': err.requestOptions.method,
        'url': err.requestOptions.uri.toString(),
        'status_code': err.response?.statusCode,
        'error_type': err.type.name,
        'message': err.message,
        if (err.response?.data != null)
          'response': _makeJsonEncodable(err.response?.data),
      };
      _addNetworkLog(logMap);
    } catch (_) {}
    super.onError(err, handler);
  }
}
