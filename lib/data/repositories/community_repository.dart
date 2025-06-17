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
        memberCount: 1247,
      ),
      const Community(
        id: 2,
        name: 'African Heritage',
        description:
            'Celebrating African diaspora stories and contributions to world history.',
        iconUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        memberCount: 892,
      ),
      const Community(
        id: 3,
        name: 'Pride Through Time',
        description:
            'LGBTQ+ milestones and movements that shaped our modern world.',
        iconUrl:
            'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
        memberCount: 756,
      ),
      const Community(
        id: 4,
        name: 'Women Who Changed History',
        description:
            'Uncovering the stories of remarkable women throughout the ages.',
        iconUrl:
            'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=400',
        memberCount: 634,
      ),
      const Community(
        id: 5,
        name: 'Civil Rights Chronicles',
        description:
            'The ongoing fight for equality and justice across cultures and time.',
        iconUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        memberCount: 2156,
      ),
      const Community(
        id: 6,
        name: 'Hidden Figures',
        description:
            'Bringing lesser-known historical figures into the spotlight they deserve.',
        iconUrl:
            'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400',
        memberCount: 934,
      ),
    ];
  }

  Future<List<Community>> getCommunitiesByCategory(String categoryId) async {
    // For now, return all communities since API doesn't support category filtering yet
    final communities = await getCommunities();
    return communities;
  }

  Future<void> joinCommunity(String communityId) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate API call
    // TODO: Implement join community API call
  }

  Future<void> leaveCommunity(String communityId) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate API call
    // TODO: Implement leave community API call
  }
}
