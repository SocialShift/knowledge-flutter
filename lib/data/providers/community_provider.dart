import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/community.dart';
import 'package:knowledge/data/repositories/community_repository.dart';
import 'dart:io';

part 'community_provider.g.dart';

// Provider for community categories
@riverpod
Future<List<CommunityCategory>> communityCategories(
  CommunityCategoriesRef ref,
) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return repository.getCategories();
}

// Provider for all communities (now async)
@riverpod
Future<List<Community>> allCommunities(AllCommunitiesRef ref) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return repository.getCommunities();
}

// Provider for communities filtered by category
@riverpod
Future<List<Community>> communitiesByCategory(
  CommunitiesByCategoryRef ref,
  String categoryId,
) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return repository.getCommunitiesByCategory(categoryId);
}

// Provider for joined communities
@riverpod
Future<List<Community>> joinedCommunities(ref) async {
  final allCommunities = await ref.watch(allCommunitiesProvider.future);
  return allCommunities.where((community) => community.isMember).toList();
}

// Provider for community actions
@riverpod
class CommunityActions extends _$CommunityActions {
  @override
  void build() {
    // Initialize
  }

  Future<void> joinCommunity(int communityId) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    await repository.joinCommunity(communityId);

    // Invalidate providers to refresh data
    ref.invalidate(allCommunitiesProvider);
    ref.invalidate(joinedCommunitiesProvider);
    ref.invalidate(communityDetailsProvider(communityId));
  }

  Future<void> leaveCommunity(int communityId) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    await repository.leaveCommunity(communityId);

    // Invalidate providers to refresh data
    ref.invalidate(allCommunitiesProvider);
    ref.invalidate(joinedCommunitiesProvider);
    ref.invalidate(communityDetailsProvider(communityId));
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

  Future<void> deleteCommunity(int communityId) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    await repository.deleteCommunity(communityId);

    // Invalidate providers to refresh data
    ref.invalidate(allCommunitiesProvider);
    ref.invalidate(joinedCommunitiesProvider);
    ref.invalidate(communityDetailsProvider(communityId));
  }
}

@riverpod
Future<Community> communityDetails(
  CommunityDetailsRef ref,
  int communityId,
) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return repository.getCommunityDetails(communityId);
}

@riverpod
Future<void> joinCommunityAction(
  JoinCommunityActionRef ref,
  int communityId,
) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  await repository.joinCommunity(communityId);

  // Invalidate related providers to refresh data
  ref.invalidate(allCommunitiesProvider);
  ref.invalidate(communityDetailsProvider(communityId));
}

@riverpod
Future<void> leaveCommunityAction(
  LeaveCommunityActionRef ref,
  int communityId,
) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  await repository.leaveCommunity(communityId);

  // Invalidate related providers to refresh data
  ref.invalidate(allCommunitiesProvider);
  ref.invalidate(communityDetailsProvider(communityId));
}

@riverpod
Future<List<Post>> communityPosts(
  CommunityPostsRef ref,
  int communityId,
) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return repository.getCommunityPosts(communityId);
}

@riverpod
class PostActions extends _$PostActions {
  @override
  void build() {
    // Initialize
  }

  Future<Post> createPost({
    required String title,
    String? body,
    required int communityId,
    File? imageFile,
  }) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    final post = await repository.createPost(
      title: title,
      body: body,
      communityId: communityId,
      imageFile: imageFile,
    );

    // Invalidate posts provider to refresh data
    ref.invalidate(communityPostsProvider(communityId));

    return post;
  }

  Future<void> votePost({
    required int postId,
    required int voteType,
    required int communityId,
  }) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    await repository.votePost(postId: postId, voteType: voteType);

    // Invalidate posts provider to refresh data
    ref.invalidate(communityPostsProvider(communityId));
  }

  Future<void> deletePost({
    required int postId,
    required int communityId,
  }) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    await repository.deletePost(postId);

    // Invalidate posts provider to refresh data
    ref.invalidate(communityPostsProvider(communityId));
  }
}

// Provider for post comments
@riverpod
Future<List<Map<String, dynamic>>> postComments(
  PostCommentsRef ref,
  int postId,
) async {
  final repository = ref.watch(communityRepositoryProvider.notifier);
  return await repository.getPostComments(postId);
}

@riverpod
class CommentActions extends _$CommentActions {
  @override
  void build() {
    // Initialize
  }

  Future<void> createComment({
    required String comment,
    required int postId,
  }) async {
    final repository = ref.read(communityRepositoryProvider.notifier);
    await repository.createComment(comment: comment, postId: postId);

    // Invalidate comments provider to refresh data
    ref.invalidate(postCommentsProvider(postId));
  }
}
