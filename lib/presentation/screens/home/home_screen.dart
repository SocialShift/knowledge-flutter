import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:knowledge/data/models/history_item.dart';
import 'package:knowledge/presentation/widgets/history_card.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: _HeaderSection(),
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
      title: 'Ancient Greece',
      subtitle: 'The birthplace of democracy and philosophy',
      imageUrl: 'https://images.unsplash.com/photo-1608730973360-cc2b8a0a9447',
    ),
    HistoryItem(
      title: 'Roman Empire',
      subtitle: 'The rise and fall of an ancient superpower',
      imageUrl: 'https://images.unsplash.com/photo-1552832230-c0197dd311b5',
    ),
    HistoryItem(
      title: 'Medieval Europe',
      subtitle: 'The age of knights and castles',
      imageUrl: 'https://images.unsplash.com/photo-1599946347371-68eb71b16afc',
    ),
    HistoryItem(
      title: 'Renaissance',
      subtitle: 'A rebirth of art and learning',
      imageUrl: 'https://images.unsplash.com/photo-1591279304068-d8ee78519c2e',
    ),
  ];
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const UserAvatar(size: 40),
              const SizedBox(width: 12),
              Text(
                'Rafael Williams',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ).animate().fadeIn().slideX(),
          const SizedBox(height: 24),
          _SearchBar().animate().fadeIn().slideY(),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
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
          Icon(Icons.search, color: Colors.grey[800]),
          const SizedBox(width: 8),
          Text(
            'Search History',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return HistoryCard(
            item: items[index],
            onTap: () {
              // Handle tap
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
