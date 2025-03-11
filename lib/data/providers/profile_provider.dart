import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/repositories/profile_repository.dart';
import 'package:knowledge/data/providers/onboarding_provider.dart';
import 'package:knowledge/data/models/profile.dart';
import 'package:knowledge/data/repositories/auth_repository.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> updateProfile({
    required String nickname,
    required String pronouns,
    required String email,
    String? location,
    String? languagePreference,
    Map<String, dynamic>? personalizationQuestions,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            nickname: nickname,
            pronouns: pronouns,
            email: email,
            location: location,
            languagePreference: languagePreference,
            personalizationQuestions: personalizationQuestions,
          );
      state = const AsyncData(null);

      // Refresh the user profile after update
      ref.invalidate(userProfileProvider);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> fetchUserProfile() async {
    state = const AsyncLoading();

    try {
      final profile =
          await ref.read(profileRepositoryProvider).getUserProfile();
      state = AsyncData(profile);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

// Use the provider from the profile repository
@riverpod
Future<Profile> userProfile(UserProfileRef ref) {
  return ref.read(profileRepositoryProvider).getUserProfile();
}
