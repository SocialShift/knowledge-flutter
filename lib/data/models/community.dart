import 'package:freezed_annotation/freezed_annotation.dart';

part 'community.freezed.dart';
part 'community.g.dart';

@freezed
class CommunityCategory with _$CommunityCategory {
  const factory CommunityCategory({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) = _CommunityCategory;

  factory CommunityCategory.fromJson(Map<String, dynamic> json) =>
      _$CommunityCategoryFromJson(json);
}

@freezed
class Post with _$Post {
  const factory Post({
    required int id,
    required String title,
    String? body,
    @JsonKey(name: 'community_id') required int communityId,
    @Default(0) int upvote,
    @Default(0) int downvote,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'created_by') int? createdBy,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

@freezed
class Community with _$Community {
  const factory Community({
    required int id,
    required String name,
    String? description,
    String? topics,
    @JsonKey(name: 'banner_url') String? bannerUrl,
    @JsonKey(name: 'icon_url') String? iconUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'created_by') int? createdBy,
    @JsonKey(name: 'member_count') @Default(0) int memberCount,
    @JsonKey(name: 'is_member') @Default(false) bool isMember,
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);

  // Factory constructor to create a Community from the API response with proper field mapping
  static Community fromApiResponse(Map<String, dynamic> json) {
    return Community(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      topics: json['topics'] is List
          ? (json['topics'] as List).join(', ')
          : json['topics']?.toString(),
      bannerUrl: json['banner_url'],
      iconUrl: json['icon_url'],
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      memberCount: json['member_count'] ?? 0,
      isMember: json['is_member'] ?? false,
    );
  }
}
