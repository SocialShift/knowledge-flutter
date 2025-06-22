import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/community.dart';
import 'package:knowledge/core/network/api_service.dart';
import 'package:dio/dio.dart';
import 'dart:io';

part 'community_repository.g.dart';

@riverpod
class CommunityRepository extends _$CommunityRepository {
  @override
  Future<void> build() async {
    // Initialize repository
  }

  // Demo categories for history learning communities
  List<CommunityCategory> getCategories() {
    return [
      const CommunityCategory(
        id: '1',
        name: 'Indigenous Histories',
        icon: '🏛️',
        color: '#8B4513',
      ),
      const CommunityCategory(
        id: '2',
        name: 'African Diaspora',
        icon: '🌍',
        color: '#4B0082',
      ),
      const CommunityCategory(
        id: '3',
        name: 'LGBTQ+ Movements',
        icon: '🏳️‍🌈',
        color: '#FFD700',
      ),
      const CommunityCategory(
        id: '4',
        name: 'Women\'s History',
        icon: '👩',
        color: '#DC143C',
      ),
      const CommunityCategory(
        id: '5',
        name: 'Civil Rights',
        icon: '✊',
        color: '#556B2F',
      ),
      const CommunityCategory(
        id: '6',
        name: 'Lesser-Known Figures',
        icon: '📚',
        color: '#2E8B57',
      ),
    ];
  }

  // Fetch communities from API
  Future<List<Community>> getCommunities() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/community');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Community.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching communities: $e');
      // Return demo data as fallback
      return _getDemoCommunities();
    }
  }

  // Fetch community details by ID from API
  Future<Community> getCommunityDetails(int communityId) async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/community/$communityId');

      if (response.data is Map<String, dynamic>) {
        return Community.fromApiResponse(response.data as Map<String, dynamic>);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      print('Error fetching community details: $e');
      // Return demo data as fallback
      return _getDemoCommunityDetails(communityId);
    }
  }

  // Create a new community
  Future<Community> createCommunity({
    required String name,
    String? description,
    String? topics,
    File? bannerFile,
    File? iconFile,
  }) async {
    try {
      final apiService = ApiService();

      print('Creating community with:');
      print('  - Name: $name');
      print('  - Description: $description');
      print('  - Topics: $topics');
      print('  - Banner file: ${bannerFile?.path}');
      print('  - Icon file: ${iconFile?.path}');

      // Create FormData for multipart request
      final formData = FormData();

      // Add required name field
      formData.fields.add(MapEntry('name', name));

      // Add optional fields
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('description', description));
      }

      if (topics != null && topics.isNotEmpty) {
        formData.fields.add(MapEntry('topics', topics));
      }

      // Add files if provided
      if (bannerFile != null) {
        formData.files.add(MapEntry(
          'banner_file',
          await MultipartFile.fromFile(bannerFile.path),
        ));
      }

      if (iconFile != null) {
        formData.files.add(MapEntry(
          'icon_file',
          await MultipartFile.fromFile(iconFile.path),
        ));
      }

      print(
          'FormData fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}');
      print('FormData files: ${formData.files.map((e) => e.key).join(', ')}');

      final response =
          await apiService.postFormData('/community/', formData: formData);

      // Handle different response types
      if (response.data is Map<String, dynamic>) {
        return Community.fromJson(response.data as Map<String, dynamic>);
      } else if (response.data is String) {
        // If API returns a string (like success message), create a basic community object
        return Community(
          id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
          name: name,
          description: description,
          topics: topics,
        );
      } else {
        // Fallback: create basic community object
        return Community(
          id: DateTime.now().millisecondsSinceEpoch,
          name: name,
          description: description,
          topics: topics,
        );
      }
    } catch (e) {
      print('Error creating community: $e');
      print('Error details: ${e.toString()}');
      if (e.toString().contains('307')) {
        print(
            '307 Redirect detected - this usually means the API endpoint expects a different format');
      }
      rethrow;
    }
  }

  // Demo communities fallback
  List<Community> _getDemoCommunities() {
    return [
      const Community(
        id: 1,
        name: 'Indigenous Voices',
        description:
            'Exploring the rich histories and cultures of Indigenous peoples worldwide.',
        iconUrl:
            'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=400',
        bannerUrl:
            'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=800',
        memberCount: 1247,
        topics: 'Indigenous History, Culture, Oral Traditions',
        createdAt: '2024-01-15T10:30:00Z',
        isMember: false,
      ),
      const Community(
        id: 2,
        name: 'African Heritage',
        description:
            'Celebrating African diaspora stories and contributions to world history.',
        iconUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        bannerUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        memberCount: 892,
        topics: 'African History, Diaspora, Cultural Heritage',
        createdAt: '2024-01-20T14:45:00Z',
        isMember: true,
      ),
      const Community(
        id: 3,
        name: 'Pride Through Time',
        description:
            'LGBTQ+ milestones and movements that shaped our modern world.',
        iconUrl:
            'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
        bannerUrl:
            'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
        memberCount: 756,
        topics: 'LGBTQ+ Rights, Pride History, Social Movements',
        createdAt: '2024-02-01T09:15:00Z',
        isMember: false,
      ),
      const Community(
        id: 4,
        name: 'Women Who Changed History',
        description:
            'Uncovering the stories of remarkable women throughout the ages.',
        iconUrl:
            'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=400',
        bannerUrl:
            'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=800',
        memberCount: 634,
        topics: 'Women\'s History, Feminism, Notable Figures',
        createdAt: '2024-02-10T16:20:00Z',
        isMember: true,
      ),
      const Community(
        id: 5,
        name: 'Civil Rights Chronicles',
        description:
            'The ongoing fight for equality and justice across cultures and time.',
        iconUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        bannerUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
        memberCount: 2156,
        topics: 'Civil Rights, Social Justice, Equality Movements',
        createdAt: '2024-01-25T11:10:00Z',
        isMember: false,
      ),
      const Community(
        id: 6,
        name: 'Hidden Figures',
        description:
            'Bringing lesser-known historical figures into the spotlight they deserve.',
        iconUrl:
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
        bannerUrl:
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800',
        memberCount: 934,
        topics: 'Hidden History, Unsung Heroes, Research',
        createdAt: '2024-02-05T13:30:00Z',
        isMember: false,
      ),
    ];
  }

  // Demo community details fallback
  Community _getDemoCommunityDetails(int communityId) {
    final communities = _getDemoCommunities();
    return communities.firstWhere(
      (community) => community.id == communityId,
      orElse: () => communities.first,
    );
  }

  Future<List<Community>> getCommunitiesByCategory(String categoryId) async {
    // For now, return all communities since API doesn't support category filtering yet
    final communities = await getCommunities();
    return communities;
  }

  Future<void> joinCommunity(int communityId) async {
    try {
      final apiService = ApiService();

      // POST /community/{community_id}/join with community_id in payload
      await apiService.post(
        '/community/$communityId/join',
        data: {
          'community_id': communityId,
        },
      );
    } catch (e) {
      print('Error joining community: $e');
      rethrow;
    }
  }

  Future<void> leaveCommunity(int communityId) async {
    try {
      final apiService = ApiService();

      // DELETE /community/{community_id}/leave with community_id in payload
      await apiService.delete(
        '/community/$communityId/leave',
        data: {
          'community_id': communityId,
        },
      );
    } catch (e) {
      print('Error leaving community: $e');
      rethrow;
    }
  }

  // Create a new post in a community
  Future<Post> createPost({
    required String title,
    String? body,
    required int communityId,
    File? imageFile,
  }) async {
    try {
      final apiService = ApiService();

      // Create FormData for multipart request
      final formData = FormData();

      // Add required fields
      formData.fields.add(MapEntry('title', title));
      formData.fields.add(MapEntry('community_id', communityId.toString()));

      // Add optional fields
      if (body != null && body.isNotEmpty) {
        formData.fields.add(MapEntry('body', body));
      }

      // Add image file if provided
      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image_file',
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      final response =
          await apiService.postFormData('/community/post/', formData: formData);

      if (response.data is Map<String, dynamic>) {
        return Post.fromJson(response.data as Map<String, dynamic>);
      } else {
        // Fallback: create basic post object
        return Post(
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          body: body,
          communityId: communityId,
        );
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  // Fetch posts for a community
  Future<List<Post>> getCommunityPosts(int communityId) async {
    try {
      final apiService = ApiService();
      final response =
          await apiService.get('/community/post/?community_id=$communityId');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Post.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching community posts: $e');
      // Return demo data as fallback
      return _getDemoPosts(communityId);
    }
  }

  // Vote on a post
  Future<void> votePost({
    required int postId,
    required int voteType, // 1 for upvote, -1 for downvote, 0 for remove vote
  }) async {
    try {
      final apiService = ApiService();
      await apiService.post(
        '/community/post/vote',
        data: {
          'vote_type': voteType,
          'post_id': postId,
        },
      );
    } catch (e) {
      print('Error voting on post: $e');
      rethrow;
    }
  }

  // Create a comment on a post
  Future<void> createComment({
    required String comment,
    required int postId,
  }) async {
    try {
      final apiService = ApiService();
      await apiService.post(
        '/community/comment/',
        data: {
          'comment': comment,
          'post_id': postId,
        },
      );
    } catch (e) {
      print('Error creating comment: $e');
      rethrow;
    }
  }

  // Get comments for a post
  Future<List<Map<String, dynamic>>> getPostComments(int postId) async {
    try {
      final apiService = ApiService();
      final response = await apiService.get('/community/post/$postId/comments');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => json as Map<String, dynamic>)
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      // Return demo comments as fallback
      return _getDemoComments(postId);
    }
  }

  // Demo comments fallback
  List<Map<String, dynamic>> _getDemoComments(int postId) {
    return [
      {
        'id': 1,
        'comment': 'Great post! Very informative.',
        'post_id': postId,
        'commented_by': 456,
        'upvote': 5,
        'downvote': 0,
        'created_at': '2024-01-20T11:30:00Z',
      },
      {
        'id': 2,
        'comment': 'Thanks for sharing this!',
        'post_id': postId,
        'commented_by': 789,
        'upvote': 3,
        'downvote': 0,
        'created_at': '2024-01-20T12:15:00Z',
      },
      {
        'id': 3,
        'comment': 'I have a different perspective on this topic...',
        'post_id': postId,
        'commented_by': 123,
        'upvote': 2,
        'downvote': 1,
        'created_at': '2024-01-20T13:45:00Z',
      },
    ];
  }

  // Demo posts fallback
  List<Post> _getDemoPosts(int communityId) {
    return [
      Post(
        id: 1,
        title: 'Welcome to our community!',
        body:
            'Hello everyone! Welcome to this amazing community where we explore and discuss fascinating historical topics together.',
        communityId: communityId,
        upvote: 15,
        downvote: 2,
        createdAt: '2024-01-20T10:30:00Z',
        createdBy: 123,
        imageUrl:
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=600',
      ),
      Post(
        id: 2,
        title: 'Interesting historical facts',
        body:
            'Did you know that the Library of Alexandria was not destroyed in a single event, but gradually declined over several centuries?',
        communityId: communityId,
        upvote: 28,
        downvote: 1,
        createdAt: '2024-01-19T14:45:00Z',
        createdBy: 456,
      ),
      Post(
        id: 3,
        title: 'Discussion: Women in Ancient Rome',
        body:
            'Let\'s discuss the roles and rights of women in ancient Roman society. What aspects would you like to explore?',
        communityId: communityId,
        upvote: 12,
        downvote: 0,
        createdAt: '2024-01-18T09:15:00Z',
        createdBy: 789,
      ),
    ];
  }
}
