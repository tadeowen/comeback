import 'dart:convert';
import 'package:http/http.dart' as http;
import 'bible_verse.dart';

class BibleService {
  static const String _baseUrl = 'https://bible-api.com';

  // Available translations
  static const Map<String, String> translations = {
    'KJV': 'kjv',
    'NIV': 'niv',
    'ESV': 'esv',
    'NASB': 'nasb',
    'NKJV': 'nkjv',
    'NLT': 'nlt',
  };

  Future<List<BibleVerse>> getChapter(String book, int chapter,
      {String translation = 'kjv'}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$book%20$chapter?translation=$translation'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['verses'] as List)
          .map((verse) => BibleVerse.fromJson(verse))
          .toList();
    } else {
      throw Exception(
          'Failed to load chapter. Status code: ${response.statusCode}');
    }
  }

  Future<List<BibleVerse>> getVerses(String reference,
      {String translation = 'kjv'}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$reference?translation=$translation'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['verses'] as List)
          .map((verse) => BibleVerse.fromJson(verse))
          .toList();
    } else {
      throw Exception(
          'Failed to load verses. Status code: ${response.statusCode}');
    }
  }

  Future<String> getVerseText(String reference,
      {String translation = 'kjv'}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$reference?translation=$translation'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['text'];
    } else {
      throw Exception(
          'Failed to load verse. Status code: ${response.statusCode}');
    }
  }
}
