import 'package:flutter/material.dart';
import 'bible_book.dart';
import 'book_selection.dart';

class TestamentSelectionScreen extends StatelessWidget {
  const TestamentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Testament')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookSelectionScreen(testament: 'OT'),
                  ),
                );
              },
              child: const Text('Old Testament'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookSelectionScreen(testament: 'NT'),
                  ),
                );
              },
              child: const Text('New Testament'),
            ),
          ],
        ),
      ),
    );
  }
}
