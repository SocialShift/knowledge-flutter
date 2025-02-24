import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:knowledge/data/models/profile.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository() : _apiService = ApiService();

  Future<void> updateProfile({
    required String nickname,
    required String pronouns,
    required String email,
    String? location,
    String? languagePreference,
    Map<String, dynamic>? personalizationQuestions,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'nickname': nickname,
        'pronouns': pronouns,
        'location': location,
        'languagePreference': languagePreference,
      };

      if (personalizationQuestions != null) {
        data['personalization_questions'] = personalizationQuestions;
      }

      final response = await _apiService.patch(
        '/auth/profile/update',
        data: data,
      );

      if (response.statusCode == 401) {
        throw 'Please log in again to continue';
      }

      if (response.statusCode != 200) {
        final errorMessage = response.data['detail'] ??
            response.data['message'] ??
            'Failed to update profile';
        throw errorMessage.toString();
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<Profile> getUserProfile() async {
    try {
      final response = await _apiService.get('/auth/user/me');

      if (response.statusCode == 200) {
        return Profile.fromJson(response.data);
      } else {
        throw response.data['detail'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      throw 'Failed to fetch profile: $e';
    }
  }
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository();
}
