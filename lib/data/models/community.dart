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
    @Default(0) int memberCount, // For local use, not from API
    @Default(false) bool isJoined, // For local use, not from API
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);
}
