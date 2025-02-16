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
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.search, '/home', true),
            _buildNavItem(context, Icons.bookmark_border, '/bookmarks', false),
            _buildNavItem(
                context, Icons.menu_book_outlined, '/elearning', false),
            _buildNavItem(context, Icons.settings_outlined, '/settings', false),
            _buildNavItem(context, Icons.person_outline, '/profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String route, bool isSelected) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF4A4AF4) : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
