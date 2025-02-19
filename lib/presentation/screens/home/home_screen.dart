import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/history_item.dart';
import 'package:knowledge/presentation/widgets/history_card.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search history...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
        ],
      ),
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
