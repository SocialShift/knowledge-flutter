import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/data/models/history_item.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/repositories/timeline_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/models/timeline.dart';

class HistoryCard extends ConsumerWidget {
  final HistoryItem item;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineDetailAsync = ref.watch(timelineDetailProvider(item.id));

    // Get screen width to calculate responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Use aspect ratio constraint rather than fixed height
        constraints: BoxConstraints(
          minHeight: isSmallScreen ? 160 : 180,
          maxHeight: 220,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with proper flex ratio based on screen size
              Expanded(
                flex: isSmallScreen ? 7 : 8,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image with Hero Animation
                    Hero(
                      tag: 'timeline_${item.id}',
                      child: _BackgroundImage(imageUrl: item.imageUrl),
                    ),

                    // Dark Gradient Overlay
                    _GradientOverlay(),
                  ],
                ),
              ),

              // Bottom section - optimized with responsive sizing
              Expanded(
                flex: isSmallScreen ? 9 : 8,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 10,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with responsive font size
                      Text(
                        item.title,
                        style: TextStyle(
                          color: const Color(0xFF36459C),
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: isSmallScreen ? 4 : 6),

                      // Character avatar and name
                      Row(
                        children: [
                          // Character Avatar (if available)
                          timelineDetailAsync.when(
                            loading: () => SizedBox(
                              width: isSmallScreen ? 20 : 24,
                              height: isSmallScreen ? 20 : 24,
                              child: CircleAvatar(
                                backgroundColor: const Color(0xFFE0E0E0),
                                child: SizedBox(
                                  width: isSmallScreen ? 10 : 12,
                                  height: isSmallScreen ? 10 : 12,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.limeGreen),
                                  ),
                                ),
                              ),
                            ),
                            error: (_, __) => SizedBox(
                              width: isSmallScreen ? 20 : 24,
                              height: isSmallScreen ? 20 : 24,
                            ),
                            data: (timeline) {
                              if (timeline.mainCharacter != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 10 : 12),
                                  child: CachedNetworkImage(
                                    imageUrl: timeline.mainCharacter!.avatarUrl,
                                    width: isSmallScreen ? 20 : 24,
                                    height: isSmallScreen ? 20 : 24,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: SizedBox(
                                          width: isSmallScreen ? 10 : 12,
                                          height: isSmallScreen ? 10 : 12,
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.limeGreen),
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        CircleAvatar(
                                      radius: isSmallScreen ? 10 : 12,
                                      backgroundColor:
                                          AppColors.navyBlue.withOpacity(0.1),
                                      child: Icon(
                                        Icons.person,
                                        size: isSmallScreen ? 12 : 14,
                                        color: AppColors.navyBlue,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return SizedBox(width: isSmallScreen ? 20 : 24);
                              }
                            },
                          ),

                          SizedBox(width: isSmallScreen ? 4 : 6),

                          // Character name (if available)
                          timelineDetailAsync.maybeWhen(
                            data: (timeline) {
                              if (timeline.mainCharacter != null) {
                                return Expanded(
                                  child: Text(
                                    timeline.mainCharacter!.persona,
                                    style: TextStyle(
                                      color: AppColors.navyBlue,
                                      fontSize: isSmallScreen ? 10 : 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              } else {
                                return const Spacer();
                              }
                            },
                            orElse: () => const Spacer(),
                          ),
                        ],
                      ),

                      // Use Expanded instead of SizedBox to push button to bottom
                      const Expanded(child: SizedBox()),

                      // Learn more button with responsive sizing
                      Container(
                        width: double.infinity,
                        height: isSmallScreen ? 28 : 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3E635),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextButton(
                          onPressed: onTap,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Learn more',
                                style: TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: isSmallScreen ? 11 : 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 2 : 4),
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.navyBlue,
                                size: isSmallScreen ? 10 : 12,
                              ),
                            ],
                          ),
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
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  final String imageUrl;

  const _BackgroundImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[800],
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[800],
        child: const Icon(
          Icons.error,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.3),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}
