import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_user.freezed.dart';
part 'social_user.g.dart';

@freezed
class SocialUser with _$SocialUser {
  const factory SocialUser({
    required int userId,
    required String username,
    required int profileId,
    required String nickname,
    required String avatarUrl,
    required bool isFollowing,
  }) = _SocialUser;

  factory SocialUser.fromJson(Map<String, dynamic> json) =>
      _$SocialUserFromJson(json);
}
