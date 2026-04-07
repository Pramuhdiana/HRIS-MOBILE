import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// API Logger Interceptor
/// Logs all API requests and responses for debugging
class ApiLoggerInterceptor extends Interceptor {
  final bool enabled;

  ApiLoggerInterceptor({this.enabled = true});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) {
      handler.next(options);
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('🌐 API REQUEST');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📍 URL: ${options.method} ${options.baseUrl}${options.path}');

    if (options.queryParameters.isNotEmpty) {
      debugPrint('🔍 Query Parameters:');
      options.queryParameters.forEach((key, value) {
        debugPrint('   $key: $value');
      });
    }

    if (options.headers.isNotEmpty) {
      debugPrint('📋 Headers:');
      options.headers.forEach((key, value) {
        // Hide sensitive headers
        if (key.toLowerCase() == 'authorization') {
          debugPrint('   $key: ${value.toString().substring(0, 20)}...');
        } else {
          debugPrint('   $key: $value');
        }
      });
    }

    if (options.data != null) {
      debugPrint('📦 Request Body:');
      if (options.data is FormData) {
        final formData = options.data as FormData;
        debugPrint('   FormData:');
        for (final field in formData.fields) {
          debugPrint('     ${field.key}: ${field.value}');
        }
        if (formData.files.isNotEmpty) {
          for (final file in formData.files) {
            debugPrint('     File: ${file.key} - ${file.value.filename}');
          }
        }
      } else {
        debugPrint('   ${_formatJson(options.data)}');
      }
    }

    debugPrint('═══════════════════════════════════════════════════════════');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) {
      handler.next(response);
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('✅ API RESPONSE');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint(
      '📍 URL: ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    debugPrint(
      '📊 Status Code: ${response.statusCode} ${response.statusMessage}',
    );

    if (response.headers.map.isNotEmpty) {
      debugPrint('📋 Response Headers:');
      response.headers.map.forEach((key, value) {
        debugPrint('   $key: ${value.join(", ")}');
      });
    }

    debugPrint('📦 Response Body:');
    debugPrint('   ${_formatJson(response.data)}');
    debugPrint('═══════════════════════════════════════════════════════════');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) {
      handler.next(err);
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('❌ API ERROR');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint(
      '📍 URL: ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    debugPrint('📊 Status Code: ${err.response?.statusCode ?? 'N/A'}');
    debugPrint('⚠️  Error Type: ${err.type}');
    debugPrint('💬 Error Message: ${err.message}');

    if (err.requestOptions.data != null) {
      debugPrint('📦 Request Body:');
      debugPrint('   ${_formatJson(err.requestOptions.data)}');
    }

    if (err.response != null) {
      debugPrint('📦 Error Response Body:');
      debugPrint('   ${_formatJson(err.response!.data)}');
    }

    debugPrint('📚 Stack Trace:');
    debugPrint('   ${err.stackTrace}');

    debugPrint('═══════════════════════════════════════════════════════════');

    handler.next(err);
  }

  /// Format JSON for better readability
  String _formatJson(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is String) {
        // Try to parse if it's a JSON string
        try {
          final json = data;
          // Return formatted string
          return json;
        } catch (e) {
          return data;
        }
      } else if (data is Map || data is List) {
        // Convert to formatted string
        final encoder = const JsonEncoder.withIndent('   ');
        return encoder.convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return data.toString();
    }
  }
}
