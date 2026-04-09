import 'package:flutter/foundation.dart';

enum ApiLogType { request, response, error }

class ApiLogEntry {
  ApiLogEntry({
    required this.type,
    required this.timestamp,
    required this.method,
    required this.url,
    this.queryParameters,
    this.statusCode,
    this.message,
    this.requestHeaders,
    this.requestBody,
    this.responseHeaders,
    this.responseBody,
  });

  final ApiLogType type;
  final DateTime timestamp;
  final String method;
  final String url;
  /// Serialized query string or JSON; null/empty if none.
  final String? queryParameters;
  final int? statusCode;
  final String? message;
  final String? requestHeaders;
  final String? requestBody;
  final String? responseHeaders;
  final String? responseBody;
}

class ApiLogStore {
  ApiLogStore._();

  static final ApiLogStore instance = ApiLogStore._();

  final ValueNotifier<List<ApiLogEntry>> logs =
      ValueNotifier<List<ApiLogEntry>>(<ApiLogEntry>[]);

  static const int _maxEntries = 300;

  void add(ApiLogEntry entry) {
    final next = <ApiLogEntry>[entry, ...logs.value];
    if (next.length > _maxEntries) {
      next.removeRange(_maxEntries, next.length);
    }
    logs.value = next;
  }

  void clear() {
    logs.value = <ApiLogEntry>[];
  }
}
