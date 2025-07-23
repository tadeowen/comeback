class BibleVerse {
  final String book;
  final String bookId;
  final int chapter;
  final int verse;
  final String text;
  final String? translation;
  final DateTime? lastAccessed;

  const BibleVerse({
    required this.book,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
    this.translation,
    this.lastAccessed,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      book: json['book_name'] ?? json['book'] ?? 'Unknown',
      bookId: json['book_id'] ?? json['bookId'] ?? '',
      chapter: _parseInt(json['chapter']),
      verse: _parseInt(json['verse']),
      text: json['text'] ?? json['content'] ?? '',
      translation: json['translation'],
      lastAccessed: json['lastAccessed'] != null
          ? DateTime.parse(json['lastAccessed'])
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String get reference => '$book $chapter:$verse';
  String get shortReference => '$bookId $chapter:$verse';
  String get chapterReference => '$book $chapter';

  BibleVerse copyWith({
    String? book,
    String? bookId,
    int? chapter,
    int? verse,
    String? text,
    String? translation,
    DateTime? lastAccessed,
  }) {
    return BibleVerse(
      book: book ?? this.book,
      bookId: bookId ?? this.bookId,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  @override
  String toString() {
    return '$reference ($translation) - ${text.length > 20 ? '${text.substring(0, 20)}...' : text}';
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'bookId': bookId,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'translation': translation,
      'lastAccessed': lastAccessed?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BibleVerse &&
        other.book == book &&
        other.bookId == bookId &&
        other.chapter == chapter &&
        other.verse == verse &&
        other.translation == translation;
  }

  @override
  int get hashCode {
    return Object.hash(book, bookId, chapter, verse, translation);
  }
}
