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
      // Check if response has status field (API format)
      if (responseData.containsKey('status')) {
        final status = responseData['status'];
        // Status 1 means success
        if (status == 1) {
          return responseData;
        } else {
          // Status != 1 means error
          final errorMessage = responseData['message'] ?? 'Request failed';
          throw ServerFailure(errorMessage);
        }
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

      // Try to extract error message from response
      String errorMessage = 'Request failed';
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['data']?['message'] ??
            'Request failed';
      } else if (responseData is String) {
        errorMessage = responseData;
      }

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
}
