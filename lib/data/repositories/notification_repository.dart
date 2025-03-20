import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/otd_notification.dart';

part 'notification_repository.g.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository() : _apiService = ApiService();

  Future<List<OtdNotification>> getOnThisDayNotifications() async {
    try {
      final response = await _apiService.get('/list/otd');

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode != 200) {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to fetch notifications';
        throw errorMessage.toString();
      }

      // Parse the response data
      final List<dynamic> notificationsData = response.data ?? [];

      // Convert the API response to our OtdNotification model
      return notificationsData
          .map((json) => OtdNotification.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching on this day notifications: $e');
      rethrow;
    }
  }
}

@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepository();
}

@riverpod
Future<List<OtdNotification>> onThisDayNotifications(
    OnThisDayNotificationsRef ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getOnThisDayNotifications();
}
