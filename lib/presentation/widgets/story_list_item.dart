import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:flutter/foundation.dart';

class StoryListItem extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const StoryListItem({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Using RepaintBoundary to isolate repainting for better iOS performance
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Image with subtle border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: CachedNetworkImage(
                        imageUrl: story.imageUrl,
                        fit: BoxFit.cover,
                        // Set memory cache size and duration for iOS optimization
                        memCacheWidth: 220, // 2x size for Retina displays
                        memCacheHeight: 220,
                        maxWidthDiskCache: 440,
                        maxHeightDiskCache: 440,
                        filterQuality: FilterQuality.medium,
                        fadeInDuration: const Duration(milliseconds: 200),
                        placeholderFadeInDuration:
                            const Duration(milliseconds: 200),
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.limeGreen),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Right side - Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date with icon
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.navyBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            story.storyDate != null &&
                                    story.storyDate!.isNotEmpty
                                ? _formatDate(story.storyDate!)
                                : '${story.year}',
                            style: TextStyle(
                              color: AppColors.navyBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        story.title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        story.description,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Add a subtle divider and "Read more" indicator
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Read more',
                            style: TextStyle(
                              color: AppColors.limeGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: AppColors.limeGreen,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to format the date from "YYYY-MM-DD" to a more readable format
  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = _getMonthName(int.parse(parts[1]));
        final day = int.parse(parts[2]);

        return '$month $day, $year';
      }
      return dateString;
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting date: $e');
      }
      return dateString;
    }
  }

  // Helper method to convert month number to name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
