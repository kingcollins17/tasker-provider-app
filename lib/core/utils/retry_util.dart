/// Callback signature expected by Riverpod's `retry` provider parameter.
typedef RetryFunc = Duration? Function(int retryCount, Object error);

/// Creates a [RetryFunc] suitable for Riverpod providers.
///
/// Parameters:
/// - [maxAttempts]: Maximum number of retry attempts before giving up (default: 3).
/// - [delay]: Base delay duration between retry attempts (default: 1 second).
/// - [exponentialBackoff]: If `true`, multiplies the delay exponentially on each retry attempt (default: `false`).
/// - [maxDelay]: Optional maximum delay cap when [exponentialBackoff] is enabled.
/// - [retryIf]: Optional predicate to selectively retry only matching errors.
///
/// Usage examples:
/// ```dart
/// // 1. Retry up to 3 times with default 1s delay:
/// retry: retryFunc(3)
///
/// // 2. Retry up to 5 times with 2s delay and exponential backoff:
/// retry: retryFunc(5, const Duration(seconds: 2), true)
///
/// // 3. Retry only specific network errors:
/// retry: retryFunc(3, const Duration(seconds: 1), false, null, (e) => e is SocketException)
/// ```
RetryFunc retryFunc([
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 1),
  bool exponentialBackoff = false,
  Duration? maxDelay,
  bool Function(Object error)? retryIf,
]) {
  return (int retryCount, Object error) {
    if (retryCount >= maxAttempts) {
      return null;
    }

    if (retryIf != null && !retryIf(error)) {
      return null;
    }

    if (exponentialBackoff) {
      final factor = 1 << (retryCount > 0 ? retryCount - 1 : 0);
      final computedDelay = delay * factor;
      if (maxDelay != null && computedDelay > maxDelay) {
        return maxDelay;
      }
      return computedDelay;
    }

    return delay;
  };
}
