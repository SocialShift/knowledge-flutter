import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  isSelected: currentIndex == 1,
                  onTap: () => context.go('/elearning'),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.leaderboard_outlined,
                  selectedIcon: Icons.leaderboard,
                  isSelected: currentIndex == 2,
                  onTap: () => context.go('/leaderboard'),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  isSelected: currentIndex == 3,
                  onTap: () => context.go('/profile'),
                  showProfileIndicator: true,
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
                    color: isSelected ? AppColors.navyBlue : Colors.grey,
                    size: isSelected ? 28 : 26,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.limeGreen,
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
    if (location.startsWith('/leaderboard')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // Default to home
  }
}
