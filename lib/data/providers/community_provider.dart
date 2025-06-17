import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/community.dart';
import 'package:knowledge/data/repositories/community_repository.dart';
import 'dart:io';

part 'community_provider.g.dart';

// Provider for community categories
@riverpod
List<CommunityCategory> communityCategories(ref) {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return repository.getCategories();
}

// Provider for all communities (now async)
@riverpod
Future<List<Community>> allCommunities(ref) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return await repository.getCommunities();
}

// Provider for communities filtered by category
@riverpod
Future<List<Community>> communitiesByCategory(ref, String categoryId) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return await repository.getCommunitiesByCategory(categoryId);
}

// Provider for joined communities
@riverpod
Future<List<Community>> joinedCommunities(ref) async {
  final allCommunities = await ref.watch(allCommunitiesProvider);
  return allCommunities.where((community) => community.isJoined).toList();
}

// Provider for community actions
@riverpod
class CommunityActions extends _$CommunityActions {
  @override
  void build() {
    // Initialize
  }

  Future<void> joinCommunity(String communityId) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    await repository.joinCommunity(communityId);

    // Invalidate providers to refresh data
    ref.invalidate(allCommunitiesProvider);
    ref.invalidate(joinedCommunitiesProvider);
  }

  Future<void> leaveCommunity(String communityId) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    await repository.leaveCommunity(communityId);

    // Invalidate providers to refresh data
    ref.invalidate(allCommunitiesProvider);
    ref.invalidate(joinedCommunitiesProvider);
  }

  Future<Community> createCommunity({
    required String name,
    String? description,
    String? topics,
    File? bannerFile,
    File? iconFile,
  }) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    final community = await repository.createCommunity(
      name: name,
      description: description,
      topics: topics,
      bannerFile: bannerFile,
      iconFile: iconFile,
    );

    // Invalidate providers to refresh data
    ref.invalidate(allCommunitiesProvider);

    return community;
  }
}
