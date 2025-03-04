import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:knowledge/core/themes/app_theme.dart';

class StoryDetailScreen extends HookConsumerWidget {
  final String storyId;

  const StoryDetailScreen({
    super.key,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = _demoStory;
    final isVideo = story.mediaType == 'video';
    final size = MediaQuery.of(context).size;
    final pageController = PageController();
    final currentPage = ValueNotifier<int>(0);

    return Scaffold(
      backgroundColor: AppColors.navyBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar with back button and audio button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  // Audio Button
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.headphones,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  currentPage.value = index;
                },
                children: [
                  // Content Pages
                  for (int i = 0; i < 5; i++)
                    _ContentPage(
                      story: story,
                      isVideo: isVideo,
                      pageIndex: i,
                    ),
                ],
              ),
            ),

            // Page Indicator and Navigation
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Page Indicator
                  ValueListenableBuilder<int>(
                    valueListenable: currentPage,
                    builder: (context, value, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Container(
                            width: index == value ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: index == value
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Navigation Buttons
                  Row(
                    children: [
                      // Bookmark Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {/* TODO: Implement bookmark */},
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.bookmark_border,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Back Button
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Next Button
                      Expanded(
                        flex: 2,
                        child: ValueListenableBuilder<int>(
                          valueListenable: currentPage,
                          builder: (context, value, child) {
                            return GestureDetector(
                              onTap: () {
                                if (value < 4) {
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  // On last page, navigate to quiz
                                  context.push('/quiz/$storyId');
                                }
                              },
                              child: Container(
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: value == 4
                                      ? AppColors.limeGreen
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  value == 4 ? 'Take Quiz' : 'Next',
                                  style: TextStyle(
                                    color: value == 4
                                        ? Colors.black
                                        : AppColors.navyBlue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Demo data - Replace with actual API data
  static final Story _demoStory = Story(
    id: '1',
    title: 'The Birth of Democracy in Ancient Athens',
    description: 'The rise of democratic ideals in Athens',
    imageUrl:
        'https://images.pexels.com/photos/3290068/pexels-photo-3290068.jpeg',
    year: 508,
    isCompleted: true,
    mediaType: 'video',
    mediaUrl: 'https://example.com/video.mp4',
    content: '''
The birth of democracy in ancient Athens marks one of the most significant developments in human political history. In 508 BCE, the Athenian leader Cleisthenes introduced a system of political reforms that would lay the groundwork for what we now call democracy.

Prior to these reforms, Athens was ruled by a series of tyrants and aristocratic families. The society was divided along tribal lines, with power concentrated in the hands of a few wealthy families. This system created deep social tensions and inequalities that threatened to tear the city-state apart.

Cleisthenes' Revolutionary Reforms

Cleisthenes introduced several groundbreaking reforms:

1. The Deme System: He reorganized the citizen body into ten new tribes, breaking down old family allegiances and creating new political units based on geography rather than kinship.

2. The Council of 500: This new legislative body included representatives from all tribes, ensuring broader participation in governance.

3. Ostracism: A procedure allowing citizens to vote to exile powerful individuals who threatened democracy, serving as a check on potential tyrants.

The Practice of Democracy

The heart of Athenian democracy was the Assembly (Ecclesia), where all male citizens could:
• Debate public policy
• Vote on laws
• Elect officials
• Decide on military matters
• Handle diplomatic relations

The system operated on several key principles:
- Isonomia (equality before the law)
- Isegoria (equality in speaking in the assembly)
- Demokratia (people power)

Impact and Legacy

This revolutionary political system had profound effects:

• It fostered unprecedented levels of citizen participation in governance
• It created a culture of public debate and rhetoric
• It coincided with Athens' Golden Age of cultural and intellectual achievement
• It influenced political thinking throughout history

Challenges and Criticisms

However, Athenian democracy was not without its critics and limitations:

1. Citizenship was restricted to adult males born to Athenian parents
2. Women, slaves, and foreigners were excluded from political participation
3. The system could be manipulated by skilled orators
4. Decision-making could be slow and sometimes led to poor choices

Modern Relevance

The Athenian experiment with democracy continues to influence political systems today:

• The principle of citizen participation in governance
• The importance of public debate
• The concept of checks and balances
• The idea of political equality before the law

While modern democratic systems differ significantly from the Athenian model, many core principles first developed in ancient Athens remain relevant to contemporary political discourse and practice.

The story of Athenian democracy reminds us that political systems can evolve and that citizen participation in governance, while challenging to implement, can create stable and prosperous societies.
  ''',
    timestamps: [
      const Timestamp(time: '0:00', title: 'Introduction to Ancient Athens'),
      const Timestamp(time: '2:30', title: 'Cleisthenes\' Reforms'),
      const Timestamp(time: '5:45', title: 'The Assembly System'),
      const Timestamp(time: '8:15', title: 'Democratic Principles'),
      const Timestamp(time: '12:30', title: 'Challenges and Limitations'),
      const Timestamp(time: '15:45', title: 'Legacy and Modern Impact'),
    ],
  );
}

class _ContentPage extends StatelessWidget {
  final Story story;
  final bool isVideo;
  final int pageIndex;

  const _ContentPage({
    required this.story,
    required this.isVideo,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Split content into pages for demonstration
    final contentParts = story.content.split('\n\n');
    final startIndex = pageIndex * 2;
    final endIndex = (startIndex + 2) < contentParts.length
        ? (startIndex + 2)
        : contentParts.length;

    final pageContent = contentParts.sublist(startIndex, endIndex).join('\n\n');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or Video
          if (pageIndex == 0) ...[
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isVideo
                    ? _VideoPlayer(videoUrl: story.mediaUrl)
                    : CachedNetworkImage(
                        imageUrl: story.mediaUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
              ),
            ),

            // Title and Year
            Text(
              story.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideX(),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${story.year} BCE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ).animate().fadeIn().slideX(),

            const SizedBox(height: 24),
          ],

          // Content
          Text(
            pageContent,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ).animate().fadeIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
              ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _VideoPlayer extends StatelessWidget {
  final String videoUrl;

  const _VideoPlayer({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Video Player Placeholder',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
