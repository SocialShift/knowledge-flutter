import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/models/badge.dart' as badge_model;
import 'package:knowledge/data/providers/profile_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class BadgesScreen extends HookConsumerWidget {
  const BadgesScreen({super.key});

  // Helper method to check if asset exists
  Future<bool> _checkAssetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      print('Asset not found: $assetPath');
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;

    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Badges',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => _buildLoadingSkeleton(isDarkMode),
        error: (error, stack) => _buildErrorState(error, textColor),
        data: (profile) => _buildBadgesContent(profile, isDarkMode),
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDarkMode) {
    final skeletonColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header skeleton
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),

          // Badge grid skeleton
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: 8,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    ).animate().shimmer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
        );
  }

  Widget _buildErrorState(Object error, Color textColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load badges',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesContent(dynamic profile, bool isDarkMode) {
    final earnedBadges = profile.badges as List<badge_model.Badge>;
    final earnedBadgeIds = earnedBadges.map((badge) => badge.id).toSet();
    final allBadges = badge_model.AllBadges.getAllBadges();

    // Group badges by path
    final badgesByPath = <String, List<badge_model.Badge>>{};
    for (final badge in allBadges) {
      badgesByPath.putIfAbsent(badge.path, () => []).add(badge);
    }

    // Sort badges within each path by tier
    for (final badges in badgesByPath.values) {
      badges.sort((a, b) => int.parse(a.tier).compareTo(int.parse(b.tier)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          _buildBadgeStats(earnedBadges, allBadges, isDarkMode),
          const SizedBox(height: 24),

          // Badge sections by path
          ...badgesByPath.entries.map((entry) {
            final pathName = entry.key;
            final pathBadges = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPathHeader(
                    pathName, pathBadges, earnedBadgeIds, isDarkMode),
                const SizedBox(height: 16),
                _buildBadgeGrid(pathBadges, earnedBadgeIds, isDarkMode),
                const SizedBox(height: 32),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBadgeStats(List<badge_model.Badge> earnedBadges,
      List<badge_model.Badge> allBadges, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.navyBlue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Badge icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.limeGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.military_tech,
              color: AppColors.limeGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),

          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Badge Collection',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${earnedBadges.length} of ${allBadges.length} badges earned',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Progress circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: earnedBadges.length / allBadges.length,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                  strokeWidth: 4,
                ),
              ),
              Text(
                '${((earnedBadges.length / allBadges.length) * 100).toInt()}%',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }

  Widget _buildPathHeader(String pathName, List<badge_model.Badge> pathBadges,
      Set<String> earnedBadgeIds, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final earnedCount =
        pathBadges.where((badge) => earnedBadgeIds.contains(badge.id)).length;

    return Row(
      children: [
        Icon(
          _getPathIcon(pathName),
          color: _getPathColor(pathName),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge_model.BadgePath.getDisplayName(pathName),
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$earnedCount of ${pathBadges.length} badges',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Mini progress bar
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: earnedCount / pathBadges.length,
            child: Container(
              decoration: BoxDecoration(
                color: _getPathColor(pathName),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeGrid(List<badge_model.Badge> pathBadges,
      Set<String> earnedBadgeIds, bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: pathBadges.length,
      itemBuilder: (context, index) {
        final badge = pathBadges[index];
        final isEarned = earnedBadgeIds.contains(badge.id);

        return _buildBadgeCard(badge, isEarned, isDarkMode);
      },
    );
  }

  Widget _buildBadgeCard(
      badge_model.Badge badge, bool isEarned, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final borderColor = isEarned
        ? _getPathColor(badge.path)
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);

    // Debug print to check badge info
    print('Building badge card for: ${badge.id}, isEarned: $isEarned');
    print('Badge path: assets/images/badges/${badge.id}.png');

    return GestureDetector(
      onTap: () => _showBadgeDetails(badge, isEarned),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isEarned ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isEarned
                        ? _getPathColor(badge.path).withOpacity(0.1)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: FutureBuilder<bool>(
                      future: _checkAssetExists(
                          'assets/images/badges/${badge.id}.png'),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return Image.asset(
                            'assets/images/badges/${badge.id}.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            color: isEarned ? null : Colors.grey.shade400,
                            colorBlendMode:
                                isEarned ? null : BlendMode.saturation,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                  'Error loading badge image: ${badge.id}.png - $error');
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _getPathColor(badge.path)
                                      .withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.military_tech,
                                  color: isEarned
                                      ? _getPathColor(badge.path)
                                      : Colors.grey.shade400,
                                  size: 40,
                                ),
                              );
                            },
                          );
                        } else {
                          print(
                              'Asset not found: assets/images/badges/${badge.id}.png');
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _getPathColor(badge.path).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.military_tech,
                              color: isEarned
                                  ? _getPathColor(badge.path)
                                  : Colors.grey.shade400,
                              size: 40,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                if (!isEarned)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Badge name
            Text(
              badge.name,
              style: TextStyle(
                color: isEarned ? textColor : textColor.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Tier
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isEarned
                    ? _getPathColor(badge.path).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tier ${badge.tier}',
                style: TextStyle(
                  color: isEarned
                      ? _getPathColor(badge.path)
                      : Colors.grey.shade500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: 100),
        );
  }

  void _showBadgeDetails(badge_model.Badge badge, bool isEarned) {
    // Show badge details in a modal
    // This would be implemented based on your app's modal pattern
  }

  IconData _getPathIcon(String path) {
    switch (path) {
      case badge_model.BadgePath.illumination:
        return Icons.lightbulb;
      case badge_model.BadgePath.game:
        return Icons.games;
      case badge_model.BadgePath.streak:
        return Icons.local_fire_department;
      case badge_model.BadgePath.starter:
        return Icons.star;
      default:
        return Icons.military_tech;
    }
  }

  Color _getPathColor(String path) {
    switch (path) {
      case badge_model.BadgePath.illumination:
        return Colors.amber;
      case badge_model.BadgePath.game:
        return Colors.purple;
      case badge_model.BadgePath.streak:
        return Colors.orange;
      case badge_model.BadgePath.starter:
        return Colors.blue;
      default:
        return AppColors.limeGreen;
    }
  }
}
