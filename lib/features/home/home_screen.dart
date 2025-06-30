import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Greetings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A warm Welcome!',
              style: theme.headline4?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Daily Bible Verse Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '"For I know the plans I have for you," declares the Lord, '
                '"plans to prosper you and not to harm you, plans to give you hope and a future." '
                '- Jeremiah 29:11',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),

            // News Section
            Text(
              'Church News',
              style: theme.headline6?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Sunday services from 7:00am, 9:00am and 11;00 AM\n'
              '• Youth fellowship on Friday at 7 PM',
            ),

            const SizedBox(height: 24),

            // Upcoming Events Section
            Text(
              'Upcoming Events',
              style: theme.headline6?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Community outreach - July 5th\n'
              '• Bible study retreat - August 5',
            ),
          ],
        ),
      ),
    );
  }
}
