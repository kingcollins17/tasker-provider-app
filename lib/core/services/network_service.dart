import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'local_storage_service.dart';

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
        fallback: 'https://tasker-api-40zn.onrender.com',
      ),
      domain: dotenv.get('DOMAIN', fallback: 'tasker-api-40zn.onrender.com'),
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
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (_) => true,
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
