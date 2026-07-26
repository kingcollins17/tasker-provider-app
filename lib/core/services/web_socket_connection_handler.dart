import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../utils/debug_logger.dart';

/// Configuration for the WebSocket reconnection strategy.
class WebSocketConfig {
  /// Base delay between reconnection attempts.
  ///
  /// This is the delay used for the first retry. Subsequent retries will
  /// multiply this value by powers of 2 when [useExponentialBackoff] is true.
  final Duration reconnectDelay;

  /// Maximum number of consecutive reconnection attempts before giving up.
  ///
  /// Set to `null` for unlimited retries (use with caution).
  final int? maxReconnectAttempts;

  /// Whether to apply exponential backoff to the reconnect delay.
  ///
  /// When true, each successive retry waits `reconnectDelay * 2^attempt`,
  /// capped at [maxReconnectDelay].
  final bool useExponentialBackoff;

  /// Upper bound for the computed reconnect delay when exponential backoff
  /// is enabled.
  final Duration maxReconnectDelay;

  /// Duration after which a silent connection is considered stale.
  ///
  /// If no message is received within this window a reconnection is triggered.
  /// Set to `null` to disable the ping timeout.
  final Duration? pingTimeout;

  const WebSocketConfig({
    this.reconnectDelay = const Duration(seconds: 3),
    this.maxReconnectAttempts = 5,
    this.useExponentialBackoff = true,
    this.maxReconnectDelay = const Duration(seconds: 30),
    this.pingTimeout,
  });

  /// A preset suitable for development — fast retries with low limits.
  static const debug = WebSocketConfig(
    reconnectDelay: Duration(seconds: 1),
    maxReconnectAttempts: 3,
    useExponentialBackoff: false,
  );
}

/// Describes the current state of the WebSocket connection.
enum WebSocketConnectionState {
  /// No connection has been established yet.
  disconnected,

  /// A connection attempt is in progress.
  connecting,

  /// The connection is active and receiving messages.
  connected,

  /// A reconnection attempt is in progress.
  reconnecting,

  /// All reconnection attempts have been exhausted.
  failed,

  /// The connection was closed intentionally by the caller.
  closed,
}

/// A robust WebSocket client that wraps [WebSocketChannel], automatically
/// decodes incoming JSON messages, and transparently handles reconnection
/// with configurable back-off.
///
/// ### Usage
/// ```dart
/// final handler = WebSocketConnectionHandler(
///   url: 'wss://example.com/ws',
///   config: const WebSocketConfig(maxReconnectAttempts: 10),
/// );
///
/// handler.connect();
///
/// handler.messageStream.listen((json) {
///   print('Received: $json');
/// });
///
/// // Later…
/// handler.dispose();
/// ```
class WebSocketConnectionHandler {
  /// The WebSocket endpoint URL (must start with `ws://` or `wss://`).
  final String url;

  /// Optional HTTP headers sent during the handshake (e.g. auth tokens).
  final Map<String, dynamic>? headers;

  /// Optional query parameters appended to the connection URL.
  final Map<String, String>? queryParameters;

  /// Reconnection and timeout configuration.
  final WebSocketConfig config;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  int _reconnectAttempts = 0;
  bool _isDisposed = false;
  bool _intentionallyClosed = false;

  /// Controller for the decoded JSON messages exposed to callers.
  final _messageController = StreamController<dynamic>.broadcast();

  /// Controller for connection state changes.
  final _stateController =
      StreamController<WebSocketConnectionState>.broadcast();

  WebSocketConnectionState _state = WebSocketConnectionState.disconnected;

  WebSocketConnectionHandler({
    required this.url,
    this.headers,
    this.queryParameters,
    this.config = const WebSocketConfig(),
  });

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Stream of decoded JSON messages (`Map<String, dynamic>`, `List`, etc.).
  ///
  /// Messages that fail JSON decoding are silently dropped and logged in debug
  /// mode.
  Stream<dynamic> get messageStream => _messageController.stream;

  /// Stream of connection state changes.
  Stream<WebSocketConnectionState> get stateStream => _stateController.stream;

  /// The current connection state.
  WebSocketConnectionState get state => _state;

  /// Whether the handler has been disposed and can no longer be used.
  bool get isDisposed => _isDisposed;

  /// Opens the WebSocket connection.
  ///
  /// If a connection is already active this method is a no-op.
  void connect() {
    if (_isDisposed) {
      debugLog('WebSocketConnectionHandler: cannot connect — already disposed');
      return;
    }

    if (_state == WebSocketConnectionState.connected ||
        _state == WebSocketConnectionState.connecting) {
      return;
    }

    _intentionallyClosed = false;
    _reconnectAttempts = 0;
    _connect();
  }

  /// Sends a JSON-serialisable [data] object over the active connection.
  ///
  /// Throws a [StateError] when called on a connection that is not in the
  /// [WebSocketConnectionState.connected] state.
  void send(Object data) {
    if (_state != WebSocketConnectionState.connected || _channel == null) {
      throw StateError(
        'WebSocketConnectionHandler: cannot send — '
        'connection is not active (state: $_state)',
      );
    }

    final encoded = jsonEncode(data);
    _channel!.sink.add(encoded);
  }

  /// Gracefully closes the connection without triggering reconnection.
  Future<void> disconnect() async {
    _intentionallyClosed = true;
    await _teardown();
    _setState(WebSocketConnectionState.closed);
  }

  /// Closes the connection and releases all resources.
  ///
  /// After calling this the handler instance must not be reused.
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _intentionallyClosed = true;

    await _teardown();
    await _messageController.close();
    await _stateController.close();
  }

  // ---------------------------------------------------------------------------
  // Internal – connection lifecycle
  // ---------------------------------------------------------------------------

  void _connect() {
    _setState(WebSocketConnectionState.connecting);

    try {
      final uri = _buildUri();
      _channel = WebSocketChannel.connect(uri, protocols: null);

      _channelSubscription = _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // The stream subscription starting without an immediate error indicates
      // the underlying socket connected.  We flip state on the first
      // successful data frame, but also optimistically mark connected here so
      // callers can start sending right away.
      _setState(WebSocketConnectionState.connected);
      _reconnectAttempts = 0;
      _resetPingTimer();

      debugLog('WebSocketConnectionHandler: connected to $uri');
    } catch (e, st) {
      debugLog('WebSocketConnectionHandler: connection failed — $e');
      debugLog('$st');
      _scheduleReconnect();
    }
  }

  Uri _buildUri() {
    final base = Uri.parse(url);
    if (queryParameters != null && queryParameters!.isNotEmpty) {
      return base.replace(
        queryParameters: {...base.queryParameters, ...queryParameters!},
      );
    }
    return base;
  }

  // ---------------------------------------------------------------------------
  // Internal – stream callbacks
  // ---------------------------------------------------------------------------

  void _onData(dynamic raw) {
    _resetPingTimer();

    if (raw is! String) {
      debugLog(
        'WebSocketConnectionHandler: received non-string data '
        '(${raw.runtimeType}), skipping',
      );
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      _messageController.add(decoded);
      debugLog('WebSocketConnectionHandler: Received message from websocket');
      debugLog(decoded);
    } catch (e) {
      debugLog('WebSocketConnectionHandler: JSON decode failed for: $raw — $e');
    }
  }

  void _onError(Object error, StackTrace stackTrace) {
    debugLog('WebSocketConnectionHandler: stream error — $error');
    if (kDebugMode) {
      debugLog('$stackTrace');
    }

    if (!_intentionallyClosed && !_isDisposed) {
      _scheduleReconnect();
    }
  }

  void _onDone() {
    debugLog('WebSocketConnectionHandler: connection closed');

    if (!_intentionallyClosed && !_isDisposed) {
      _scheduleReconnect();
    }
  }

  // ---------------------------------------------------------------------------
  // Internal – reconnection
  // ---------------------------------------------------------------------------

  void _scheduleReconnect() {
    _cancelTimers();
    _channelSubscription?.cancel();
    _channelSubscription = null;

    final maxAttempts = config.maxReconnectAttempts;
    if (maxAttempts != null && _reconnectAttempts >= maxAttempts) {
      debugLog(
        'WebSocketConnectionHandler: max reconnect attempts '
        '($maxAttempts) reached — giving up',
      );
      _setState(WebSocketConnectionState.failed);
      return;
    }

    _setState(WebSocketConnectionState.reconnecting);

    final delay = _computeDelay();
    _reconnectAttempts++;

    debugLog(
      'WebSocketConnectionHandler: reconnecting in '
      '${delay.inMilliseconds}ms (attempt $_reconnectAttempts'
      '${maxAttempts != null ? '/$maxAttempts' : ''})',
    );

    _reconnectTimer = Timer(delay, () {
      if (!_isDisposed && !_intentionallyClosed) {
        _connect();
      }
    });
  }

  Duration _computeDelay() {
    if (!config.useExponentialBackoff) {
      return config.reconnectDelay;
    }

    // 2^attempt * baseDelay, capped at maxReconnectDelay
    final multiplier = 1 << _reconnectAttempts; // 1, 2, 4, 8 …
    final computed = config.reconnectDelay * multiplier;

    return computed > config.maxReconnectDelay
        ? config.maxReconnectDelay
        : computed;
  }

  // ---------------------------------------------------------------------------
  // Internal – ping / stale-connection detection
  // ---------------------------------------------------------------------------

  void _resetPingTimer() {
    _pingTimer?.cancel();

    final timeout = config.pingTimeout;
    if (timeout == null) return;

    _pingTimer = Timer(timeout, () {
      debugLog(
        'WebSocketConnectionHandler: no data received within '
        '${timeout.inSeconds}s — reconnecting',
      );
      _channelSubscription?.cancel();
      _channelSubscription = null;
      _scheduleReconnect();
    });
  }

  // ---------------------------------------------------------------------------
  // Internal – cleanup helpers
  // ---------------------------------------------------------------------------

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  Future<void> _teardown() async {
    _cancelTimers();
    await _channelSubscription?.cancel();
    _channelSubscription = null;

    try {
      await _channel?.sink.close(status.normalClosure);
    } catch (_) {
      // Ignore errors on an already-closed channel.
    }
    _channel = null;
  }

  void _setState(WebSocketConnectionState newState) {
    if (_state == newState) return;
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }
}
