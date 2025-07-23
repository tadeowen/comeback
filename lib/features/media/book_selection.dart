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
      appBar: AppBar(
        title: Text('$testament Books'),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            title: Text(book.name),
            subtitle: Text(book.abbreviation),
            trailing: Text('${book.chapters} chapters'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterSelectionScreen(book: book),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
