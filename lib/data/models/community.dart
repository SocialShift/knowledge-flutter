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
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required String categoryId,
    required int memberCount,
    required int xpReward,
    required bool isJoined,
    @Default([]) List<String> tags,
    String? location,
    DateTime? createdAt,
  }) = _Community;

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);
}
