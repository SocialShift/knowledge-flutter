import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSearch;

  const SearchBarWidget({
    super.key,
    required this.onFilterTap,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onSearch,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFB5FF3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.filter_list, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }
}
