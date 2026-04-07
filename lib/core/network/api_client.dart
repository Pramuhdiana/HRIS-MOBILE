import 'package:dio/dio.dart';
import '../constants/company_context.dart';
import '../constants/api_config.dart';
import '../constants/api_endpoints.dart';
import 'api_logger.dart';

/// API Client for HTTP requests
/// Handles authentication, company context, and error handling
class ApiClient {
  late final Dio _dio;
  CompanyContext? _currentCompany;
  String? _authToken;

  ApiClient({
    String? baseUrl,
    CompanyContext? companyContext,
    String? authToken,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _currentCompany = companyContext;
    _authToken = authToken;

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Add API Logger Interceptor (first, so it logs everything)
    _dio.interceptors.add(
      ApiLoggerInterceptor(enabled: ApiConfig.enableApiLogging),
    );

    // Add Auth and Company Context Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          // Add company context header for multi-company support
          if (_currentCompany != null) {
            options.headers['X-Company-Id'] = _currentCompany!.companyId;
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          return handler.next(error);
        },
      ),
    );
  }

  /// Update company context
  void updateCompanyContext(CompanyContext company) {
    _currentCompany = company;
  }

  void clearCompanyContext() {
    _currentCompany = null;
  }

  /// Update auth token
  void updateAuthToken(String? token) {
    _authToken = token;
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
}
