import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/social_user.dart';
import 'package:knowledge/data/providers/social_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class AddFriendsScreen extends HookConsumerWidget {
  const AddFriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = ref.watch(searchQueryProvider);
    final socialResults = ref.watch(socialNotifierProvider);
    final isSearching = useState(false);

    // Create a debounced search function
    final debouncer = useMemoized(() => Debouncer(milliseconds: 1000));

    // Track when text changes to show a visual indicator while debouncing
    final onSearchTextChanged = useCallback((String value) {
      isSearching.value = true;
      ref.read(searchQueryProvider.notifier).setQuery(value);

      // Use debouncer to delay the API call
      debouncer.run(() {
        isSearching.value = false;
        ref.read(socialNotifierProvider.notifier).searchUsers(value);
      });
    }, [debouncer]);

    // Cleanup debouncer on dispose
    useEffect(() {
      return () {
        debouncer.dispose();
      };
    }, [debouncer]);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Friends',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.navyBlue,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(
              controller: searchController,
              onSearch: onSearchTextChanged,
              isSearching: isSearching.value,
            ),
          ),
          if (isSearching.value)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Searching...',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Expanded(
            child: socialResults.when(
              data: (users) {
                if (users.isEmpty &&
                    searchQuery.isNotEmpty &&
                    !isSearching.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found matching "${searchQuery}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try a different search term',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (users.isEmpty && !isSearching.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for users by their username',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Find friends to follow their activity',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _UserListItem(
                      user: user,
                      onFollowPressed: () {
                        if (user.isFollowing) {
                          ref
                              .read(socialNotifierProvider.notifier)
                              .unfollowUser(user.profileId);
                        } else {
                          ref
                              .read(socialNotifierProvider.notifier)
                              .followUser(user.profileId);
                        }
                      },
                      onTap: () {
                        // Navigate to user profile
                        context.push('/profile/${user.userId}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    SelectableText.rich(
                      TextSpan(
                        text: 'Error: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        children: [
                          TextSpan(
                            text: error.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(socialNotifierProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.limeGreen,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({
    required TextEditingController controller,
    required Function(String) onSearch,
    required bool isSearching,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearch,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Enter username to search...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isSearching ? AppColors.limeGreen : Colors.grey,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        cursorColor: AppColors.navyBlue,
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final SocialUser user;
  final VoidCallback onFollowPressed;
  final VoidCallback onTap;

  const _UserListItem({
    required this.user,
    required this.onFollowPressed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Follow button
              ElevatedButton(
                onPressed: onFollowPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isFollowing
                      ? Colors.grey.shade200
                      : AppColors.navyBlue,
                  foregroundColor:
                      user.isFollowing ? Colors.black87 : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: Text(
                  user.isFollowing ? 'Unfollow' : 'Follow',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A debouncer class that delays execution of a function
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
