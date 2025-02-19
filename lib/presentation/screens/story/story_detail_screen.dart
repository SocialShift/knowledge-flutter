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
    // TODO: Replace with actual API data
    final story = _demoStory;
    final isVideo = story.mediaType == 'video';

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Media Section (Video/Image)
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: isVideo
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

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interaction Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _InteractionButton(
                        icon: Icons.thumb_up_outlined,
                        label: 'Like',
                        onTap: () {/* TODO */},
                      ),
                      const SizedBox(width: 16),
                      _InteractionButton(
                        icon: Icons.thumb_down_outlined,
                        label: 'Dislike',
                        onTap: () {/* TODO */},
                      ),
                      const Spacer(),
                      _InteractionButton(
                        icon: Icons.flag_outlined,
                        label: 'Report',
                        onTap: () {/* TODO */},
                      ),
                    ],
                  ),
                ),

                // Title and Year
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${story.year}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Timestamps or Story Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: isVideo
                      ? _VideoTimestamps(timestamps: story.timestamps)
                      : Text(
                          story.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                ),

                // Navigation Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Back to Timeline'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement next action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Demo data - Replace with actual API data
  static final Story _demoStory = Story(
    id: '1',
    title: 'Birth of Democracy',
    description: 'The rise of democratic ideals in Athens',
    imageUrl:
        'https://images.pexels.com/photos/3290068/pexels-photo-3290068.jpeg',
    year: 1967,
    isCompleted: true,
    mediaType: 'video',
    mediaUrl: 'https://example.com/video.mp4',
    content: '''
    The story of democracy in ancient Athens is a fascinating journey through time. 
    It began in the 6th century BCE when Solon laid the groundwork for what would 
    become the world's first democratic system...
  ''',
    timestamps: [
      const Timestamp(time: '0:00', title: 'Introduction'),
      const Timestamp(time: '2:30', title: 'Early Democracy'),
      const Timestamp(time: '5:45', title: 'The Assembly'),
      const Timestamp(time: '8:15', title: 'Legacy'),
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
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
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
