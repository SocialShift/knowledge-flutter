import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';
// import 'package:go_router/go_router.dart';
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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<GameInfo> _games = [
    GameInfo(
      id: 'guess_year',
      title: 'When',
      description: 'Test your knowledge of historical dates',
      icon: Icons.hourglass_bottom,
      color: Colors.indigo,
      gameType: 1,
      comingSoon: false,
    ),
    GameInfo(
      id: 'image_guess',
      title: 'Legacy',
      description: 'Guess historical figures from images',
      icon: Icons.account_balance,
      color: Colors.purple,
      gameType: 2,
      comingSoon: false,
    ),
    GameInfo(
      id: 'fill_blanks',
      title: 'Fragments',
      description: 'Complete famous historical quotes',
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
    // Add listener to update tab icons when tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Initial refresh when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
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

    // Listen to the refresh provider to trigger refreshes
    ref.listen(gamesRefreshProvider, (previous, current) {
      if (previous != current) {
        _refreshData();
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightPurple,
              AppColors.navyBlue,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userProfileAsync),
              const SizedBox(height: 20),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Games Tab with pull-to-refresh
                    RefreshIndicator(
                      onRefresh: _refreshData,
                      color: AppColors.limeGreen,
                      backgroundColor: Colors.white,
                      child: _buildGamesTab(),
                    ),

                    // Navigation Tab (with dynamic milestones)
                    _buildNavigationTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AsyncValue userProfileAsync) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                "Reveal",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Refresh button
              // Container(
              //   margin: const EdgeInsets.only(right: 12),
              //   decoration: BoxDecoration(
              //     color: Colors.white.withOpacity(0.2),
              //     shape: BoxShape.circle,
              //   ),
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.refresh,
              //       color: Colors.white,
              //     ),
              //     tooltip: 'Refresh',
              //     onPressed: () {
              //       HapticFeedback.lightImpact();
              //       _refreshData();
              //     },
              //   ),
              // ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.emoji_events_outlined,
                    color: AppColors.limeGreen,
                  ),
                  onPressed: () {
                    // Show achievements
                    _showAchievementsDialog();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.limeGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.limeGreen.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_border,
                  color: AppColors.limeGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                userProfileAsync.when(
                  data: (profile) {
                    final points = profile.points ?? 0;
                    String level = 'Beginner';

                    // Determine level based on points
                    if (points >= 1000) {
                      level = 'History Master';
                    } else if (points >= 500) {
                      level = 'History Expert';
                    } else if (points >= 200) {
                      level = 'History Enthusiast';
                    } else if (points >= 50) {
                      level = 'History Student';
                    }

                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Game Points: $points",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Expanded(
                    child: Center(
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                  error: (error, stack) => Expanded(
                    child: Text(
                      "Game Points: 0",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.limeGreen,
            boxShadow: [
              BoxShadow(
                color: AppColors.limeGreen.withOpacity(0.3),
                blurRadius: 0,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          labelColor: AppColors.navyBlue,
          unselectedLabelColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.psychology,
                  //   size: 18,
                  //   color: _tabController.index == 0
                  //       ? AppColors.navyBlue
                  //       : Colors.white,
                  // ),
                  const SizedBox(width: 8),
                  Text(
                    'Games',
                    style: TextStyle(
                      color: _tabController.index == 0
                          ? AppColors.navyBlue
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.psychology,
                  //   size: 18,
                  //   color: _tabController.index == 1
                  //       ? AppColors.navyBlue
                  //       : Colors.white,
                  // ),
                  const SizedBox(width: 8),
                  Text(
                    'Milestones',
                    style: TextStyle(
                      color: _tabController.index == 1
                          ? AppColors.navyBlue
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 200));
  }

  Widget _buildGamesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics:
          const AlwaysScrollableScrollPhysics(), // Important for pull-to-refresh
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 16),
                  child: Text(
                    "Educational Games",
                    style: TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ..._games
                    .map((game) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildGameCard(game),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationTab() {
    // Milestone completion metrics
    final totalMilestones = _milestones.length;
    final completedMilestones = _milestones.where((m) => m.isCompleted).length;
    final completionPercentage = (completedMilestones / totalMilestones);

    // Milestones tab content with scrolling to avoid overflow
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Milestones",
                  style: TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Dynamic milestone items
                ..._milestones.map((milestone) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMilestoneItem(
                      title: milestone.title,
                      icon: milestone.icon,
                      isCompleted: milestone.isCompleted,
                      progress: milestone.progress,
                      description: milestone.description,
                    ),
                  );
                }).toList(),

                const SizedBox(height: 8),
                Text(
                  "Milestones Completed: $completedMilestones/$totalMilestones",
                  style: const TextStyle(
                    color: AppColors.navyBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completionPercentage,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: const Duration(milliseconds: 300));
  }

  Widget _buildMilestoneItem({
    required String title,
    required bool isCompleted,
    required double progress,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCompleted ? AppColors.limeGreen.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? AppColors.limeGreen.withOpacity(0.3)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 3,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon based on game type
                    Icon(
                      icon,
                      size: 16,
                      color: isCompleted ? AppColors.limeGreen : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.navyBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.limeGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Completed",
                          style: TextStyle(
                            color: AppColors.navyBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    // Background
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Progress
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      height: 6,
                      width: MediaQuery.of(context).size.width * 0.5 * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: isCompleted
                              ? [
                                  AppColors.limeGreen,
                                  AppColors.limeGreen.withBlue(180)
                                ]
                              : [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: isCompleted
                                ? AppColors.limeGreen.withOpacity(0.0)
                                : Colors.amber.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(
                        color: isCompleted ? AppColors.limeGreen : Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppColors.limeGreen : Colors.grey.shade300,
                width: 2,
              ),
              color: isCompleted
                  ? AppColors.limeGreen.withOpacity(0.1)
                  : Colors.transparent,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: AppColors.limeGreen.withOpacity(0.2),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.limeGreen, size: 16)
                : null,
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 500)).slideX(
        begin: 0.05, end: 0, duration: const Duration(milliseconds: 300));
  }

  Widget _buildGameCard(GameInfo game) {
    return GestureDetector(
      onTap: () => _navigateToGame(context, game),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: game.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: game.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                game.icon,
                color: game.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    game.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.limeGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppColors.limeGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Achievements",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyBlue,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Unlock rewards by playing games",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "2/12 Achievements Unlocked",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyBlue,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "16%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.limeGreen,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 2 / 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.limeGreen),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),
                const SizedBox(height: 8),

                // Achievement items
                _buildAchievementItem(
                  title: "History Novice",
                  description: "Complete your first game",
                  isUnlocked: true,
                  xp: 100,
                ),
                const SizedBox(height: 12),
                _buildAchievementItem(
                  title: "Perfect Score",
                  description: "Get 100% correct answers in any game",
                  isUnlocked: true,
                  xp: 250,
                ),
                const SizedBox(height: 12),
                _buildAchievementItem(
                  title: "Streak Master",
                  description: "Win 5 games in a row",
                  isUnlocked: false,
                  xp: 500,
                ),
                const SizedBox(height: 12),
                _buildAchievementItem(
                  title: "History Expert",
                  description: "Complete all Historical Figure games",
                  isUnlocked: false,
                  xp: 750,
                ),

                const SizedBox(height: 24),

                // Bottom buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                              color: AppColors.navyBlue.withOpacity(0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Close",
                          style: TextStyle(
                            color: AppColors.navyBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.limeGreen,
                          foregroundColor: AppColors.navyBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "View All",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String description,
    required bool isUnlocked,
    required int xp,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.limeGreen.withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? AppColors.limeGreen.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.limeGreen.withOpacity(0.2)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock_outline,
              color: isUnlocked ? AppColors.limeGreen : Colors.grey.shade500,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        isUnlocked ? AppColors.navyBlue : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.limeGreen : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "+$xp XP",
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
