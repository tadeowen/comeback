import 'package:flutter/material.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Media')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Gospel music, videos, news...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  // Gospel Music
                  Text(
                    'Gospel Music',
                    style: theme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMediaTile(
                    title: 'Hillsong Worship - What a Beautiful Name',
                    subtitle: 'Listen now',
                    icon: Icons.music_note,
                  ),
                  _buildMediaTile(
                    title: 'Sinach - Way Maker',
                    subtitle: 'Listen now',
                    icon: Icons.music_note,
                  ),

                  const SizedBox(height: 24),

                  // Gospel Videos
                  Text(
                    'Gospel Videos',
                    style: theme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMediaTile(
                    title: 'Sermon: The Power of Prayer',
                    subtitle: 'Watch now',
                    icon: Icons.play_circle_fill,
                  ),
                  _buildMediaTile(
                    title: 'Praise & Worship Session',
                    subtitle: 'Watch now',
                    icon: Icons.play_circle_fill,
                  ),

                  const SizedBox(height: 24),

                  // News
                  Text(
                    'Latest News',
                    style: theme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMediaTile(
                    title: 'New Gospel Album Released',
                    subtitle: 'Read more',
                    icon: Icons.article,
                  ),
                  _buildMediaTile(
                    title: 'Upcoming Gospel Concert',
                    subtitle: 'Read more',
                    icon: Icons.article,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, size: 32),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // TODO: Add navigation to detail page or player
      },
    );
  }
}