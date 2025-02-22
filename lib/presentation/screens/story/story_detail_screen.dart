import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/data/models/timeline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Media + Header)
            SizedBox(
              height: size.height * 0.4,
              child: Stack(
                children: [
                  // Media
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: isVideo
                            ? _VideoPlayer(videoUrl: story.mediaUrl)
                            : Hero(
                                tag: 'story_${story.id}',
                                child: CachedNetworkImage(
                                  imageUrl: story.mediaUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Back Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title Section with better alignment
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn().slideX(),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${story.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).animate().fadeIn().slideX(),
                ],
              ),
            ),

            // Interaction Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _InteractionButton(
                    icon: Icons.thumb_up_outlined,
                    label: 'Like',
                    onTap: () {/* TODO */},
                  ),
                  const SizedBox(width: 12),
                  _InteractionButton(
                    icon: Icons.bookmark_border,
                    label: 'Save',
                    onTap: () {/* TODO */},
                  ),
                  const SizedBox(width: 12),
                  _InteractionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {/* TODO */},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scrollable Content with better typography
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.7,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (isVideo) ...[
                      const Text(
                        'Video Chapters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _VideoTimestamps(timestamps: story.timestamps),
                    ],
                    const SizedBox(height: 100), // Bottom padding for content
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back to Timeline'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/quiz/$storyId'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Take Quiz'),
                    ),
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

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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

class _VideoTimestamps extends StatelessWidget {
  final List<Timestamp> timestamps;

  const _VideoTimestamps({required this.timestamps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: timestamps.map((timestamp) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Text(
                timestamp.time,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  timestamp.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
