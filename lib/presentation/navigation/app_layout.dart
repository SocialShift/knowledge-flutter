import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/presentation/widgets/email_verification_guard.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    // Get theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.white;
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.2)
        : Colors.black.withOpacity(0.05);
    final indicatorColor = AppColors.limeGreen;
    final selectedIconColor =
        isDarkMode ? AppColors.limeGreen : AppColors.navyBlue;
    final unselectedIconColor = isDarkMode ? Colors.grey.shade400 : Colors.grey;

    return Scaffold(
      body: EmailVerificationGuard(child: child),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_filled,
                  isSelected: currentIndex == 0,
                  onTap: () => context.go('/home'),
                  selectedIconColor: selectedIconColor,
                  unselectedIconColor: unselectedIconColor,
                  indicatorColor: indicatorColor,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  isSelected: currentIndex == 1,
                  onTap: () => context.go('/elearning'),
                  selectedIconColor: selectedIconColor,
                  unselectedIconColor: unselectedIconColor,
                  indicatorColor: indicatorColor,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.psychology_outlined,
                  selectedIcon: Icons.psychology,
                  isSelected: currentIndex == 2,
                  onTap: () => context.go('/games'),
                  selectedIconColor: selectedIconColor,
                  unselectedIconColor: unselectedIconColor,
                  indicatorColor: indicatorColor,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.emoji_events_outlined,
                  selectedIcon: Icons.emoji_events,
                  isSelected: currentIndex == 3,
                  onTap: () => context.go('/leaderboard'),
                  selectedIconColor: selectedIconColor,
                  unselectedIconColor: unselectedIconColor,
                  indicatorColor: indicatorColor,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  isSelected: currentIndex == 4,
                  onTap: () => context.go('/profile'),
                  showProfileIndicator: true,
                  selectedIconColor: selectedIconColor,
                  unselectedIconColor: unselectedIconColor,
                  indicatorColor: indicatorColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required VoidCallback onTap,
    bool showProfileIndicator = false,
    required Color selectedIconColor,
    required Color unselectedIconColor,
    required Color indicatorColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? selectedIconColor : unselectedIconColor,
                    size: isSelected ? 28 : 26,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/elearning')) return 1;
    if (location.startsWith('/games')) return 2;
    if (location.startsWith('/leaderboard')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // Default to home
  }
}
