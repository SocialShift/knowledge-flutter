import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:knowledge/core/config/app_config.dart';
import 'package:knowledge/core/utils/debug_utils.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() : _dio = Dio() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.validateStatus = (status) => status! < 500;

    // Optimize timeout settings for better iOS performance
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.sendTimeout = const Duration(seconds: 15);

    // Add default headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor for cookies
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) async {
          // Check both lowercase and uppercase header names
          final cookies =
              response.headers['Set-Cookie'] ?? response.headers['set-cookie'];

          if (cookies != null && cookies.isNotEmpty) {
            DebugUtils.debugLog('Storing cookie: ${cookies.first}');
            await _storage.write(key: 'session_cookie', value: cookies.first);
          }
          return handler.next(response);
        },
        onRequest: (options, handler) async {
          // Attach session cookie to requests
          final cookie = await _storage.read(key: 'session_cookie');
          if (cookie != null) {
            DebugUtils.debugLog('Attaching cookie to request: $cookie');
            options.headers['Cookie'] = cookie;
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          DebugUtils.debugError('Request error: ${e.message}');
          DebugUtils.debugError('Request path: ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            try {
              DebugUtils.debugInfo('Retrying request due to timeout...');
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              return handler.next(e as DioException);
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Only add logger in development environment
    if (dotenv.env['ENVIRONMENT'] == 'development' && kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      DebugUtils.debugLog(
          'Making POST request to: ${_dio.options.baseUrl}$path');

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      DebugUtils.debugLog('Response status: ${response.statusCode}');

      if (response.statusCode == 401) {
        throw 'Unauthorized access';
      }

      if (response.statusCode! >= 400) {
        throw _handleDioError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      return response;
    } on DioException catch (e) {
      DebugUtils.debugError('DioException occurred: ${e.message}');
      DebugUtils.debugError('DioException type: ${e.type}');
      throw _handleDioError(e);
    }
  }

  Future<Response> postFormData(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      DebugUtils.debugLog(
          'Making FormData POST request to: ${_dio.options.baseUrl}$path');
      DebugUtils.debugLog('FormData fields: ${formData.fields}');

      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          // Don't set Content-Type manually for FormData - let Dio handle it with boundary
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      DebugUtils.debugLog('Response status: ${response.statusCode}');
      DebugUtils.debugLog('Response data: ${response.data}');

      if (response.statusCode == 307) {
        DebugUtils.debugError('307 Temporary Redirect received');
        DebugUtils.debugError(
            'This usually means the API endpoint URL is incorrect or needs modification');
        DebugUtils.debugError(
            'Location header: ${response.headers['location']}');
        throw 'API endpoint redirected (307). Please check the endpoint URL.';
      }

      if (response.statusCode == 401) {
        throw 'Unauthorized access';
      }

      if (response.statusCode! >= 400) {
        throw _handleDioError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      return response;
    } on DioException catch (e) {
      DebugUtils.debugError('DioException occurred: ${e.message}');
      DebugUtils.debugError('DioException type: ${e.type}');
      DebugUtils.debugError('DioException response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<Response> patchFormData(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      DebugUtils.debugLog(
          'Making FormData PATCH request to: ${_dio.options.baseUrl}$path');
      DebugUtils.debugLog('FormData fields: ${formData.fields}');

      final response = await _dio.patch(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(
          // Don't set Content-Type manually for FormData - let Dio handle it with boundary
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      DebugUtils.debugLog('Response status: ${response.statusCode}');
      DebugUtils.debugLog('Response data: ${response.data}');

      if (response.statusCode == 401) {
        throw 'Unauthorized access';
      }

      if (response.statusCode! >= 400) {
        throw _handleDioError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      return response;
    } on DioException catch (e) {
      DebugUtils.debugError('DioException occurred: ${e.message}');
      DebugUtils.debugError('DioException type: ${e.type}');
      DebugUtils.debugError('DioException response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 401) {
        throw 'Unauthorized access';
      }

      if (response.statusCode! >= 400) {
        throw _handleDioError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      return response;
    } on DioException catch (e) {
      DebugUtils.debugError('DioException in patch: ${e.message}');
      DebugUtils.debugError('DioException type: ${e.type}');
      DebugUtils.debugError('DioException response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      DebugUtils.debugLog(
          'Making DELETE request to: ${_dio.options.baseUrl}$path');
      DebugUtils.debugLog('Request data: $data');

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      DebugUtils.debugLog('Response status: ${response.statusCode}');
      DebugUtils.debugLog('Response data: ${response.data}');

      if (response.statusCode == 401) {
        throw 'Unauthorized access';
      }

      if (response.statusCode! >= 400) {
        throw _handleDioError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      return response;
    } on DioException catch (e) {
      DebugUtils.debugError('DioException in delete: ${e.message}');
      DebugUtils.debugError('DioException type: ${e.type}');
      DebugUtils.debugError('DioException response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    String errorMessage = 'An error occurred';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (e.response != null) {
          final statusCode = e.response!.statusCode;
          final data = e.response!.data;

          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (statusCode == 401) {
            errorMessage = 'Unauthorized access. Please log in again.';
          } else if (statusCode == 403) {
            errorMessage = 'Access forbidden. You don\'t have permission.';
          } else if (statusCode == 404) {
            errorMessage = 'Resource not found.';
          } else if (statusCode! >= 500) {
            errorMessage = 'Server error. Please try again later.';
          }
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') ?? false) {
          errorMessage = 'No internet connection. Please check your network.';
        }
        break;
      default:
        errorMessage = 'Network error occurred. Please try again.';
    }

    return errorMessage;
  }
}
