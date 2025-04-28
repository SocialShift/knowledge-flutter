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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
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
              // Image Section - slightly reduced flex ratio
              Expanded(
                flex: 9,
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

                    // Year Badge
                    // Positioned(
                    //   top: 8,
                    //   left: 8,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 8, vertical: 4),
                    //     decoration: BoxDecoration(
                    //       color: AppColors.limeGreen,
                    //       borderRadius: BorderRadius.circular(6),
                    //     ),
                    //     child: Text(
                    //       item.year.toString(),
                    //       style: const TextStyle(
                    //         color: AppColors.navyBlue,
                    //         fontSize: 10,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              // Bottom section - optimized layout
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF36459C),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Character avatar and name
                      Row(
                        children: [
                          // Character Avatar (if available)
                          timelineDetailAsync.when(
                            loading: () => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircleAvatar(
                                backgroundColor: Color(0xFFE0E0E0),
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.limeGreen),
                                  ),
                                ),
                              ),
                            ),
                            error: (_, __) => const SizedBox(
                              width: 24,
                              height: 24,
                            ),
                            data: (timeline) {
                              if (timeline.mainCharacter != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: timeline.mainCharacter!.avatarUrl,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
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
                                      radius: 12,
                                      backgroundColor:
                                          AppColors.navyBlue.withOpacity(0.1),
                                      child: const Icon(
                                        Icons.person,
                                        size: 14,
                                        color: AppColors.navyBlue,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox(width: 24);
                              }
                            },
                          ),

                          const SizedBox(width: 6),

                          // Character name (if available)
                          timelineDetailAsync.maybeWhen(
                            data: (timeline) {
                              if (timeline.mainCharacter != null) {
                                return Expanded(
                                  child: Text(
                                    timeline.mainCharacter!.persona,
                                    style: const TextStyle(
                                      color: AppColors.navyBlue,
                                      fontSize: 11,
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

                      // Learn more button (full width, rectangular with rounded corners)
                      Container(
                        width: double.infinity,
                        height: 32,
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
                            children: const [
                              Text(
                                'Learn more',
                                style: TextStyle(
                                  color: AppColors.navyBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                color: AppColors.navyBlue,
                                size: 12,
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
