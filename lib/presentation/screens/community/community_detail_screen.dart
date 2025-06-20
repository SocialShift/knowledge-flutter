import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/community.dart';
import 'package:knowledge/data/providers/community_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:knowledge/data/providers/auth_provider.dart';
// import 'package:knowledge/data/providers/post_provider.dart';

class CommunityDetailScreen extends ConsumerWidget {
  final int communityId;

  const CommunityDetailScreen({
    super.key,
    required this.communityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityId = int.tryParse(
        GoRouterState.of(context).pathParameters['communityId'] ?? '');

    if (communityId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Community')),
        body: const Center(
          child: Text('Invalid community ID'),
        ),
      );
    }

    final communityAsync = ref.watch(communityDetailsProvider(communityId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : Colors.grey.shade50,
      body: communityAsync.when(
        data: (community) =>
            _buildCommunityDetail(context, ref, community, isDarkMode),
        loading: () => _buildLoadingState(context, isDarkMode),
        error: (error, stack) =>
            _buildErrorState(context, ref, communityId, error, isDarkMode),
      ),
    );
  }

  Widget _buildCommunityDetail(BuildContext context, WidgetRef ref,
      Community community, bool isDarkMode) {
    return CustomScrollView(
      slivers: [
        // Enhanced SliverAppBar with integrated community info
        _buildEnhancedHeader(context, ref, community, isDarkMode),

        // Posts Section
        SliverToBoxAdapter(
          child: _buildPostsSection(context, ref, community, isDarkMode),
        ),

        // Add some bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, WidgetRef ref,
      Community community, bool isDarkMode) {
    // Get current user ID from auth state
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.maybeWhen(
      authenticated: (user, _, __) => user.id,
      orElse: () => null,
    );

    // Check if current user is the creator of this community
    final isCreatedByCurrentUser = currentUserId != null &&
        community.createdBy != null &&
        currentUserId == community.createdBy.toString();

    return SliverAppBar(
      expandedHeight: 320, // Increased height to accommodate info card
      pinned: true,
      backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.navyBlue,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        // 3-dots dropdown menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == 'about') {
              // Scroll to about section or show about dialog
              _showAboutDialog(context, community, isDarkMode);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('About'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Banner Image with blur and overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: community.bannerUrl != null &&
                        community.bannerUrl!.isNotEmpty
                    ? Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: community.bannerUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: AppColors.navyBlue.withOpacity(0.8),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.navyBlue.withOpacity(0.8),
                            ),
                          ),
                          // Blur effect
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                            child: Container(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.navyBlue,
                              AppColors.navyBlue.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            // Community Info Overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Community Icon and Name
                  Row(
                    children: [
                      // Community Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: CachedNetworkImage(
                            imageUrl: community.iconUrl ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.limeGreen.withOpacity(0.3),
                              child: Icon(
                                Icons.groups,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.limeGreen.withOpacity(0.3),
                              child: Icon(
                                Icons.groups,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Community Name and Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              community.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Stats Row
                            Row(
                              children: [
                                _buildStatChip(
                                  context,
                                  Icons.people,
                                  _formatMemberCount(community.memberCount),
                                ),
                                const SizedBox(width: 12),
                                _buildStatChip(
                                  context,
                                  Icons.calendar_today,
                                  _formatDate(community.createdAt),
                                ),
                                const SizedBox(width: 12),
                                _buildStatChip(
                                  context,
                                  Icons.visibility,
                                  'Public',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Join/Leave or Owner Button
                      Expanded(
                        flex: 2,
                        child: isCreatedByCurrentUser
                            ? Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Community Owner',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  _handleJoinLeave(context, ref, community);
                                },
                                icon: Icon(
                                  community.isMember
                                      ? Icons.person_remove
                                      : Icons.person_add,
                                  size: 18,
                                ),
                                label: Text(
                                  community.isMember ? 'Leave' : 'Join',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: community.isMember
                                      ? Colors.grey.shade600.withOpacity(0.9)
                                      : AppColors.limeGreen,
                                  foregroundColor: community.isMember
                                      ? Colors.white
                                      : AppColors.navyBlue,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(width: 12),

                      // Create Post Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push(
                                '/community/${community.id}/create-post',
                                extra: {
                                  'communityName': community.name,
                                });
                          },
                          icon: Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Post',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.navyBlue.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(
      BuildContext context, Community community, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkCard : Colors.white,
          title: Text(
            'About ${community.name}',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.navyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  community.description ?? 'No description available.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    height: 1.5,
                  ),
                ),
                if (community.topics != null &&
                    community.topics!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Topics',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.navyBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    community.topics!,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostsSection(BuildContext context, WidgetRef ref,
      Community community, bool isDarkMode) {
    final postsAsync = ref.watch(communityPostsProvider(community.id));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community Posts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDarkMode ? Colors.white : AppColors.navyBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              Icon(
                Icons.forum,
                color: isDarkMode ? Colors.white70 : AppColors.navyBlue,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Posts Content
          postsAsync.when(
            data: (posts) => posts.isEmpty
                ? _buildEmptyPosts(context, isDarkMode)
                : _buildPostsList(context, ref, posts, isDarkMode),
            loading: () => _buildPostsLoading(context, isDarkMode),
            error: (error, stack) =>
                _buildPostsError(context, ref, community.id, error, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPosts(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to start a discussion!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(
      BuildContext context, WidgetRef ref, List<Post> posts, bool isDarkMode) {
    return Column(
      children: posts
          .map((post) => _buildPostCard(context, ref, post, isDarkMode))
          .toList(),
    );
  }

  Widget _buildPostCard(
      BuildContext context, WidgetRef ref, Post post, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Author Avatar (placeholder for now)
                CircleAvatar(
                  backgroundColor: AppColors.limeGreen.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: AppColors.navyBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Author Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to user profile
                          if (post.createdBy != null) {
                            context.push('/profile/${post.createdBy}');
                          }
                        },
                        child: Text(
                          'User ${post.createdBy ?? 'Unknown'}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: isDarkMode
                                        ? Colors.white
                                        : AppColors.navyBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.grey.shade500,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),

                // Post Menu
                IconButton(
                  onPressed: () {
                    // Show post options menu
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Title
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                // Post Body
                if (post.body != null && post.body!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.body!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700,
                          height: 1.4,
                        ),
                  ),
                ],
              ],
            ),
          ),

          // Post Image
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
          ],

          // Post Actions (Upvote, Downvote, Comments)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Upvote
                _buildVoteButton(
                  context,
                  Icons.keyboard_arrow_up,
                  post.upvote,
                  Colors.green,
                  isDarkMode,
                  () {
                    // Handle upvote
                  },
                ),
                const SizedBox(width: 16),

                // Downvote
                _buildVoteButton(
                  context,
                  Icons.keyboard_arrow_down,
                  post.downvote,
                  Colors.red,
                  isDarkMode,
                  () {
                    // Handle downvote
                  },
                ),

                const Spacer(),

                // Comments (placeholder)
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 18,
                      color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Comment',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? Colors.white60
                                : Colors.grey.shade500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(
    BuildContext context,
    IconData icon,
    int count,
    Color color,
    bool isDarkMode,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsLoading(BuildContext context, bool isDarkMode) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsError(BuildContext context, WidgetRef ref, int communityId,
      Object error, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load posts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(communityPostsProvider(communityId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navyBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isDarkMode) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor:
                isDarkMode ? AppColors.darkCard : AppColors.navyBlue,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.navyBlue,
                      AppColors.navyBlue.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, int communityId,
      Object error, bool isDarkMode) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.navyBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load community',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(communityDetailsProvider(communityId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleJoinLeave(
      BuildContext context, WidgetRef ref, Community community) async {
    try {
      final communityActions = ref.read(communityActionsProvider.notifier);

      if (community.isMember) {
        // Leave the community
        await communityActions.leaveCommunity(community.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Left ${community.name}'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Join the community
        await communityActions.joinCommunity(community.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined ${community.name}!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatMemberCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else {
        return 'Today';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
