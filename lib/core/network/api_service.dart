import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:knowledge/core/config/app_config.dart';

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() : _dio = Dio() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.validateStatus = (status) => status! < 500;

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
            print('Storing cookie: ${cookies.first}'); // Debug log
            await _storage.write(key: 'session_cookie', value: cookies.first);
          }
          return handler.next(response);
        },
        onRequest: (options, handler) async {
          // Attach session cookie to requests
          final cookie = await _storage.read(key: 'session_cookie');
          if (cookie != null) {
            print('Attaching cookie to request: $cookie'); // Debug log
            options.headers['Cookie'] = cookie;
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          print('Request error: ${e.message}');
          print('Request path: ${e.requestOptions.path}');
          print('Request headers: ${e.requestOptions.headers}');
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
              print('Retrying request due to timeout...');
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

    if (dotenv.env['ENVIRONMENT'] == 'development') {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
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
      print('Making POST request to: ${_dio.options.baseUrl}$path');
      print('Request data: $data');

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

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

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
      print('DioException occurred: ${e.message}');
      print('DioException type: ${e.type}');
      print('DioException response: ${e.response?.data}');
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
      print('DioException in patch: ${e.message}');
      print('DioException type: ${e.type}');
      print('DioException response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final message = e.response?.data['detail'] ??
          e.response?.data['message'] ??
          e.response?.data['error'];
      if (message != null) return message.toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection and try again.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}). Please try again later.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
