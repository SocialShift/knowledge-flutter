import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'https://knowledge-backend-rqya.onrender.com';

  // Auth endpoints
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get signupEndpoint => '$baseUrl/auth/register';
  static String get forgotPasswordEndpoint => '$baseUrl/auth/forgot-password';

  // Add headers configuration
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
