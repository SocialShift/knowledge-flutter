import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  late final Dio _dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
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
