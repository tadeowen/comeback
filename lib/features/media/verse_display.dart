import 'package:flutter/material.dart';
import 'bible_service_class.dart';
import 'bible_verse.dart';

class VerseDisplayScreen extends StatefulWidget {
  final String book;
  final int chapter;

  const VerseDisplayScreen({
    super.key,
    required this.book,
    required this.chapter,
  });

  @override
  State<VerseDisplayScreen> createState() => _VerseDisplayScreenState();
}

class _VerseDisplayScreenState extends State<VerseDisplayScreen> {
  final BibleService _bibleService = BibleService();
  late Future<List<BibleVerse>> _versesFuture;
  String _translation = 'kjv';

  @override
  void initState() {
    super.initState();
    _loadVerses();
  }

  void _loadVerses() {
    _versesFuture = _bibleService.getChapter(
      widget.book,
      widget.chapter,
      translation: _translation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: Text(
          '${widget.book} ${widget.chapter}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: FutureBuilder<List<BibleVerse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No verses found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final verses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: verses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final verse = verses[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 18,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                    children: [
                      TextSpan(
                        text: '${verse.verse} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      TextSpan(text: verse.text),
                    ],
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
