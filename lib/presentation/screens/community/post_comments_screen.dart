import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/community.dart';
import 'package:knowledge/data/repositories/social_repository.dart';
import 'package:knowledge/data/providers/community_provider.dart';
import 'package:knowledge/data/providers/profile_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PostCommentsScreen extends HookConsumerWidget {
  final Post post;
  final String communityName;

  const PostCommentsScreen({
    super.key,
    required this.post,
    required this.communityName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final commentController = useTextEditingController();
    final isLoading = useState(false);

    // Get real comments from API
    final commentsAsync = ref.watch(postCommentsProvider(post.id));

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : AppColors.offWhite,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? AppColors.darkSurface : AppColors.navyBlue,
        foregroundColor: Colors.white,
        title: Text(
          communityName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Fixed Original Post Card
          Container(
            padding: const EdgeInsets.all(20),
            child: _buildOriginalPost(context, ref, isDarkMode),
          ),

          // Scrollable Comments Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Comments Section
                  commentsAsync.when(
                    data: (comments) => Column(
                      children: [
                        // Comments Section Header
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.navyBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Comments (${comments.length})',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.navyBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                        const SizedBox(height: 16),

                        // Comments List
                        if (comments.isEmpty)
                          _buildEmptyComments(context, isDarkMode)
                        else
                          ...comments.asMap().entries.map((entry) {
                            final index = entry.key;
                            final comment = entry.value;
                            return _buildCommentCard(
                                    context, ref, comment, isDarkMode)
                                .animate()
                                .fadeIn(
                                    duration: 500.ms,
                                    delay: (600 + index * 100).ms)
                                .slideX(
                                    begin: 0.3,
                                    duration: 600.ms,
                                    curve: Curves.easeOutCubic);
                          }).toList(),
                      ],
                    ),
                    loading: () => _buildCommentsLoading(context, isDarkMode),
                    error: (error, stack) =>
                        _buildCommentsError(context, isDarkMode),
                  ),

                  const SizedBox(height: 100), // Space for bottom input
                ],
              ),
            ),
          ),

          // Comment Input Section
          _buildCommentInput(
              context, ref, commentController, isLoading, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildOriginalPost(
      BuildContext context, WidgetRef ref, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.limeGreen.withOpacity(0.3),
          width: 2,
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
          // Post Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildUserAvatar(ref, post.createdBy, isDarkMode),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUserInfo(context, ref, isDarkMode),
                ),
              ],
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
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
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              child: CachedNetworkImage(
                imageUrl: post.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
          ],

          // Post Actions
          Container(
            margin: const EdgeInsets.fromLTRB(32, 16, 20, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildVoteButton(
                    Icons.keyboard_arrow_up_rounded,
                    post.upvote,
                    Colors.green,
                    isDarkMode,
                    () => _handleVote(ref, post.id, 1)),
                const SizedBox(width: 20),
                _buildVoteButton(
                    Icons.keyboard_arrow_down_rounded,
                    post.downvote,
                    Colors.red,
                    isDarkMode,
                    () => _handleVote(ref, post.id, -1)),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, duration: 800.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildCommentCard(BuildContext context, WidgetRef ref,
      Map<String, dynamic> comment, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Row(
            children: [
              _buildUserAvatar(ref, comment['commented_by'], isDarkMode),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCommentUserInfo(context, ref, comment, isDarkMode),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment Text
          Padding(
            padding: const EdgeInsets.only(left: 56), // Align with username
            child: Text(
              comment['comment'],
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(
      BuildContext context,
      WidgetRef ref,
      TextEditingController controller,
      ValueNotifier<bool> isLoading,
      bool isDarkMode) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar (Current User) - Show actual user avatar
          _buildCurrentUserAvatar(ref, isDarkMode),
          const SizedBox(width: 12),

          // Comment Input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.limeGreen.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Send Button
          GestureDetector(
            onTap: isLoading.value
                ? null
                : () async {
                    if (controller.text.trim().isEmpty) return;

                    isLoading.value = true;

                    try {
                      // Create comment using API
                      await ref
                          .read(commentActionsProvider.notifier)
                          .createComment(
                            comment: controller.text.trim(),
                            postId: post.id,
                          );

                      controller.clear();
                    } catch (e) {
                      // Handle error
                      print('Error creating comment: $e');
                    } finally {
                      isLoading.value = false;
                    }
                  },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.limeGreen,
                shape: BoxShape.circle,
              ),
              child: isLoading.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(WidgetRef ref, int? userId, bool isDarkMode) {
    if (userId == null) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.limeGreen.withOpacity(0.2),
        child: Icon(Icons.person, color: AppColors.navyBlue, size: 18),
      );
    }

    final userProfileAsync = ref.watch(userProfileByIdProvider(userId));

    return userProfileAsync.when(
      data: (profile) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.limeGreen.withOpacity(0.3), width: 1.5),
        ),
        child: ClipOval(
          child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: profile.avatarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.limeGreen.withOpacity(0.2),
                    child:
                        Icon(Icons.person, color: AppColors.navyBlue, size: 18),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.limeGreen.withOpacity(0.2),
                    child:
                        Icon(Icons.person, color: AppColors.navyBlue, size: 18),
                  ),
                )
              : Container(
                  color: AppColors.limeGreen.withOpacity(0.2),
                  child:
                      Icon(Icons.person, color: AppColors.navyBlue, size: 18),
                ),
        ),
      ),
      loading: () => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.3),
        ),
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.limeGreen.withOpacity(0.2),
        child: Icon(Icons.person, color: AppColors.navyBlue, size: 18),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, WidgetRef ref, bool isDarkMode) {
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
            style: TextStyle(color: Colors.grey, fontSize: 12),
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
          Text(
            profile.nickname ?? 'Unknown User',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDarkMode ? Colors.white : AppColors.navyBlue,
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            _formatDate(post.createdAt),
            style: TextStyle(color: Colors.grey, fontSize: 12),
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
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentUserInfo(BuildContext context, WidgetRef ref,
      Map<String, dynamic> comment, bool isDarkMode) {
    final userProfileAsync =
        ref.watch(userProfileByIdProvider(comment['commented_by']));

    return userProfileAsync.when(
      data: (profile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.nickname ?? 'Unknown User',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.navyBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            _formatDate(comment['created_at']),
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 12,
            width: 50,
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
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.navyBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            _formatDate(comment['created_at']),
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(IconData icon, int count, Color color,
      bool isDarkMode, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
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
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Helper methods for different states
  Widget _buildEmptyComments(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No comments yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to comment!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsLoading(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        // Comments header skeleton
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Container(
              height: 18,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Comment skeletons
        ...List.generate(
            3,
            (index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.darkSurface.withOpacity(0.7)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 16,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
      ],
    );
  }

  Widget _buildCommentsError(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.red.withOpacity(0.1)
            : Colors.red.withOpacity(0.05),
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
            'Failed to load comments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Handle voting on posts
  Future<void> _handleVote(WidgetRef ref, int postId, int voteType) async {
    try {
      await ref.read(postActionsProvider.notifier).votePost(
            postId: postId,
            voteType: voteType,
            communityId:
                0, // We don't have community ID in this context, but the API might not need it for individual posts
          );
    } catch (e) {
      // Handle error silently or show a snackbar
      print('Error voting on post: $e');
    }
  }

  // Build current user avatar for comment input
  Widget _buildCurrentUserAvatar(WidgetRef ref, bool isDarkMode) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (profile) => Container(
        width: 36,
        height: 36,
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
                      size: 18,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.limeGreen.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: AppColors.navyBlue,
                      size: 18,
                    ),
                  ),
                )
              : Container(
                  color: AppColors.limeGreen.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: AppColors.navyBlue,
                    size: 18,
                  ),
                ),
        ),
      ),
      loading: () => Container(
        width: 36,
        height: 36,
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
        radius: 18,
        backgroundColor: AppColors.limeGreen.withOpacity(0.2),
        child: Icon(
          Icons.person,
          color: AppColors.navyBlue,
          size: 18,
        ),
      ),
    );
  }
}
