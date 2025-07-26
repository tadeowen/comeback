import 'package:flutter/material.dart';
import 'bible_book.dart';
import 'chapter_selection.dart';

class BookSelectionScreen extends StatelessWidget {
  final String testament;

  const BookSelectionScreen({
    super.key,
    required this.testament,
  });

  @override
  Widget build(BuildContext context) {
    final books =
        testament == 'OT' ? BibleBook.oldTestament : BibleBook.newTestament;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FB), // Light background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: Text(
          testament == 'OT' ? 'Old Testament Books' : 'New Testament Books',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF64B5F6),
                child: Text(
                  book.abbreviation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                book.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text('${book.chapters} Chapters'),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterSelectionScreen(book: book),
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
