import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/community.dart';
import 'package:knowledge/data/repositories/community_repository.dart';

part 'community_provider.g.dart';

// Provider for community categories
@riverpod
List<CommunityCategory> communityCategories(ref) {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return repository.getCategories();
}

// Provider for all communities
@riverpod
List<Community> allCommunities(ref) {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return repository.getCommunities();
}

// Provider for communities filtered by category
@riverpod
Future<List<Community>> communitiesByCategory(ref, String categoryId) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return await repository.getCommunitiesByCategory(categoryId);
}

// Provider for joined communities
@riverpod
List<Community> joinedCommunities(ref) {
  final allCommunities = ref.watch(allCommunitiesProvider);
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
}
