import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/history_item.dart';
import 'package:knowledge/presentation/widgets/history_card.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: _HeaderSection(),
            ),
            const SliverToBoxAdapter(
              child: _FeaturedSection(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Popular in History',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _HistoryGrid(items: _demoItems),
            ),
          ],
        ),
      ),
    );
  }

  static const List<HistoryItem> _demoItems = [
    HistoryItem(
      id: '1',
      title: 'Ancient Greece',
      subtitle: 'The birthplace of democracy and philosophy',
      imageUrl: 'https://images.unsplash.com/photo-1608730973360-cc2b8a0a9447',
      year: 1967,
    ),
    HistoryItem(
      id: '2',
      title: 'Roman Empire',
      subtitle: 'The rise and fall of an ancient superpower',
      imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5',
      year: 1970,
    ),
    HistoryItem(
      id: '3',
      title: 'Medieval Europe',
      subtitle: 'The age of knights and castles',
      imageUrl: 'https://images.unsplash.com/photo-1599946347371-68eb71b16afc',
      year: 1976,
    ),
    HistoryItem(
      id: '4',
      title: 'Renaissance',
      subtitle: 'The rebirth of art and learning',
      imageUrl: 'https://images.unsplash.com/photo-1578925518470-4def7a0f08bb',
      year: 1980,
    ),
  ];
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const UserAvatar(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white),
                onPressed: () {
                  // TODO: Implement notifications
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchBar(),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SearchBarWidget(
        onSearch: (value) {
          // TODO: Implement search functionality
        },
        onFilterTap: () {
          _showFilterBottomSheet(context);
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String _selectedEra = 'All';
  String _selectedRegion = 'All';
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white24,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Stories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    title: 'Historical Era',
                    options: [
                      'All',
                      'Ancient',
                      'Medieval',
                      'Modern',
                      'Contemporary'
                    ],
                    selectedValue: _selectedEra,
                    onChanged: (value) => setState(() => _selectedEra = value),
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'Region',
                    options: [
                      'All',
                      'Europe',
                      'Asia',
                      'Americas',
                      'Africa',
                      'Oceania'
                    ],
                    selectedValue: _selectedRegion,
                    onChanged: (value) =>
                        setState(() => _selectedRegion = value),
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    title: 'Content Type',
                    options: ['All', 'Stories', 'Videos', 'Quizzes'],
                    selectedValue: _selectedType,
                    onChanged: (value) => setState(() => _selectedType = value),
                  ),
                ],
              ),
            ),
          ),
          // Apply Button
          Container(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Apply filters
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5FF3A),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return FilterChip(
              selected: isSelected,
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.9),
              selectedColor: const Color(0xFFB5FF3A),
              checkmarkColor: Colors.black,
              onSelected: (_) => onChanged(option),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/timeline/featured'),
      child: Container(
        height: 200,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: 'timeline_featured',
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1552832230-c0197dd311b5',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Story',
                    style: TextStyle(
                      color: Colors.pink[100],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The Rise of Roman Empire',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1970',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(
          begin: -0.1,
          end: 0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
        );
  }
}

class _HistoryGrid extends StatelessWidget {
  final List<HistoryItem> items;

  const _HistoryGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return HistoryCard(
            item: item,
            onTap: () {
              print('Navigating to timeline: ${item.id}');
              context.push('/timeline/${item.id}');
            },
          )
              .animate(
                delay: Duration(milliseconds: index * 100),
              )
              .slideY(
                begin: 0.2,
                end: 0,
                curve: Curves.easeOutCubic,
                duration: const Duration(milliseconds: 600),
              )
              .fadeIn(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
        },
        childCount: items.length,
      ),
    );
  }
}
