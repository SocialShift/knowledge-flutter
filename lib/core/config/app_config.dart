import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) {
      throw AssertionError(
        'API_BASE_URL not found in .env file. Please check .env configuration.',
      );
    }
    return url;
  }

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
