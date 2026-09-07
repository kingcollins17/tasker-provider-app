import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Structured parsed error containing a user-friendly title, message, and matching icon.
class ParsedError {
  final String title;
  final String message;
  final IconData icon;

  const ParsedError({
    required this.title,
    required this.message,
    required this.icon,
  });
}

/// Extension on [Object] to convert any caught exception, error, or string into user-friendly text and parsed error objects.
extension ErrorExt on Object {
  /// Converts any exception or error into a structured [ParsedError] with title, friendly message, and icon.
  ParsedError toParsedError() {
    final error = this;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const ParsedError(
            title: 'Server Busy',
            message: 'It will not take a long time till we get the error fixed. We will be live again shortly.',
            icon: Icons.satellite_alt_rounded,
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            return const ParsedError(
              title: 'Your session has expired',
              message: 'Your session has expired and your user has been disconnected. Click OK to return to the login screen.',
              icon: Icons.desktop_windows_rounded,
            );
          }
          if (statusCode != null && statusCode >= 500) {
            return const ParsedError(
              title: 'Server Busy',
              message: 'It will not take a long time till we get the error fixed. Please try again in a few moments.',
              icon: Icons.satellite_alt_rounded,
            );
          }
          final response = error.response;
          if (response != null && response.data is Map) {
            final data = response.data as Map;
            if (data.containsKey('detail') && data['detail'] != null) {
              final detailStr = data['detail'].toString();
              if (!_isRawStackTrace(detailStr)) {
                return ParsedError(
                  title: 'Unable to Complete Request',
                  message: detailStr,
                  icon: Icons.error_outline_rounded,
                );
              }
            }
            if (data.containsKey('message') && data['message'] != null) {
              final msgStr = data['message'].toString();
              if (!_isRawStackTrace(msgStr)) {
                return ParsedError(
                  title: 'Unable to Complete Request',
                  message: msgStr,
                  icon: Icons.error_outline_rounded,
                );
              }
            }
          }
          return const ParsedError(
            title: 'Server Busy',
            message: 'It will not take a long time till we get the error fixed. Please try again shortly.',
            icon: Icons.satellite_alt_rounded,
          );
        case DioExceptionType.connectionError:
          return const ParsedError(
            title: 'No network connection',
            message: 'Mobile data is disabled. Enable mobile data or connect your phone to Wi-Fi to use the application.',
            icon: Icons.cell_tower_rounded,
          );
        case DioExceptionType.cancel:
          return const ParsedError(
            title: 'Request Cancelled',
            message: 'The operation was cancelled before completion.',
            icon: Icons.cancel_outlined,
          );
        default:
          return const ParsedError(
            title: 'No network connection',
            message: 'Mobile data is disabled. Enable mobile data or connect your phone to Wi-Fi to use the application.',
            icon: Icons.cell_tower_rounded,
          );
      }
    }

    final rawString = toString().trim();

    // Check common raw exception strings
    if (rawString.contains('SocketException') ||
        rawString.contains('Failed host lookup') ||
        rawString.contains('Network is unreachable') ||
        rawString.contains('No internet')) {
      return const ParsedError(
        title: 'No network connection',
        message: 'Mobile data is disabled. Enable mobile data or connect your phone to Wi-Fi to use the application.',
        icon: Icons.cell_tower_rounded,
      );
    }

    if (rawString.contains('TimeoutException') || rawString.contains('connectionTimeout')) {
      return const ParsedError(
        title: 'Server Busy',
        message: 'It will not take a long time till we get the error fixed. Please try again shortly.',
        icon: Icons.satellite_alt_rounded,
      );
    }

    if (rawString.contains('401') || rawString.contains('Unauthorized') || rawString.contains('session expired')) {
      return const ParsedError(
        title: 'Your session has expired',
        message: 'Your session has expired and your user has been disconnected. Click OK to return to the login screen.',
        icon: Icons.desktop_windows_rounded,
      );
    }

    if (rawString.contains('500') || rawString.contains('502') || rawString.contains('503') || rawString.contains('Server Error')) {
      return const ParsedError(
        title: 'Server Busy',
        message: 'It will not take a long time till we get the error fixed. Please try again shortly.',
        icon: Icons.satellite_alt_rounded,
      );
    }

    // Clean up generic exceptions like "Exception: Bad credentials" -> "Bad credentials"
    var cleanMsg = rawString;
    if (cleanMsg.startsWith('Exception: ')) {
      cleanMsg = cleanMsg.substring(11);
    } else if (cleanMsg.startsWith('Bad state: ')) {
      cleanMsg = cleanMsg.substring(11);
    }

    if (_isRawStackTrace(cleanMsg)) {
      return const ParsedError(
        title: 'Oops! Something went wrong',
        message: 'An unexpected issue occurred while loading data. Please try again.',
        icon: Icons.warning_amber_rounded,
      );
    }

    return ParsedError(
      title: 'Oops! Something went wrong',
      message: cleanMsg,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Converts any exception or error into a user-friendly string message.
  String toFriendlyString() {
    return toParsedError().message;
  }

  static bool _isRawStackTrace(String text) {
    return text.contains('TypeError') ||
        text.contains('NoSuchMethodError') ||
        text.contains('NullThrownError') ||
        text.contains('Stack trace:') ||
        text.contains('.dart:') ||
        text.contains('Unhandled Exception') ||
        text.contains('closure');
  }
}
