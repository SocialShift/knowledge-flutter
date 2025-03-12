import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';

class CircularTimeline extends StatelessWidget {
  final List<TimelinePeriod> periods;
  final int selectedIndex;
  final Function(int) onPeriodSelected;
  final List<String>? timelineIds;

  const CircularTimeline({
    super.key,
    required this.periods,
    required this.selectedIndex,
    required this.onPeriodSelected,
    this.timelineIds,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        children: [
          // Main timeline content
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Add +1 to itemCount to include the "End!" label
              itemCount: periods.length + 1,
              itemBuilder: (context, index) {
                // Check if this is the "End!" item
                final isEndLabel = index == periods.length;

                if (isEndLabel) {
                  // Render the "End!" label
                  return Container(
                    width: 60,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // "End!" label
                        Positioned(
                          top: 36, // Just above the line
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.limeGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.limeGreen,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              "End!",
                              style: TextStyle(
                                color: AppColors.limeGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Regular timeline item
                final period = periods[index];
                final isSelected = index == selectedIndex;
                final timelineId =
                    timelineIds != null && index < timelineIds!.length
                        ? timelineIds![index]
                        : null;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Timeline circle
                    GestureDetector(
                      onTap: () => onPeriodSelected(index),
                      child: Tooltip(
                        message: timelineId != null
                            ? 'Long press to view timeline details'
                            : '',
                        child: Stack(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.limeGreen
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color:
                                          AppColors.limeGreen.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Hero(
                                  tag: timelineId != null
                                      ? 'timeline_$timelineId'
                                      : 'timeline_${period.year}',
                                  child: ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: period.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[800],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    AppColors.limeGreen),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.error,
                                            color: Colors.white54),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Add a ripple effect for better touch feedback
                            if (timelineId != null)
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => onPeriodSelected(index),
                                    onLongPress: () =>
                                        context.push('/timeline/$timelineId'),
                                    splashColor:
                                        AppColors.limeGreen.withOpacity(0.3),
                                    highlightColor:
                                        AppColors.limeGreen.withOpacity(0.1),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Line and year label after each circle
                    Container(
                      width: 60,
                      height: 90,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Horizontal line
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 45, // Center of the container
                            child: Container(
                              height: 3,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),

                          // Year label on top of the line
                          Positioned(
                            top: 36, // Just above the line
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.navyBlue,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                period.year.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TimelinePeriod {
  final int year;
  final String imageUrl;
  final String? title;

  TimelinePeriod({
    required this.year,
    required this.imageUrl,
    this.title,
  });
}
