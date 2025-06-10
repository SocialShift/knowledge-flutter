import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/providers/auth_provider.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(
                context,
                auth.maybeWhen(
                  authenticated: (user, _, __) => user.username ?? 'Explorer',
                  orElse: () => 'Explorer',
                ),
                isDarkMode),

            // Categories Section
            _buildCategoriesSection(context, isDarkMode),

            // Communities Section
            _buildCommunitiesSection(context, isDarkMode),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [AppColors.darkSurface, AppColors.darkCard]
              : [AppColors.navyBlue, AppColors.navyBlue.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with greeting and notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello $userName,',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Join Historical\nCommunities',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                    ),
                  ],
                ),
              ),
              // Notification bell
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats Row
          Row(
            children: [
              _buildStatCard(
                context,
                icon: Icons.groups,
                title: 'Joined',
                value: '3',
                subtitle: 'Communities',
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                icon: Icons.stars,
                title: 'Earned',
                value: '470',
                subtitle: 'XP Points',
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                context,
                icon: Icons.trending_up,
                title: 'Rank',
                value: '#24',
                subtitle: 'Global',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Trending section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.limeGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: AppColors.navyBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trending Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'WWII History Buffs +156 new members today',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.limeGreen,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, bool isDarkMode) {
    // Demo categories for now
    final categories = [
      {'id': '1', 'name': 'Ancient', 'icon': '🏛️', 'color': '#8B4513'},
      {'id': '2', 'name': 'Medieval', 'icon': '⚔️', 'color': '#4B0082'},
      {'id': '3', 'name': 'Renaissance', 'icon': '🎨', 'color': '#FFD700'},
      {'id': '4', 'name': 'Modern', 'icon': '🚂', 'color': '#DC143C'},
      {'id': '5', 'name': 'Wars', 'icon': '✈️', 'color': '#556B2F'},
      {'id': '6', 'name': 'Philosophy', 'icon': '🤔', 'color': '#2E8B57'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Browse Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.navyBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: AnimationLimiter(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategoryId == category['id'];

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryId =
                                  isSelected ? null : category['id'] as String;
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.limeGreen
                                        : (isDarkMode
                                            ? AppColors.darkCard
                                            : Colors.white),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.navyBlue, width: 2)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      category['icon'] as String,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['name'] as String,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: isSelected
                                            ? AppColors.navyBlue
                                            : (isDarkMode
                                                ? Colors.white70
                                                : Colors.black87),
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitiesSection(BuildContext context, bool isDarkMode) {
    // Demo communities for now
    final communities = [
      {
        'id': '1',
        'name': 'Roman Empire Explorers',
        'description': 'Dive deep into the glory of Ancient Rome',
        'imageUrl':
            'https://images.unsplash.com/photo-1539650116574-75c0c6d73c6c?w=400',
        'memberCount': 1247,
        'xpReward': 150,
        'isJoined': false,
        'location': 'Global Community',
      },
      {
        'id': '2',
        'name': 'Greek Mythology Masters',
        'description': 'Uncover epic tales of gods and heroes',
        'imageUrl':
            'https://images.unsplash.com/photo-1555991496-c0d7c68ea4c5?w=400',
        'memberCount': 892,
        'xpReward': 120,
        'isJoined': true,
        'location': 'Ancient Greece Hub',
      },
      {
        'id': '3',
        'name': 'Knights & Castles Guild',
        'description': 'Experience the age of chivalry',
        'imageUrl':
            'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400',
        'memberCount': 756,
        'xpReward': 180,
        'isJoined': false,
        'location': 'Medieval Europe',
      },
      {
        'id': '4',
        'name': 'Renaissance Artists Circle',
        'description': 'Celebrate rebirth of art and culture',
        'imageUrl':
            'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400',
        'memberCount': 634,
        'xpReward': 200,
        'isJoined': true,
        'location': 'Florence & Beyond',
      },
      {
        'id': '5',
        'name': 'WWII History Buffs',
        'description': 'Explore the pivotal moments of World War II',
        'imageUrl':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        'memberCount': 2156,
        'xpReward': 250,
        'isJoined': false,
        'location': 'Global War Studies',
      },
      {
        'id': '6',
        'name': 'Viking Saga Society',
        'description': 'Journey through Norse legends and culture',
        'imageUrl':
            'https://images.unsplash.com/photo-1578321272176-b7bbc0679853?w=400',
        'memberCount': 934,
        'xpReward': 175,
        'isJoined': true,
        'location': 'Scandinavian Heritage',
      },
      {
        'id': '7',
        'name': 'Egyptian Mysteries',
        'description': 'Unravel the secrets of ancient pharaohs',
        'imageUrl':
            'https://images.unsplash.com/photo-1539650116574-75c0c6d73c6c?w=400',
        'memberCount': 418,
        'xpReward': 190,
        'isJoined': false,
        'location': 'Nile Valley Explorer',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Communities List',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.navyBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${communities.length} Active',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.navyBlue,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 4),

          // Communities list
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 20.0,
                    child: FadeInAnimation(
                      child:
                          _buildCommunityCard(context, community, isDarkMode),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(
      BuildContext context, Map<String, dynamic> community, bool isDarkMode) {
    final isJoined = community['isJoined'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isJoined
              ? AppColors.limeGreen.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Community image with overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: community['imageUrl'] as String,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    if (isJoined)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Community info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community['name'] as String,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.navyBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        community['description'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                              fontSize: 13,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        community['location'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.limeGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),

                // Member count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.limeGreen,
                        AppColors.limeGreen.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatMemberCount(community['memberCount'] as int),
                        style: const TextStyle(
                          color: AppColors.navyBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'members',
                        style: const TextStyle(
                          color: AppColors.navyBlue,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom row with XP and action button
            Row(
              children: [
                // XP Reward badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        size: 16,
                        color: AppColors.navyBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+${community['xpReward']} XP',
                        style: const TextStyle(
                          color: AppColors.navyBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Activity indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Join/Joined button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isJoined
                        ? Colors.green.withOpacity(0.1)
                        : AppColors.limeGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: isJoined
                        ? Border.all(color: Colors.green, width: 1)
                        : null,
                  ),
                  child: Text(
                    isJoined ? 'Joined' : 'Join',
                    style: TextStyle(
                      color: isJoined ? Colors.green : AppColors.navyBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMemberCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
