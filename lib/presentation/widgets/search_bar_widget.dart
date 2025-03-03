import 'package:flutter/material.dart';
import 'package:knowledge/core/themes/app_theme.dart';

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
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 8.0),
            child: Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
          ),

          // Text field
          Expanded(
            child: TextField(
              onChanged: onSearch,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search for history topics...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              cursorColor: AppColors.navyBlue,
              cursorWidth: 1.5,
            ),
          ),

          // Divider
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Filter button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.tune,
                  color: AppColors.navyBlue,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
