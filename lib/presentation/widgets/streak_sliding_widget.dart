import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/providers/profile_provider.dart';

class StreakSlidingWidget extends HookConsumerWidget {
  const StreakSlidingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final overlayEntry = useState<OverlayEntry?>(null);

    // Watch the user profile to get streak data
    final profileAsync = ref.watch(userProfileProvider);

    void _showStreakOverlay() {
      if (overlayEntry.value != null) return;

      final overlay = Overlay.of(context);
      final entry = OverlayEntry(
        builder: (context) => _StreakOverlay(
          onClose: () {
            overlayEntry.value?.remove();
            overlayEntry.value = null;
          },
          isDarkMode: isDarkMode,
          profileAsync: profileAsync,
        ),
      );

      overlayEntry.value = entry;
      overlay.insert(entry);
      HapticFeedback.lightImpact();
    }

    // Clean up overlay when widget is disposed
    useEffect(() {
      return () {
        overlayEntry.value?.remove();
        overlayEntry.value = null;
      };
    }, []);

    return profileAsync.when(
      data: (profile) {
        final currentStreak = profile.currentLoginStreak ?? 0;

        return GestureDetector(
          onTap: _showStreakOverlay,
          child: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular background
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // Fire icon (scroll icon)
                SvgPicture.asset(
                  'assets/icons/scroll.svg',
                  height: 24,
                  width: 24,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                // Streak number
                Positioned(
                  top: 13,
                  child: Center(
                    child: Text(
                      '$currentStreak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(
              delay: const Duration(milliseconds: 300),
            );
      },
      loading: () => Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      error: (_, __) => Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.only(right: 12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/scroll.svg',
              height: 24,
              width: 24,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const Positioned(
              top: 13,
              child: Center(
                child: Text(
                  '0',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate overlay widget that renders full screen
class _StreakOverlay extends HookWidget {
  final VoidCallback onClose;
  final bool isDarkMode;
  final AsyncValue<dynamic> profileAsync;

  const _StreakOverlay({
    required this.onClose,
    required this.isDarkMode,
    required this.profileAsync,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 700),
    );

    useEffect(() {
      animationController.forward();
      return null;
    }, []);

    return profileAsync.when(
      data: (profile) {
        final currentStreak = profile.currentLoginStreak ?? 0;
        final maxStreak = profile.maxLoginStreak ?? 0;
        final completedQuizzes = profile.completedQuizzes ?? 0;

        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            final slideValue =
                Curves.easeOutCubic.transform(animationController.value);

            return Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  animationController.reverse().then((_) => onClose());
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color:
                      Colors.black.withOpacity(0.4 * animationController.value),
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping inside
                    child: Transform.translate(
                      offset: Offset(
                          0,
                          -MediaQuery.of(context).size.height *
                              (1 - slideValue)),
                      child: Opacity(
                        opacity: animationController.value,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.darkBackground,
                                      AppColors.darkSurface,
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.offWhite,
                                      Colors.white,
                                    ],
                                  ),
                          ),
                          child: SafeArea(
                            child: Column(
                              children: [
                                // Header with close button
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 20, 20, 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.limeGreen
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/icons/scroll.svg',
                                          height: 24,
                                          width: 24,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.navyBlue,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Streak',
                                              style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : AppColors.navyBlue,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Keep the momentum going!',
                                              style: TextStyle(
                                                color: isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black54,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Close button
                                      GestureDetector(
                                        onTap: () {
                                          animationController
                                              .reverse()
                                              .then((_) => onClose());
                                          HapticFeedback.lightImpact();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? Colors.white.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 20,
                                            color: isDarkMode
                                                ? Colors.white70
                                                : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Scrollable Content
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Current Streak Display
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(32),
                                          decoration: BoxDecoration(
                                            color: AppColors.limeGreen
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: AppColors.limeGreen
                                                  .withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.limeGreen
                                                      .withOpacity(0.2),
                                                  border: Border.all(
                                                    color: AppColors.limeGreen,
                                                    width: 3,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '$currentStreak',
                                                    style: const TextStyle(
                                                      color: AppColors.navyBlue,
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Current Streak',
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : AppColors.navyBlue,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // if (currentStreak > 0) ...[
                                              //   Text(
                                              //     currentStreak == 1
                                              //         ? '1 day in a row! 🔥'
                                              //         : '$currentStreak days in a row! 🔥',
                                              //     style: const TextStyle(
                                              //       color: AppColors.navyBlue,
                                              //       fontSize: 16,
                                              //       fontWeight: FontWeight.w600,
                                              //     ),
                                              //   ),
                                              // ] else ...[
                                              //   Text(
                                              //     'Start your streak today!',
                                              //     style: TextStyle(
                                              //       color: isDarkMode
                                              //           ? Colors.white70
                                              //           : Colors.black54,
                                              //       fontSize: 16,
                                              //     ),
                                              //   ),
                                              // ],
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        // Calendar Section
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: isDarkMode
                                                ? Colors.white.withOpacity(0.05)
                                                : Colors.grey.withOpacity(0.05),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isDarkMode
                                                  ? Colors.white
                                                      .withOpacity(0.1)
                                                  : Colors.grey
                                                      .withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Streak Calendar',
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : AppColors.navyBlue,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Track your learning consistency',
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              _StreakCalendar(
                                                currentStreak: currentStreak,
                                                isDarkMode: isDarkMode,
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // Stats Section
                                        // Text(
                                        //   'Statistics',
                                        //   style: TextStyle(
                                        //     color: isDarkMode
                                        //         ? Colors.white
                                        //         : AppColors.navyBlue,
                                        //     fontSize: 20,
                                        //     fontWeight: FontWeight.bold,
                                        //   ),
                                        // ),
                                        // const SizedBox(height: 16),
                                        // Row(
                                        //   children: [
                                        //     Expanded(
                                        //       child: _StatCard(
                                        //         title: 'Best Streak',
                                        //         value: '$maxStreak',
                                        //         subtitle: 'days',
                                        //         icon: Icons.emoji_events,
                                        //         color: Colors.orange,
                                        //         isDarkMode: isDarkMode,
                                        //       ),
                                        //     ),
                                        //     const SizedBox(width: 16),
                                        //     Expanded(
                                        //       child: _StatCard(
                                        //         title: 'Quizzes',
                                        //         value: '$completedQuizzes',
                                        //         subtitle: 'completed',
                                        //         icon: Icons.quiz,
                                        //         color: Colors.blue,
                                        //         isDarkMode: isDarkMode,
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),

                                        // const SizedBox(height: 24),

                                        // Motivation Section
                                        // Container(
                                        //   width: double.infinity,
                                        //   padding: const EdgeInsets.all(20),
                                        //   decoration: BoxDecoration(
                                        //     color: isDarkMode
                                        //         ? Colors.white.withOpacity(0.05)
                                        //         : Colors.grey.withOpacity(0.05),
                                        //     borderRadius:
                                        //         BorderRadius.circular(16),
                                        //   ),
                                        //   child: Column(
                                        //     children: [
                                        //       Icon(
                                        //         Icons.lightbulb,
                                        //         color: AppColors.limeGreen,
                                        //         size: 32,
                                        //       ),
                                        //       const SizedBox(height: 12),
                                        //       Text(
                                        //         'Daily Motivation',
                                        //         style: TextStyle(
                                        //           color: isDarkMode
                                        //               ? Colors.white
                                        //               : AppColors.navyBlue,
                                        //           fontSize: 18,
                                        //           fontWeight: FontWeight.bold,
                                        //         ),
                                        //       ),
                                        //       const SizedBox(height: 8),
                                        //       Text(
                                        //         _getMotivationMessage(
                                        //             currentStreak),
                                        //         style: TextStyle(
                                        //           color: isDarkMode
                                        //               ? Colors.white70
                                        //               : Colors.black54,
                                        //           fontSize: 15,
                                        //           fontStyle: FontStyle.italic,
                                        //           height: 1.5,
                                        //         ),
                                        //         textAlign: TextAlign.center,
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),

                                        const SizedBox(height: 40),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading streak data')),
    );
  }

  String _getMotivationMessage(int streak) {
    if (streak == 0) {
      return "Every expert was once a beginner. Start your learning journey today and build the habit that will transform your life!";
    } else if (streak == 1) {
      return "Great start! The first step is always the hardest. You've proven you can do it - now keep the momentum going!";
    } else if (streak < 7) {
      return "You're building a fantastic habit! Consistency is the key to success. Each day you learn is a step closer to mastery.";
    } else if (streak < 30) {
      return "You're on fire! 🔥 Your dedication is truly inspiring. This consistent effort will compound into extraordinary results!";
    } else if (streak < 100) {
      return "Incredible dedication! You're becoming unstoppable! 🚀 Your commitment to learning is setting you apart from the rest.";
    } else {
      return "You're a learning legend! 🏆 Your extraordinary commitment has created a powerful habit that will serve you for life!";
    }
  }
}

// Enhanced Streak Calendar Widget - Now with real calendar functionality
class _StreakCalendar extends HookWidget {
  final int currentStreak;
  final bool isDarkMode;

  const _StreakCalendar({
    required this.currentStreak,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // State for current viewing month/year
    final currentMonth = useState(DateTime(now.year, now.month));

    // Get the first day of the month and calculate calendar layout
    final firstDayOfMonth =
        DateTime(currentMonth.value.year, currentMonth.value.month, 1);
    final lastDayOfMonth =
        DateTime(currentMonth.value.year, currentMonth.value.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final daysInMonth = lastDayOfMonth.day;

    // Calculate previous month days to show
    final prevMonth =
        DateTime(currentMonth.value.year, currentMonth.value.month - 1);
    final lastDayOfPrevMonth =
        DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

    // Get month name
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    void goToPreviousMonth() {
      currentMonth.value =
          DateTime(currentMonth.value.year, currentMonth.value.month - 1);
    }

    void goToNextMonth() {
      currentMonth.value =
          DateTime(currentMonth.value.year, currentMonth.value.month + 1);
    }

    void goToToday() {
      currentMonth.value = DateTime(now.year, now.month);
    }

    // Function to check if a date is a streak day
    bool isStreakDay(DateTime date) {
      final daysDifference = today.difference(date).inDays;
      return daysDifference >= 0 && daysDifference < currentStreak;
    }

    return Column(
      children: [
        // Calendar Header with navigation
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              // Previous month button
              GestureDetector(
                onTap: goToPreviousMonth,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    size: 20,
                  ),
                ),
              ),

              // Month and Year display
              Expanded(
                child: GestureDetector(
                  onTap: goToToday,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Text(
                          monthNames[currentMonth.value.month - 1],
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${currentMonth.value.year}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Next month button
              GestureDetector(
                onTap: goToNextMonth,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Week days header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Container(
                      width: 40,
                      height: 30,
                      alignment: Alignment.center,
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),

        // Calendar Grid
        Container(
          child: Column(
            children: List.generate(6, (weekIndex) {
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (dayIndex) {
                    final cellIndex = weekIndex * 7 + dayIndex;
                    final totalCellsBeforeMonth = firstDayOfWeek;

                    late DateTime cellDate;
                    late bool isCurrentMonth;
                    late bool isToday;
                    late bool isStreakDayForDate;
                    late int displayDay;

                    if (cellIndex < totalCellsBeforeMonth) {
                      // Previous month days
                      displayDay = lastDayOfPrevMonth -
                          (totalCellsBeforeMonth - cellIndex - 1);
                      cellDate =
                          DateTime(prevMonth.year, prevMonth.month, displayDay);
                      isCurrentMonth = false;
                    } else if (cellIndex <
                        totalCellsBeforeMonth + daysInMonth) {
                      // Current month days
                      displayDay = cellIndex - totalCellsBeforeMonth + 1;
                      cellDate = DateTime(currentMonth.value.year,
                          currentMonth.value.month, displayDay);
                      isCurrentMonth = true;
                    } else {
                      // Next month days
                      displayDay =
                          cellIndex - totalCellsBeforeMonth - daysInMonth + 1;
                      final nextMonth = DateTime(currentMonth.value.year,
                          currentMonth.value.month + 1);
                      cellDate =
                          DateTime(nextMonth.year, nextMonth.month, displayDay);
                      isCurrentMonth = false;
                    }

                    isToday = cellDate.year == today.year &&
                        cellDate.month == today.month &&
                        cellDate.day == today.day;

                    isStreakDayForDate = isStreakDay(cellDate);

                    // Hide cells that are too far in the future/past for cleaner look
                    if (weekIndex >= 5 && !isCurrentMonth) {
                      return const SizedBox(width: 40, height: 40);
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isStreakDayForDate && isCurrentMonth
                            ? isToday
                                ? AppColors.limeGreen
                                : AppColors.limeGreen.withOpacity(0.8)
                            : isToday
                                ? AppColors.limeGreen.withOpacity(0.3)
                                : Colors.transparent,
                        border: isToday
                            ? Border.all(
                                color: AppColors.limeGreen,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$displayDay',
                          style: TextStyle(
                            color: !isCurrentMonth
                                ? (isDarkMode ? Colors.white30 : Colors.black26)
                                : isStreakDayForDate
                                    ? Colors.white
                                    : isToday
                                        ? AppColors.limeGreen
                                        : isDarkMode
                                            ? Colors.white70
                                            : Colors.black87,
                            fontSize: 14,
                            fontWeight: isToday || isStreakDayForDate
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),

        // const SizedBox(height: 16),

        // Today button and legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Today button
            GestureDetector(
              onTap: goToToday,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.limeGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.limeGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.today,
                      color: AppColors.navyBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Today',
                      style: TextStyle(
                        color: AppColors.navyBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Legend
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.limeGreen,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Streak day',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Streak info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.limeGreen.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.limeGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            currentStreak > 0
                ? 'You\'re on a $currentStreak day streak! Keep it up! 🔥'
                : 'Start your learning streak today! 🚀',
            style: TextStyle(
              color: AppColors.navyBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
