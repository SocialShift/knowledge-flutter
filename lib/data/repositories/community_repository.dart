import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:knowledge/data/models/community.dart';

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
        name: 'Ancient History',
        icon: '🏛️',
        color: '#8B4513',
      ),
      const CommunityCategory(
        id: '2',
        name: 'Medieval Times',
        icon: '⚔️',
        color: '#4B0082',
      ),
      const CommunityCategory(
        id: '3',
        name: 'Renaissance',
        icon: '🎨',
        color: '#FFD700',
      ),
      const CommunityCategory(
        id: '4',
        name: 'Modern Era',
        icon: '🚂',
        color: '#DC143C',
      ),
      const CommunityCategory(
        id: '5',
        name: 'World Wars',
        icon: '✈️',
        color: '#556B2F',
      ),
      const CommunityCategory(
        id: '6',
        name: 'Philosophy',
        icon: '🤔',
        color: '#2E8B57',
      ),
    ];
  }

  // Demo communities with gamification elements
  List<Community> getCommunities() {
    return [
      const Community(
        id: '1',
        name: 'Roman Empire Explorers',
        description: 'Dive deep into the glory and complexity of Ancient Rome',
        imageUrl:
            'https://images.unsplash.com/photo-1539650116574-75c0c6d73c6c?w=400',
        categoryId: '1',
        memberCount: 1247,
        xpReward: 150,
        isJoined: false,
        tags: ['Caesar', 'Gladiators', 'Architecture'],
        location: 'Global Community',
      ),
      const Community(
        id: '2',
        name: 'Greek Mythology Masters',
        description: 'Uncover the epic tales of gods, heroes, and monsters',
        imageUrl:
            'https://images.unsplash.com/photo-1555991496-c0d7c68ea4c5?w=400',
        categoryId: '1',
        memberCount: 892,
        xpReward: 120,
        isJoined: true,
        tags: ['Zeus', 'Olympus', 'Heroes'],
        location: 'Ancient Greece Hub',
      ),
      const Community(
        id: '3',
        name: 'Knights & Castles Guild',
        description: 'Experience the age of chivalry and feudalism',
        imageUrl:
            'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
        categoryId: '2',
        memberCount: 756,
        xpReward: 180,
        isJoined: false,
        tags: ['Crusades', 'Chivalry', 'Castles'],
        location: 'Medieval Europe',
      ),
      const Community(
        id: '4',
        name: 'Renaissance Artists Circle',
        description: 'Celebrate the rebirth of art, science, and culture',
        imageUrl:
            'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400',
        categoryId: '3',
        memberCount: 634,
        xpReward: 200,
        isJoined: true,
        tags: ['DaVinci', 'Michelangelo', 'Innovation'],
        location: 'Florence & Beyond',
      ),
      const Community(
        id: '5',
        name: 'Industrial Revolution Society',
        description: 'Witness the transformation that changed the world',
        imageUrl:
            'https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=400',
        categoryId: '4',
        memberCount: 543,
        xpReward: 160,
        isJoined: false,
        tags: ['Steam Engine', 'Factory', 'Progress'],
        location: 'Industrial Britain',
      ),
      const Community(
        id: '6',
        name: 'WWII History Buffs',
        description: 'Study the most significant conflict in human history',
        imageUrl:
            'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=400',
        categoryId: '5',
        memberCount: 2156,
        xpReward: 250,
        isJoined: false,
        tags: ['Strategy', 'Heroes', 'Turning Points'],
        location: 'Global Battlefield',
      ),
      const Community(
        id: '7',
        name: 'Philosophical Thinkers',
        description: 'Explore the great minds that shaped human thought',
        imageUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        categoryId: '6',
        memberCount: 418,
        xpReward: 175,
        isJoined: true,
        tags: ['Socrates', 'Logic', 'Ethics'],
        location: 'Academy of Minds',
      ),
    ];
  }

  Future<List<Community>> getCommunitiesByCategory(String categoryId) async {
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate API call
    return getCommunities()
        .where((community) => community.categoryId == categoryId)
        .toList();
  }

  Future<void> joinCommunity(String communityId) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate API call
    // In real implementation, this would make an API call
  }

  Future<void> leaveCommunity(String communityId) async {
    await Future.delayed(
        const Duration(milliseconds: 800)); // Simulate API call
    // In real implementation, this would make an API call
  }
}
