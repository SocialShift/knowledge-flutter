import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/community.dart';
import 'package:knowledge/data/providers/community_provider.dart';
import 'package:knowledge/data/repositories/social_repository.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/presentation/screens/community/post_comments_screen.dart';
import 'package:knowledge/presentation/widgets/report_dialog.dart';
// import 'package:knowledge/data/providers/post_provider.dart';

class CommunityDetailScreen extends HookConsumerWidget {
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

    // Scroll controller to detect when banner disappears
    final scrollController = useScrollController();
    final showTopNotification = useState(false);

    // Listen to scroll changes
    useEffect(() {
      void scrollListener() {
        // Calculate when posts section (white area) touches the top
        // This should be when the SliverAppBar's expanded height is fully scrolled
        final postsThreshold =
            320.0; // Match the expandedHeight from SliverAppBar
        final isPostsTouchingTop = scrollController.hasClients &&
            scrollController.offset >= postsThreshold;

        if (isPostsTouchingTop != showTopNotification.value) {
          showTopNotification.value = isPostsTouchingTop;
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : AppColors.offWhite,
      body: communityAsync.when(
        data: (community) => Stack(
          children: [
            _buildCommunityDetail(
                context, ref, community, isDarkMode, scrollController),

            // Top Notification Bar (appears when scrolled past banner)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: showTopNotification.value ? 0 : -200,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: showTopNotification.value ? 1.0 : 0.0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).padding.top + 8, 20, 12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.darkSurface.withOpacity(0.95)
                        : Colors.white.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              community.name,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.navyBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${_formatMemberCount(community.memberCount)} members',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Create post button in notification bar
                      GestureDetector(
                        onTap: () {
                          context.push('/community/${community.id}/create-post',
                              extra: {
                                'communityName': community.name,
                              });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.limeGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Post',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        loading: () => _buildLoadingState(context, isDarkMode),
        error: (error, stack) =>
            _buildErrorState(context, ref, communityId, error, isDarkMode),
      ),
    );
  }

  Widget _buildCommunityDetail(BuildContext context, WidgetRef ref,
      Community community, bool isDarkMode, ScrollController scrollController) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Enhanced SliverAppBar with integrated community info
        _buildEnhancedHeader(context, ref, community, isDarkMode),

        // Posts Section
        SliverToBoxAdapter(
          child: _buildPostsSection(context, ref, community, isDarkMode),
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
            } else if (value == 'report') {
              // Show report dialog for community
              _showReportDialog(
                context,
                'community',
                community.id,
                community.name,
              );
            } else if (value == 'delete') {
              // Show delete confirmation dialog for community
              _showDeleteCommunityDialog(context, ref, community);
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
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Report', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            // Only show delete option if current user is the community owner
            if (isCreatedByCurrentUser)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Community',
                        style: TextStyle(color: Colors.red)),
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

  void _showReportDialog(
      BuildContext context, String reportType, int itemId, String itemName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReportDialog(
          reportType: reportType,
          reportedItemId: itemId,
          itemName: itemName,
        );
      },
    );
  }

  Widget _buildPostsSection(BuildContext context, WidgetRef ref,
      Community community, bool isDarkMode) {
    final postsAsync = ref.watch(communityPostsProvider(community.id));

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(top: 0),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkSurface.withOpacity(0.85)
                : Colors.white.withOpacity(0.85),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                    height: 24), // Slightly more space to see banner curves

                // Posts Content
                postsAsync.when(
                  data: (posts) => posts.isEmpty
                      ? _buildEmptyPosts(context, isDarkMode)
                      : _buildPostsList(
                          context, ref, posts, isDarkMode, community),
                  loading: () => _buildPostsLoading(context, isDarkMode),
                  error: (error, stack) => _buildPostsError(
                      context, ref, community.id, error, isDarkMode),
                ),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .slideY(
            begin: 1.0,
            duration: 1000.ms,
            curve: Curves.easeOutCubic,
            delay: 300.ms)
        .fadeIn(duration: 800.ms, delay: 300.ms);
  }

  Widget _buildEmptyPosts(BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 0, 0), // Consistent left margin
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
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

  Widget _buildPostsList(BuildContext context, WidgetRef ref, List<Post> posts,
      bool isDarkMode, Community community) {
    return Column(
      children: posts.asMap().entries.map((entry) {
        final index = entry.key;
        final post = entry.value;
        return _buildPostCard(context, ref, post, isDarkMode, community)
            .animate()
            .fadeIn(duration: 600.ms, delay: (index * 150).ms)
            .slideY(
              begin: 0.3,
              duration: 800.ms,
              curve: Curves.easeOutCubic,
            );
      }).toList(),
    );
  }

  Widget _buildPostCard(BuildContext context, WidgetRef ref, Post post,
      bool isDarkMode, Community community) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header with User Info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Author Avatar with actual user data
                _buildUserAvatar(ref, post.createdBy, isDarkMode),
                const SizedBox(width: 12),

                // Author Info with actual user data
                Expanded(
                  child: _buildUserInfo(context, ref, post, isDarkMode),
                ),

                // Post Menu
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                      size: 18,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'report') {
                      _showReportDialog(
                        context,
                        'post',
                        post.id,
                        post.title,
                      );
                    } else if (value == 'delete') {
                      _showDeletePostDialog(context, ref, post, community);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Report', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    // Show delete option if current user is the post creator or community owner
                    if (_canDeletePost(ref, post, community))
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Post',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.fromLTRB(
                32, 0, 20, 0), // Increased left margin
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Title
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),

                // Post Body
                if (post.body != null && post.body!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    post.body!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700,
                          height: 1.5,
                          fontSize: 15,
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
          Container(
            margin:
                const EdgeInsets.fromLTRB(32, 16, 20, 16), // Match left margin
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Upvote
                _buildVoteButton(
                  context,
                  Icons.keyboard_arrow_up_rounded,
                  post.upvote,
                  Colors.green,
                  isDarkMode,
                  () => _handleVote(ref, post.id, 1, community.id),
                ),
                const SizedBox(width: 20),

                // Downvote
                _buildVoteButton(
                  context,
                  Icons.keyboard_arrow_down_rounded,
                  post.downvote,
                  Colors.red,
                  isDarkMode,
                  () => _handleVote(ref, post.id, -1, community.id),
                ),

                const Spacer(),

                // Comments with count
                _buildCommentButton(
                    context, ref, post, community.name, isDarkMode),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
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

  // Helper method to build user avatar with actual user data
  Widget _buildUserAvatar(WidgetRef ref, int? userId, bool isDarkMode) {
    if (userId == null) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.limeGreen.withOpacity(0.2),
        child: Icon(
          Icons.person,
          color: AppColors.navyBlue,
          size: 20,
        ),
      );
    }

    final userProfileAsync = ref.watch(userProfileByIdProvider(userId));

    return userProfileAsync.when(
      data: (profile) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.limeGreen.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: profile.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.limeGreen.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: AppColors.navyBlue,
                      size: 20,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.limeGreen.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: AppColors.navyBlue,
                      size: 20,
                    ),
                  ),
                )
              : Container(
                  color: AppColors.limeGreen.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: AppColors.navyBlue,
                    size: 20,
                  ),
                ),
        ),
      ),
      loading: () => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.3),
        ),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
        ),
      ),
      error: (_, __) => CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.limeGreen.withOpacity(0.2),
        child: Icon(
          Icons.person,
          color: AppColors.navyBlue,
          size: 20,
        ),
      ),
    );
  }

  // Helper method to build user info with actual user data
  Widget _buildUserInfo(
      BuildContext context, WidgetRef ref, Post post, bool isDarkMode) {
    if (post.createdBy == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unknown User',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.navyBlue,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            _formatDate(post.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                  fontSize: 12,
                ),
          ),
        ],
      );
    }

    final userProfileAsync =
        ref.watch(userProfileByIdProvider(post.createdBy!));

    return userProfileAsync.when(
      data: (profile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.push('/profile/${post.createdBy}');
            },
            child: Text(
              profile.nickname ?? 'Unknown User',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDarkMode ? Colors.white : AppColors.navyBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            _formatDate(post.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                  fontSize: 12,
                ),
          ),
        ],
      ),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 12,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unknown User',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.navyBlue,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            _formatDate(post.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  // Handle voting on posts
  Future<void> _handleVote(
      WidgetRef ref, int postId, int voteType, int communityId) async {
    try {
      await ref.read(postActionsProvider.notifier).votePost(
            postId: postId,
            voteType: voteType,
            communityId: communityId,
          );
    } catch (e) {
      // Handle error silently or show a snackbar
      print('Error voting on post: $e');
    }
  }

  // Navigate to comments screen
  void _navigateToComments(
      BuildContext context, Post post, String communityName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostCommentsScreen(
          post: post,
          communityName: communityName,
        ),
      ),
    );
  }

  // Build comment button with actual comment count
  Widget _buildCommentButton(BuildContext context, WidgetRef ref, Post post,
      String communityName, bool isDarkMode) {
    final commentsAsync = ref.watch(postCommentsProvider(post.id));

    return commentsAsync.when(
      data: (comments) => GestureDetector(
        onTap: () => _navigateToComments(context, post, communityName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: AppColors.navyBlue,
              ),
              const SizedBox(width: 6),
              Text(
                '${comments.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.navyBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
      loading: () => GestureDetector(
        onTap: () => _navigateToComments(context, post, communityName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: AppColors.navyBlue,
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.navyBlue),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (_, __) => GestureDetector(
        onTap: () => _navigateToComments(context, post, communityName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 16,
                color: AppColors.navyBlue,
              ),
              const SizedBox(width: 6),
              Text(
                '0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.navyBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Check if current user can delete the post (post creator or community owner)
  bool _canDeletePost(WidgetRef ref, Post post, Community community) {
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.maybeWhen(
      authenticated: (user, _, __) => user.id,
      orElse: () => null,
    );

    if (currentUserId == null) return false;

    // Post creator can delete their own post
    final isPostCreator =
        post.createdBy != null && currentUserId == post.createdBy.toString();

    // Community owner can delete any post in their community
    final isCommunityOwner = community.createdBy != null &&
        currentUserId == community.createdBy.toString();

    return isPostCreator || isCommunityOwner;
  }

  // Show delete community confirmation dialog
  void _showDeleteCommunityDialog(
      BuildContext context, WidgetRef ref, Community community) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkCard : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Delete Community',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${community.name}"?',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone. All posts, comments, and community data will be permanently deleted.',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCommunity(context, ref, community);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Show delete post confirmation dialog
  void _showDeletePostDialog(
      BuildContext context, WidgetRef ref, Post post, Community community) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkCard : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Delete Post',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : AppColors.navyBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this post?',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${post.title}"',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(context, ref, post, community);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Handle community deletion
  Future<void> _deleteCommunity(
      BuildContext context, WidgetRef ref, Community community) async {
    try {
      final communityActions = ref.read(communityActionsProvider.notifier);
      await communityActions.deleteCommunity(community.id);

      if (context.mounted) {
        // Navigate back to communities list
        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Community "${community.name}" deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete community: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Handle post deletion
  Future<void> _deletePost(BuildContext context, WidgetRef ref, Post post,
      Community community) async {
    try {
      final postActions = ref.read(postActionsProvider.notifier);
      await postActions.deletePost(
        postId: post.id,
        communityId: community.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete post: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
