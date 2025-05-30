import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:go_router/go_router.dart';
// import 'package:knowledge/data/models/game_question.dart';
import 'package:knowledge/data/repositories/profile_repository.dart';
import 'package:knowledge/presentation/screens/games/guess_year_game_screen.dart';
import 'package:knowledge/presentation/screens/games/image_guess_game_screen.dart';
import 'package:knowledge/presentation/screens/games/fill_blanks_game_screen.dart';

// Create a provider to notify when to refresh the games screen
final gamesRefreshProvider = StateProvider<int>((ref) => 0);

// Class to store milestone information
class MilestoneInfo {
  final String title;
  final String gameId;
  final String description;
  final bool isCompleted;
  final double progress;

  MilestoneInfo({
    required this.title,
    required this.gameId,
    required this.description,
    required this.isCompleted,
    required this.progress,
  });

  // Get the appropriate icon based on the game ID
  IconData get icon {
    switch (gameId) {
      case 'guess_year':
        return Icons.hourglass_bottom;
      case 'image_guess':
        return Icons.account_balance;
      case 'fill_blanks':
        return Icons.notes_sharp;
      default:
        return Icons.extension;
    }
  }
}

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;

  final List<GameInfo> _games = [
    GameInfo(
      id: 'guess_year',
      title: 'When',
      description: 'Test your knowledge of historical dates and timelines',
      icon: Icons.hourglass_bottom,
      color: Colors.indigo,
      gameType: 1,
      comingSoon: false,
    ),
    GameInfo(
      id: 'image_guess',
      title: 'Legacy',
      description: 'Identify famous historical figures and landmarks',
      icon: Icons.account_balance,
      color: Colors.purple,
      gameType: 2,
      comingSoon: false,
    ),
    GameInfo(
      id: 'fill_blanks',
      title: 'Fragments',
      description: 'Complete famous quotes and historical texts',
      icon: Icons.notes_sharp,
      color: Colors.teal,
      gameType: 3,
      comingSoon: false,
    ),
  ];

  // List of milestone items to make it dynamic
  final List<MilestoneInfo> _milestones = [
    MilestoneInfo(
      title: "Legacy",
      gameId: "image_guess",
      description: "Complete 5 rounds of Historical Figure game",
      isCompleted: true,
      progress: 1.0,
    ),
    MilestoneInfo(
      title: "When",
      gameId: "guess_year",
      description: "Win 3 consecutive rounds",
      isCompleted: false,
      progress: 0.6,
    ),
    MilestoneInfo(
      title: "Fragments",
      gameId: "fill_blanks",
      description: "Score 500 points in a single round",
      isCompleted: false,
      progress: 0.3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Add listener to update tab icons when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
        // Trigger card animations when switching tabs
        _cardAnimationController.reset();
        _cardAnimationController.forward();
      }
    });

    // Initial refresh when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      _headerAnimationController.forward();
      _cardAnimationController.forward();
    });
  }

  // Method to refresh user profile data
  Future<void> _refreshData() async {
    // Invalidate the user profile provider to fetch fresh data
    ref.invalidate(userProfileProvider);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _navigateToGame(BuildContext context, GameInfo game) {
    if (game.comingSoon) return;

    // Provide tactile feedback
    HapticFeedback.lightImpact();

    // Navigate to the specific game based on ID
    switch (game.id) {
      case 'guess_year':
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => const GuessYearGameScreen(),
            settings: const RouteSettings(name: 'guess_year_game'),
          ),
        )
            .then((_) {
          // Refresh data when returning from the game
          _refreshData();
        });
        break;
      case 'image_guess':
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => const ImageGuessGameScreen(),
            settings: const RouteSettings(name: 'image_guess_game'),
          ),
        )
            .then((_) {
          // Refresh data when returning from the game
          _refreshData();
        });
        break;
      case 'fill_blanks':
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => const FillBlanksGameScreen(),
            settings: const RouteSettings(name: 'fill_blanks_game'),
          ),
        )
            .then((_) {
          // Refresh data when returning from the game
          _refreshData();
        });
        break;
      default:
        // If no match, do nothing
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the user profile to get points
    final userProfileAsync = ref.watch(userProfileProvider);

    // Get theme colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final cardColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppColors.navyBlue;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

    // Listen to the refresh provider to trigger refreshes
    ref.listen(gamesRefreshProvider, (previous, current) {
      if (previous != current) {
        _refreshData();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFe2e8f0),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Tab Bar
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _buildEnhancedTabBar(isDarkMode),
            ),

            // Scrollable Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Games Tab with full screen refresh
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppColors.limeGreen,
                    backgroundColor: cardColor,
                    strokeWidth: 3,
                    child: _buildScrollableGamesContent(userProfileAsync,
                        isDarkMode, textColor, secondaryTextColor),
                  ),

                  // Milestones Tab with full screen refresh
                  RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppColors.limeGreen,
                    backgroundColor: cardColor,
                    strokeWidth: 3,
                    child: _buildScrollableMilestonesContent(
                        isDarkMode, cardColor, textColor, borderColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableGamesContent(AsyncValue userProfileAsync,
      bool isDarkMode, Color textColor, Color secondaryTextColor) {
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Header moved into scrollable content
            _buildEnhancedHeader(userProfileAsync, isDarkMode, textColor),
            const SizedBox(height: 24),

            // Games Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.all(10),
                        //   decoration: BoxDecoration(
                        //     color: AppColors.limeGreen.withOpacity(0.2),
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(
                        //       color: AppColors.limeGreen.withOpacity(0.3),
                        //     ),
                        //   ),
                        //   // child: Icon(
                        //   //   Icons.psychology,
                        //   //   color: AppColors.limeGreen,
                        //   //   size: 20,
                        //   // ),
                        // ),
                        const SizedBox(width: 12),
                        Text(
                          "Educational Games",
                          style: TextStyle(
                            color: AppColors.navyBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ..._games.asMap().entries.map((entry) {
                      final index = entry.key;
                      final game = entry.value;
                      return Transform.translate(
                        offset: Offset(
                          50 * (1 - _cardAnimationController.value),
                          0,
                        ),
                        child: Opacity(
                          opacity: _cardAnimationController.value,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _games.length - 1 ? 0 : 16,
                            ),
                            child: _buildEnhancedGameCard(
                              game,
                              index,
                              isDarkMode,
                              textColor,
                              secondaryTextColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScrollableMilestonesContent(
      bool isDarkMode, Color cardColor, Color textColor, Color borderColor) {
    // Milestone completion metrics
    final totalMilestones = _milestones.length;
    final completedMilestones = _milestones.where((m) => m.isCompleted).length;
    final completionPercentage = (completedMilestones / totalMilestones);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Milestones Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.navyBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.navyBlue,
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events_outlined,
                      color: AppColors.offWhite,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Milestones",
                    style: TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 12,
                  //     vertical: 6,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFF10B981).withOpacity(0.2),
                  //     borderRadius: BorderRadius.circular(12),
                  //     border: Border.all(
                  //       color: const Color(0xFF10B981).withOpacity(0.3),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     "${(completionPercentage * 100).toInt()}% Complete",
                  //     style: TextStyle(
                  //       color: const Color(0xFF10B981),
                  //       fontSize: 12,
                  //       fontWeight: FontWeight.w700,
                  //       letterSpacing: 0.3,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),

              // Enhanced overall progress section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Overall Progress",
                          style: TextStyle(
                            color: AppColors.navyBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "$completedMilestones/$totalMilestones",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.navyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completionPercentage,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dynamic milestone items
              ..._milestones.asMap().entries.map((entry) {
                final index = entry.key;
                final milestone = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildEnhancedMilestoneItem(
                    title: milestone.title,
                    icon: milestone.icon,
                    isCompleted: milestone.isCompleted,
                    progress: milestone.progress,
                    description: milestone.description,
                    isDarkMode: isDarkMode,
                    textColor: textColor,
                    borderColor: borderColor,
                    index: index,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: const Duration(milliseconds: 600));
  }

  Widget _buildEnhancedHeader(
      AsyncValue userProfileAsync, bool isDarkMode, Color textColor) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerAnimationController.value)),
          child: Opacity(
            opacity: _headerAnimationController.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.limeGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reveal",
                              style: TextStyle(
                                color: AppColors.navyBlue,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Challenge your mind",
                              style: TextStyle(
                                color: AppColors.navyBlue.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFe2e8f0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.navyBlue.withOpacity(0.2),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.navyBlue,
                            size: 20,
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showMonetizationDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.limeGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.star_border,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: userProfileAsync.when(
                            data: (profile) {
                              final points = profile.points ?? 0;
                              String level = 'Beginner';
                              Color levelColor = Colors.grey;

                              if (points >= 1000) {
                                level = 'History Master';
                                levelColor = const Color(0xFFFFD700);
                              } else if (points >= 500) {
                                level = 'History Expert';
                                levelColor = const Color(0xFFFF6B6B);
                              } else if (points >= 200) {
                                level = 'History Enthusiast';
                                levelColor = const Color(0xFF9C88FF);
                              } else if (points >= 50) {
                                level = 'History Student';
                                levelColor = const Color(0xFF4ECDC4);
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Game Points: ",
                                        style: TextStyle(
                                          color: AppColors.navyBlue,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.limeGreen,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "$points",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: levelColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        level,
                                        style: TextStyle(
                                          color: AppColors.navyBlue
                                              .withOpacity(0.8),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                            loading: () => Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.limeGreen),
                                ),
                              ),
                            ),
                            error: (error, stack) => Text(
                              "Game Points: 0",
                              style: TextStyle(
                                color: AppColors.navyBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTabBar(bool isDarkMode) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.limeGreen,
            width: 3,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
        labelColor: AppColors.navyBlue,
        unselectedLabelColor: AppColors.navyBlue.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            return states.contains(MaterialState.focused)
                ? null
                : Colors.transparent;
          },
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Text('Games'),
          ),
          Tab(
            child: Text('Milestones'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 400)).scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1.0, 1.0),
        duration: const Duration(milliseconds: 400));
  }

  Widget _buildEnhancedGameCard(GameInfo game, int index, bool isDarkMode,
      Color textColor, Color secondaryTextColor) {
    // Enhanced game-specific color schemes
    final gameColors = _getGameColorScheme(game.id, isDarkMode);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _navigateToGame(context, game);
      },
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFe2e8f0).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gameColors['border']!.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Game Icon Container
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gameColors['gradient']!,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                game.icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),

            // Game Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Title
                  Text(
                    game.title,
                    style: TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Game Description
                  Text(
                    game.description,
                    style: TextStyle(
                      color: AppColors.navyBlue.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Action Button
            // Container(
            //   width: 40,
            //   height: 40,
            //   decoration: BoxDecoration(
            //     color: gameColors['border']!.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Icon(
            //     Icons.arrow_forward_ios,
            //     color: gameColors['border']!,
            //     size: 16,
            //   ),
            // ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 200 * index))
        .fadeIn(duration: const Duration(milliseconds: 700))
        .slideX(
            begin: 0.1, end: 0, duration: const Duration(milliseconds: 500));
  }

  Widget _buildEnhancedMilestoneItem({
    required String title,
    required bool isCompleted,
    required double progress,
    required String description,
    required IconData icon,
    required bool isDarkMode,
    required Color textColor,
    required Color borderColor,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFF10B981).withOpacity(0.1)
            : const Color(0xFFe2e8f0).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withOpacity(0.4)
              : AppColors.navyBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : AppColors.navyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isCompleted
                      ? Colors.white
                      : AppColors.navyBlue.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Completed",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: AppColors.navyBlue.withOpacity(0.7),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.navyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFBBF24))
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isCompleted
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFBBF24))
                        .withOpacity(0.4),
                  ),
                ),
                child: Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 150 * index))
        .fadeIn(duration: const Duration(milliseconds: 600))
        .slideX(
            begin: 0.1, end: 0, duration: const Duration(milliseconds: 500));
  }

  // Helper method to get game-specific color schemes
  Map<String, dynamic> _getGameColorScheme(String gameId, bool isDarkMode) {
    switch (gameId) {
      case 'guess_year':
        return {
          'gradient': isDarkMode
              ? [
                  const Color(0xFF4C1D95),
                  const Color(0xFF3730A3),
                  const Color(0xFF1E1B4B),
                ]
              : [
                  const Color(0xFF8B5CF6),
                  const Color(0xFF7C3AED),
                  const Color(0xFF6D28D9),
                ],
          'border': const Color(0xFF8B5CF6),
          'shadow': const Color(0xFF8B5CF6),
          'textGradient': [
            const Color(0xFF8B5CF6),
            const Color(0xFF7C3AED),
          ],
          'actionGradient': [
            const Color(0xFF8B5CF6).withOpacity(0.8),
            const Color(0xFF7C3AED).withOpacity(0.6),
          ],
        };
      case 'image_guess':
        return {
          'gradient': isDarkMode
              ? [
                  const Color(0xFF7E22CE),
                  const Color(0xFF6B21A8),
                  const Color(0xFF581C87),
                ]
              : [
                  const Color(0xFFA855F7),
                  const Color(0xFF9333EA),
                  const Color(0xFF7E22CE),
                ],
          'border': const Color(0xFFA855F7),
          'shadow': const Color(0xFFA855F7),
          'textGradient': [
            const Color(0xFFA855F7),
            const Color(0xFF9333EA),
          ],
          'actionGradient': [
            const Color(0xFFA855F7).withOpacity(0.8),
            const Color(0xFF9333EA).withOpacity(0.6),
          ],
        };
      case 'fill_blanks':
        return {
          'gradient': isDarkMode
              ? [
                  const Color(0xFF0F766E),
                  const Color(0xFF0D9488),
                  const Color(0xFF134E4A),
                ]
              : [
                  const Color(0xFF14B8A6),
                  const Color(0xFF0D9488),
                  const Color(0xFF0F766E),
                ],
          'border': const Color(0xFF14B8A6),
          'shadow': const Color(0xFF14B8A6),
          'textGradient': [
            const Color(0xFF14B8A6),
            const Color(0xFF0D9488),
          ],
          'actionGradient': [
            const Color(0xFF14B8A6).withOpacity(0.8),
            const Color(0xFF0D9488).withOpacity(0.6),
          ],
        };
      default:
        return {
          'gradient': isDarkMode
              ? [
                  const Color(0xFF374151),
                  const Color(0xFF1F2937),
                ]
              : [
                  const Color(0xFF6B7280),
                  const Color(0xFF4B5563),
                ],
          'border': const Color(0xFF6B7280),
          'shadow': const Color(0xFF6B7280),
          'textGradient': [
            const Color(0xFF6B7280),
            const Color(0xFF4B5563),
          ],
          'actionGradient': [
            const Color(0xFF6B7280).withOpacity(0.8),
            const Color(0xFF4B5563).withOpacity(0.6),
          ],
        };
    }
  }

  void _showMonetizationDialog() {
    // Navigate to the subscription screen instead of showing dialog
    context.push('/subscription');
  }
}

class GameInfo {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int gameType;
  final bool comingSoon;

  GameInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gameType,
    this.comingSoon = false,
  });
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:knowledge/core/themes/app_theme.dart';
// import 'package:go_router/go_router.dart';
// // import 'package:knowledge/data/models/game_question.dart';
// import 'package:knowledge/data/repositories/profile_repository.dart';
// import 'package:knowledge/presentation/screens/games/guess_year_game_screen.dart';
// import 'package:knowledge/presentation/screens/games/image_guess_game_screen.dart';
// import 'package:knowledge/presentation/screens/games/fill_blanks_game_screen.dart';

// // Create a provider to notify when to refresh the games screen
// final gamesRefreshProvider = StateProvider<int>((ref) => 0);

// // Class to store milestone information
// class MilestoneInfo {
//   final String title;
//   final String gameId;
//   final String description;
//   final bool isCompleted;
//   final double progress;

//   MilestoneInfo({
//     required this.title,
//     required this.gameId,
//     required this.description,
//     required this.isCompleted,
//     required this.progress,
//   });

//   // Get the appropriate icon based on the game ID
//   IconData get icon {
//     switch (gameId) {
//       case 'guess_year':
//         return Icons.hourglass_bottom;
//       case 'image_guess':
//         return Icons.account_balance;
//       case 'fill_blanks':
//         return Icons.notes_sharp;
//       default:
//         return Icons.extension;
//     }
//   }
// }

// class GamesScreen extends ConsumerStatefulWidget {
//   const GamesScreen({super.key});

//   @override
//   ConsumerState<GamesScreen> createState() => _GamesScreenState();
// }

// class _GamesScreenState extends ConsumerState<GamesScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final List<GameInfo> _games = [
//     GameInfo(
//       id: 'guess_year',
//       title: 'When',
//       description: 'Test your knowledge of historical dates',
//       icon: Icons.hourglass_bottom,
//       color: Colors.indigo,
//       gameType: 1,
//       comingSoon: false,
//     ),
//     GameInfo(
//       id: 'image_guess',
//       title: 'Legacy',
//       description: 'Guess historical figures from images',
//       icon: Icons.account_balance,
//       color: Colors.purple,
//       gameType: 2,
//       comingSoon: false,
//     ),
//     GameInfo(
//       id: 'fill_blanks',
//       title: 'Fragments',
//       description: 'Complete famous historical quotes',
//       icon: Icons.notes_sharp,
//       color: Colors.teal,
//       gameType: 3,
//       comingSoon: false,
//     ),
//   ];

//   // List of milestone items to make it dynamic
//   final List<MilestoneInfo> _milestones = [
//     MilestoneInfo(
//       title: "Legacy",
//       gameId: "image_guess",
//       description: "Complete 5 rounds of Historical Figure game",
//       isCompleted: true,
//       progress: 1.0,
//     ),
//     MilestoneInfo(
//       title: "When",
//       gameId: "guess_year",
//       description: "Win 3 consecutive rounds",
//       isCompleted: false,
//       progress: 0.6,
//     ),
//     MilestoneInfo(
//       title: "Fragments",
//       gameId: "fill_blanks",
//       description: "Score 500 points in a single round",
//       isCompleted: false,
//       progress: 0.3,
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     // Add listener to update tab icons when tab changes
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) {
//         setState(() {});
//       }
//     });

//     // Initial refresh when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _refreshData();
//     });
//   }

//   // Method to refresh user profile data
//   Future<void> _refreshData() async {
//     // Invalidate the user profile provider to fetch fresh data
//     ref.invalidate(userProfileProvider);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _navigateToGame(BuildContext context, GameInfo game) {
//     if (game.comingSoon) return;

//     // Provide tactile feedback
//     HapticFeedback.lightImpact();

//     // Navigate to the specific game based on ID
//     switch (game.id) {
//       case 'guess_year':
//         Navigator.of(context)
//             .push(
//           MaterialPageRoute(
//             builder: (context) => const GuessYearGameScreen(),
//             settings: const RouteSettings(name: 'guess_year_game'),
//           ),
//         )
//             .then((_) {
//           // Refresh data when returning from the game
//           _refreshData();
//         });
//         break;
//       case 'image_guess':
//         Navigator.of(context)
//             .push(
//           MaterialPageRoute(
//             builder: (context) => const ImageGuessGameScreen(),
//             settings: const RouteSettings(name: 'image_guess_game'),
//           ),
//         )
//             .then((_) {
//           // Refresh data when returning from the game
//           _refreshData();
//         });
//         break;
//       case 'fill_blanks':
//         Navigator.of(context)
//             .push(
//           MaterialPageRoute(
//             builder: (context) => const FillBlanksGameScreen(),
//             settings: const RouteSettings(name: 'fill_blanks_game'),
//           ),
//         )
//             .then((_) {
//           // Refresh data when returning from the game
//           _refreshData();
//         });
//         break;
//       default:
//         // If no match, do nothing
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Watch the user profile to get points
//     final userProfileAsync = ref.watch(userProfileProvider);

//     // Listen to the refresh provider to trigger refreshes
//     ref.listen(gamesRefreshProvider, (previous, current) {
//       if (previous != current) {
//         _refreshData();
//       }
//     });

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.lightPurple,
//               AppColors.navyBlue,
//             ],
//             stops: const [0.0, 0.3],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(userProfileAsync),
//               const SizedBox(height: 20),
//               _buildTabBar(),
//               Expanded(
//                 child: TabBarView(
//                   controller: _tabController,
//                   physics: const BouncingScrollPhysics(),
//                   children: [
//                     // Games Tab with pull-to-refresh
//                     RefreshIndicator(
//                       onRefresh: _refreshData,
//                       color: AppColors.limeGreen,
//                       backgroundColor: Colors.white,
//                       child: _buildGamesTab(),
//                     ),

//                     // Navigation Tab (with dynamic milestones)
//                     _buildNavigationTab(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(AsyncValue userProfileAsync) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.psychology,
//                 color: Colors.white,
//                 size: 32,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 "Reveal",
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.95),
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               // Refresh button
//               // Container(
//               //   margin: const EdgeInsets.only(right: 12),
//               //   decoration: BoxDecoration(
//               //     color: Colors.white.withOpacity(0.2),
//               //     shape: BoxShape.circle,
//               //   ),
//               //   child: IconButton(
//               //     icon: const Icon(
//               //       Icons.refresh,
//               //       color: Colors.white,
//               //     ),
//               //     tooltip: 'Refresh',
//               //     onPressed: () {
//               //       HapticFeedback.lightImpact();
//               //       _refreshData();
//               //     },
//               //   ),
//               // ),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.lightbulb_outline,
//                     color: AppColors.limeGreen,
//                   ),
//                   onPressed: () {
//                     // Show monetization coming soon message
//                     _showMonetizationDialog();
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: AppColors.limeGreen.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: AppColors.limeGreen.withOpacity(0.5),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.star_border,
//                   color: AppColors.limeGreen,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 12),
//                 userProfileAsync.when(
//                   data: (profile) {
//                     final points = profile.points ?? 0;
//                     String level = 'Beginner';

//                     // Determine level based on points
//                     if (points >= 1000) {
//                       level = 'History Master';
//                     } else if (points >= 500) {
//                       level = 'History Expert';
//                     } else if (points >= 200) {
//                       level = 'History Enthusiast';
//                     } else if (points >= 50) {
//                       level = 'History Student';
//                     }

//                     return Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Game Points: $points",
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.95),
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             level,
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.8),
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                   loading: () => const Expanded(
//                     child: Center(
//                       child: SizedBox(
//                         height: 16,
//                         width: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       ),
//                     ),
//                   ),
//                   error: (error, stack) => Expanded(
//                     child: Text(
//                       "Game Points: 0",
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.95),
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ).animate().fadeIn().slideY(begin: -0.1, end: 0);
//   }

//   Widget _buildTabBar() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       height: 54,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(27),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.2),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             spreadRadius: 0,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(3),
//         child: TabBar(
//           controller: _tabController,
//           indicator: BoxDecoration(
//             borderRadius: BorderRadius.circular(24),
//             color: AppColors.limeGreen,
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.limeGreen.withOpacity(0.3),
//                 blurRadius: 0,
//                 spreadRadius: 0,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           labelColor: AppColors.navyBlue,
//           unselectedLabelColor: Colors.white,
//           labelStyle: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             fontWeight: FontWeight.w500,
//             fontSize: 15,
//           ),
//           splashFactory: NoSplash.splashFactory,
//           overlayColor: MaterialStateProperty.resolveWith<Color?>(
//             (Set<MaterialState> states) {
//               return states.contains(MaterialState.focused)
//                   ? null
//                   : Colors.transparent;
//             },
//           ),
//           dividerColor: Colors.transparent,
//           tabs: [
//             Tab(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Icon(
//                   //   Icons.psychology,
//                   //   size: 18,
//                   //   color: _tabController.index == 0
//                   //       ? AppColors.navyBlue
//                   //       : Colors.white,
//                   // ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Games',
//                     style: TextStyle(
//                       color: _tabController.index == 0
//                           ? AppColors.navyBlue
//                           : Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Tab(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Icon(
//                   //   Icons.psychology,
//                   //   size: 18,
//                   //   color: _tabController.index == 1
//                   //       ? AppColors.navyBlue
//                   //       : Colors.white,
//                   // ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Milestones',
//                     style: TextStyle(
//                       color: _tabController.index == 1
//                           ? AppColors.navyBlue
//                           : Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: const Duration(milliseconds: 200));
//   }

//   Widget _buildGamesTab() {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       physics:
//           const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh
//       children: [
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 spreadRadius: 0,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.only(left: 8, bottom: 16),
//                   child: Text(
//                     "Educational Games",
//                     style: TextStyle(
//                       color: AppColors.navyBlue,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 ..._games
//                     .map((game) => Padding(
//                           padding: const EdgeInsets.only(bottom: 16),
//                           child: _buildGameCard(game),
//                         ))
//                     .toList(),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNavigationTab() {
//     // Milestone completion metrics
//     final totalMilestones = _milestones.length;
//     final completedMilestones = _milestones.where((m) => m.isCompleted).length;
//     final completionPercentage = (completedMilestones / totalMilestones);

//     // Milestones tab content with scrolling to avoid overflow
//     return RefreshIndicator(
//       onRefresh: _refreshData,
//       color: AppColors.limeGreen,
//       backgroundColor: Colors.white,
//       strokeWidth: 2.5,
//       displacement: 40,
//       child: ListView(
//         padding: const EdgeInsets.all(16),
//         physics: const AlwaysScrollableScrollPhysics(),
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   spreadRadius: 0,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Milestones",
//                     style: TextStyle(
//                       color: AppColors.navyBlue,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Dynamic milestone items
//                   ..._milestones.map((milestone) {
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: _buildMilestoneItem(
//                         title: milestone.title,
//                         icon: milestone.icon,
//                         isCompleted: milestone.isCompleted,
//                         progress: milestone.progress,
//                         description: milestone.description,
//                       ),
//                     );
//                   }).toList(),

//                   const SizedBox(height: 8),
//                   Text(
//                     "Milestones Completed: $completedMilestones/$totalMilestones",
//                     style: const TextStyle(
//                       color: AppColors.navyBlue,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   LinearProgressIndicator(
//                     value: completionPercentage,
//                     backgroundColor: Colors.grey.shade200,
//                     valueColor: const AlwaysStoppedAnimation<Color>(
//                         AppColors.limeGreen),
//                     borderRadius: BorderRadius.circular(10),
//                     minHeight: 8,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ).animate().fadeIn(delay: const Duration(milliseconds: 300));
//   }

//   Widget _buildMilestoneItem({
//     required String title,
//     required bool isCompleted,
//     required double progress,
//     required String description,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color:
//             isCompleted ? AppColors.limeGreen.withOpacity(0.05) : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isCompleted
//               ? AppColors.limeGreen.withOpacity(0.3)
//               : Colors.grey.shade200,
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.02),
//             blurRadius: 3,
//             spreadRadius: 0,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     // Icon based on game type
//                     Icon(
//                       icon,
//                       size: 16,
//                       color: isCompleted ? AppColors.limeGreen : Colors.grey,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       title,
//                       style: TextStyle(
//                         color: AppColors.navyBlue,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     if (isCompleted)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: AppColors.limeGreen,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Text(
//                           "Completed",
//                           style: TextStyle(
//                             color: AppColors.navyBlue,
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   description,
//                   style: TextStyle(
//                     color: Colors.grey.shade600,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Stack(
//                   children: [
//                     // Background
//                     Container(
//                       height: 6,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     // Progress
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 800),
//                       curve: Curves.easeInOut,
//                       height: 6,
//                       width: MediaQuery.of(context).size.width * 0.5 * progress,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.centerLeft,
//                           end: Alignment.centerRight,
//                           colors: isCompleted
//                               ? [
//                                   AppColors.limeGreen,
//                                   AppColors.limeGreen.withBlue(180)
//                                 ]
//                               : [Colors.amber, Colors.orange],
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                         boxShadow: [
//                           BoxShadow(
//                             color: isCompleted
//                                 ? AppColors.limeGreen.withOpacity(0.0)
//                                 : Colors.amber.withOpacity(0.3),
//                             blurRadius: 4,
//                             spreadRadius: 0,
//                             offset: const Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       "${(progress * 100).toInt()}%",
//                       style: TextStyle(
//                         color: isCompleted ? AppColors.limeGreen : Colors.amber,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Container(
//             width: 28,
//             height: 28,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: isCompleted ? AppColors.limeGreen : Colors.grey.shade300,
//                 width: 2,
//               ),
//               color: isCompleted
//                   ? AppColors.limeGreen.withOpacity(0.1)
//                   : Colors.transparent,
//               boxShadow: isCompleted
//                   ? [
//                       BoxShadow(
//                         color: AppColors.limeGreen.withOpacity(0.2),
//                         blurRadius: 4,
//                         spreadRadius: 0,
//                         offset: const Offset(0, 1),
//                       ),
//                     ]
//                   : null,
//             ),
//             child: isCompleted
//                 ? const Icon(Icons.check, color: AppColors.limeGreen, size: 16)
//                 : null,
//           ),
//         ],
//       ),
//     ).animate().fadeIn(duration: const Duration(milliseconds: 500)).slideX(
//         begin: 0.05, end: 0, duration: const Duration(milliseconds: 300));
//   }

//   Widget _buildGameCard(GameInfo game) {
//     return GestureDetector(
//       onTap: () => _navigateToGame(context, game),
//       child: Container(
//         height: 100,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: game.color.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: game.color.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 game.icon,
//                 color: game.color,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     game.title,
//                     style: const TextStyle(
//                       color: AppColors.navyBlue,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     game.description,
//                     style: TextStyle(
//                       color: Colors.grey.shade700,
//                       fontSize: 12,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showMonetizationDialog() {
//     // Navigate to the subscription screen instead of showing dialog
//     context.push('/subscription');
//   }
// }

// class GameInfo {
//   final String id;
//   final String title;
//   final String description;
//   final IconData icon;
//   final Color color;
//   final int gameType;
//   final bool comingSoon;

//   GameInfo({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.color,
//     required this.gameType,
//     this.comingSoon = false,
//   });
// }
