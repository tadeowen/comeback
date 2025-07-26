import 'package:flutter/material.dart';
import 'bible_book.dart';
import 'verse_display.dart';

class ChapterSelectionScreen extends StatelessWidget {
  final BibleBook book;

  const ChapterSelectionScreen({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB), // Soft light background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: Text(
          book.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: book.chapters,
        itemBuilder: (context, index) {
          final chapterNumber = index + 1;
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF64B5F6),
                child: Text(
                  '$chapterNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                'Chapter $chapterNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerseDisplayScreen(
                      book: book.name,
                      chapter: chapterNumber,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
