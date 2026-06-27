import 'debug_logger.dart';

/// A global singleton to handle application-wide exceptions and errors.
class AppExceptionHandler {
  // Private constructor for singleton
  AppExceptionHandler._privateConstructor();

  // Static instance
  static final AppExceptionHandler instance = AppExceptionHandler._privateConstructor();

  /// Handles app exceptions globally (e.g. logging or sending to monitoring tools).
  void handleError(dynamic error, [StackTrace? stackTrace]) {
    debugLog('App Exception Caught: $error');
    if (stackTrace != null) {
      debugLog('Stacktrace:\n$stackTrace');
    }
  }
}
