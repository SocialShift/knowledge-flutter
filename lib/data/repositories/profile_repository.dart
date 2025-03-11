import 'dart:convert';
import 'package:dio/dio.dart';
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
      // Create FormData instance
      final formData = FormData();

      // Add basic fields
      formData.fields.add(MapEntry('nickname', nickname));
      formData.fields.add(MapEntry('pronouns', pronouns));
      formData.fields.add(MapEntry('email', email));

      // Add optional fields if they exist
      if (location != null) {
        formData.fields.add(MapEntry('location', location));
      }

      if (languagePreference != null) {
        formData.fields.add(MapEntry('languagePreference', languagePreference));
      }

      // Handle personalization questions
      if (personalizationQuestions != null) {
        // Convert the map to a proper JSON string
        final questionsJson = jsonEncode(personalizationQuestions);
        formData.fields
            .add(MapEntry('personalization_questions', questionsJson));
      }

      final response = await _apiService.patchFormData(
        '/auth/profile/update',
        formData: formData,
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
        // Use the new fromApiResponse method to handle the nested structure
        return Profile.fromApiResponse(response.data);
      } else {
        throw response.data['detail'] ?? 'Failed to fetch profile';
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw 'Failed to fetch profile: $e';
    }
  }

  // Check if the user has completed their profile setup
  Future<bool> hasCompletedProfile() async {
    try {
      final response = await _apiService.get('/auth/user/me');

      if (response.statusCode == 200) {
        final profileData = response.data['profile'] ?? {};

        // Check if nickname and pronouns are set
        final nickname = profileData['nickname'];
        final pronouns = profileData['pronouns'];

        return nickname != null &&
            nickname.toString().isNotEmpty &&
            pronouns != null &&
            pronouns.toString().isNotEmpty;
      }

      return false;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }
}

@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository();
}

// Provider for getting the user profile
@riverpod
Future<Profile> userProfile(UserProfileRef ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile();
}
