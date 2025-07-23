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
      appBar: AppBar(
        title: Text(book.name),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        itemCount: book.chapters,
        itemBuilder: (context, index) {
          final chapterNumber = index + 1;
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: Text('$chapterNumber'),
            onPressed: () {
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
          );
        },
      ),
    );
  }
}
