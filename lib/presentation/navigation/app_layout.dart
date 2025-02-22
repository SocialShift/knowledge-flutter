import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          color: const Color(0xFF1A1A1A),
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.leaderboard_outlined,
                  selectedIcon: Icons.leaderboard,
                  isSelected: currentIndex == 0,
                  onTap: () => context.go('/leaderboard'),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_filled,
                  isSelected: currentIndex == 1,
                  onTap: () => context.go('/home'),
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  isSelected: currentIndex == 2,
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? Colors.white : Colors.white60,
                size: isSelected ? 28 : 26,
              ),
            ),
            if (showProfileIndicator && isSelected)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/leaderboard')) return 0;
    if (location.startsWith('/home')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 1; // Default to home
  }
}
