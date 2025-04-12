import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/providers/filter_provider.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSearch;

  const SearchBarWidget({
    super.key,
    required this.onFilterTap,
    required this.onSearch,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with the current search query from the filter state
    final currentQuery = ref.read(filterNotifierProvider).searchQuery;
    _controller.text = currentQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              controller: _controller,
              onChanged: (value) {
                setState(() {}); // Rebuild to show/hide clear button
                widget.onSearch(value);
              },
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
                // Add clear button when text is entered
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.clear,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                          });
                          widget.onSearch('');
                        },
                      )
                    : null,
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
              onTap: widget.onFilterTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Consumer(
                  builder: (context, ref, child) {
                    final filterState = ref.watch(filterNotifierProvider);
                    final hasActiveFilters = filterState.hasActiveFilters;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.tune,
                          color: AppColors.navyBlue,
                          size: 20,
                        ),
                        if (hasActiveFilters)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              height: 8,
                              width: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.limeGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
