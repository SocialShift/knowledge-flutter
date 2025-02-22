import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ElearningScreen extends StatefulWidget {
  const ElearningScreen({super.key});

  @override
  State<ElearningScreen> createState() => _ElearningScreenState();
}

class _ElearningScreenState extends State<ElearningScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _categories = [
    'All',
    'History',
    'Culture',
    'Politics',
    'Science',
    'Art',
  ];
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Search Bar and Categories
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFF1A1A1A),
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 60),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search stories...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 600)),
                  const SizedBox(height: 16),
                  // Categories
                  SizedBox(
                    height: 35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(category),
                            labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[400],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            backgroundColor: Colors.grey[900],
                            selectedColor: Colors.blue,
                            onSelected: (selected) {
                              setState(() => _selectedCategory = category);
                            },
                          ),
                        );
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 800)),
                ],
              ),
            ),
          ),

          // Stories Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildStoryCard(index)
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 600),
                      delay: Duration(milliseconds: 100 * index),
                    )
                    .slideY(begin: 0.2, end: 0),
                childCount: 10, // Replace with actual story count
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(int index) {
    return GestureDetector(
      onTap: () => context.push('/story/$index'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/200/300?random=$index',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Story Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Story Title $index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Brief description of the story...',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '5 min read',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
