import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.g.dart';
part 'profile.freezed.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String nickname,
    required String email,
    String? pronouns,
    String? avatarUrl,
    String? languagePreference,
    String? location,
    Map<String, dynamic>? personalizationQuestions,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
