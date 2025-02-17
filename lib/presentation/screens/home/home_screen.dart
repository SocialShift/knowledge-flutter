import 'package:flutter/material.dart';
import 'package:knowledge/presentation/widgets/user_avatar.dart';
import 'package:knowledge/presentation/widgets/search_bar_widget.dart';
import 'package:knowledge/presentation/widgets/timeline_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Top Section with Avatar and Welcome
            Container(
              color: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const UserAvatar(size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, Ann 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'What do you want to study today?',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  SearchBarWidget(
                    onFilterTap: () {},
                    onSearch: (query) {},
                  ),
                ],
              ),
            ),

            // Timeline Grid
            Expanded(
              child: TimelineGrid(
                itemCount: 10,
                nodes: List.generate(
                  10,
                  (index) => TimelineNodeData(
                    year: 1700 + (index * 50),
                    isCompleted: index < 3,
                    isActive: index == 3,
                    title: 'Period ${index + 1}',
                  ),
                ),
                onNodeTap: (index) {
                  // Handle node tap
                  debugPrint('Tapped node at index: $index');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
