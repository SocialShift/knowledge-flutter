import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:knowledge/core/config/app_config.dart';

class ApiService {
  late final Dio _dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL']!,
      headers: AppConfig.headers,
      validateStatus: (status) => status! < 500,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    ));

    // Add interceptors for logging, token handling, etc.
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Response> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    int retries = 2,
  }) async {
    try {
      print('Making POST request to: ${_dio.options.baseUrl}$path');
      print('Request data: $data');

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      print('DioException occurred: ${e.message}');
      print('DioException type: ${e.type}');
      print('DioException response: ${e.response?.data}');

      if (retries > 0 &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout)) {
        print('Retrying request... (${retries} attempts left)');
        return post(
          path,
          data: data,
          queryParameters: queryParameters,
          retries: retries - 1,
        );
      }

      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.data != null) {
      final message = e.response?.data['detail'] ?? e.response?.data['message'];
      if (message != null) return message.toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error. Please try again later.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
