import 'dart:convert';

import 'package:dio/dio.dart';
import '../errors/failures.dart';
import 'api_client.dart';

/// API Helper
/// Reusable helper methods for common API operations (GET, POST, PUT, DELETE)
class ApiHelper {
  final ApiClient _apiClient;

  ApiHelper(this._apiClient);

  /// Generic GET request
  ///
  /// [endpoint] - API endpoint path
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns: Response data as `Map<String, dynamic>`
  /// Throws: Failure on error
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _apiClient.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: $e');
    }
  }

  /// Generic POST request
  ///
  /// [endpoint] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns: Response data as `Map<String, dynamic>`
  /// Throws: Failure on error
  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _apiClient.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: $e');
    }
  }

  /// Generic PUT request
  ///
  /// [endpoint] - API endpoint path
  /// [data] - Request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns: Response data as `Map<String, dynamic>`
  /// Throws: Failure on error
  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _apiClient.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: $e');
    }
  }

  /// Generic DELETE request
  ///
  /// [endpoint] - API endpoint path
  /// [data] - Optional request body data
  /// [queryParameters] - Optional query parameters
  /// [options] - Optional request options
  ///
  /// Returns: Response data as `Map<String, dynamic>`
  /// Throws: Failure on error
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _apiClient.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: $e');
    }
  }

  /// Handle API response
  /// Checks status code and response format
  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == null ||
        (response.statusCode! < 200 || response.statusCode! >= 300)) {
      throw ServerFailure(
        'Request failed with status: ${response.statusCode} ${response.statusMessage}',
      );
    }

    final responseData = response.data;

    // If response is already a Map, return it
    if (responseData is Map<String, dynamic>) {
      // Support several backend conventions:
      // - status: 1
      // - status: 200
      // - code: "00"
      final hasStatus = responseData.containsKey('status');
      final hasCode = responseData.containsKey('code');
      if (hasStatus || hasCode) {
        final status = responseData['status'];
        final code = responseData['code']?.toString();
        final isSuccess =
            status == 1 ||
            status == 200 ||
            status == '1' ||
            status == '200' ||
            code == '00';
        if (isSuccess) return responseData;

        final errorMessage =
            responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            'Request failed';
        throw ServerFailure(errorMessage);
      }

      // If no status field, assume success if status code is 2xx
      return responseData;
    }

    // If response is not a Map, wrap it
    return {'data': responseData};
  }

  /// Handle DioException errors
  Failure _handleDioError(DioException e) {
    if (e.response != null) {
      // Server responded with error
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;
      final statusText = e.response!.statusMessage?.trim();
      final requestMethod = e.requestOptions.method;
      final requestUrl = '${e.requestOptions.baseUrl}${e.requestOptions.path}';
      final humanMessage = _extractHumanErrorMessage(responseData);
      final fullBody = _stringifyErrorBody(responseData);
      final errorMessage = _composeDetailedErrorMessage(
        statusCode: statusCode,
        statusText: statusText,
        requestMethod: requestMethod,
        requestUrl: requestUrl,
        humanMessage: humanMessage,
        fullBody: fullBody,
      );

      if (statusCode == 401) {
        return UnauthorizedFailure(errorMessage);
      } else if (statusCode == 403) {
        return PermissionFailure(errorMessage);
      } else if (statusCode == 404) {
        return NotFoundFailure(errorMessage);
      } else if (statusCode != null && statusCode >= 500) {
        return ServerFailure('Server error: $errorMessage');
      } else {
        return ServerFailure(errorMessage);
      }
    } else {
      // Network or other error
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return NetworkFailure(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        return NetworkFailure(
          'No internet connection. Please check your network.',
        );
      } else {
        return NetworkFailure('Network error: ${e.message}');
      }
    }
  }

  String _composeDetailedErrorMessage({
    required int? statusCode,
    required String? statusText,
    required String requestMethod,
    required String requestUrl,
    required String? humanMessage,
    required String fullBody,
  }) {
    final code = statusCode?.toString() ?? 'unknown';
    final status = (statusText != null && statusText.isNotEmpty)
        ? statusText
        : 'Request failed';
    final head = 'HTTP $code $status';
    final msg = (humanMessage != null && humanMessage.isNotEmpty)
        ? humanMessage
        : head;
    // Selalu lampirkan request + body response agar sumber error jelas.
    return '$msg\n$requestMethod $requestUrl\n\n$fullBody';
  }

  String? _extractHumanErrorMessage(dynamic responseData) {
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      final message = _asNonEmptyString(map['message']);
      if (message != null) return message;

      final error = map['error'];
      final errorStr = _asNonEmptyString(error);
      if (errorStr != null) return errorStr;
      if (error is Map) {
        final nested = _asNonEmptyString(error['message']);
        if (nested != null) return nested;
      }

      final data = map['data'];
      if (data is Map) {
        final nested = _asNonEmptyString(data['message']);
        if (nested != null) return nested;
      }
    } else if (responseData is String) {
      final t = responseData.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }

  String? _asNonEmptyString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  String _stringifyErrorBody(dynamic responseData) {
    if (responseData == null) return '{}';
    if (responseData is String) return responseData;
    try {
      if (responseData is Map || responseData is List) {
        return const JsonEncoder.withIndent('  ').convert(responseData);
      }
      return responseData.toString();
    } catch (_) {
      return responseData.toString();
    }
  }
}
