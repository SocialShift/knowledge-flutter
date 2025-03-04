import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class CircularTimeline extends StatelessWidget {
  final List<TimelinePeriod> periods;
  final int selectedIndex;
  final Function(int) onPeriodSelected;

  const CircularTimeline({
    super.key,
    required this.periods,
    required this.selectedIndex,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onPeriodSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  // Circle with year
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
                            color: AppColors.limeGreen.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'timeline_${period.year}',
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.limeGreen),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.error,
                                  color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Year text
                  Text(
                    period.year.toString(),
                    style: TextStyle(
                      color: isSelected ? AppColors.limeGreen : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
