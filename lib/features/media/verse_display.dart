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
    setState(() {
      _versesFuture = _bibleService.getChapter(widget.book, widget.chapter,
          translation: _translation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book} ${widget.chapter}'),
        actions: [
          DropdownButton<String>(
            value: _translation,
            items: BibleService.translations.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.value,
                child: Text(entry.key),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _translation = value!;
                _loadVerses();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<BibleVerse>>(
        future: _versesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No verses found'));
          }

          final verses = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: verses.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final verse = verses[index];
              return RichText(
                text: TextSpan(
                  style:
                      DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
                  children: [
                    TextSpan(
                      text: '${verse.verse} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    TextSpan(text: verse.text),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
