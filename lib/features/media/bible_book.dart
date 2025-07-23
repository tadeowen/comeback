class BibleBook {
  final String name;
  final String abbreviation;
  final String testament;
  final int chapters;
  final int position;

  const BibleBook({
    required this.name,
    required this.abbreviation,
    required this.testament,
    required this.chapters,
    required this.position,
  });

  static const List<BibleBook> allBooks = [
    // Old Testament
    BibleBook(
        name: "Genesis",
        abbreviation: "Gen",
        testament: "OT",
        chapters: 50,
        position: 1),
    BibleBook(
        name: "Exodus",
        abbreviation: "Exo",
        testament: "OT",
        chapters: 40,
        position: 2),
    BibleBook(
        name: "Leviticus",
        abbreviation: "Lev",
        testament: "OT",
        chapters: 27,
        position: 3),
    BibleBook(
        name: "Numbers",
        abbreviation: "Num",
        testament: "OT",
        chapters: 36,
        position: 4),
    BibleBook(
        name: "Deuteronomy",
        abbreviation: "Deut",
        testament: "OT",
        chapters: 34,
        position: 5),
    BibleBook(
        name: "Joshua",
        abbreviation: "Josh",
        testament: "OT",
        chapters: 24,
        position: 6),
    BibleBook(
        name: "Judges",
        abbreviation: "Judg",
        testament: "OT",
        chapters: 21,
        position: 7),
    BibleBook(
        name: "Ruth",
        abbreviation: "Ruth",
        testament: "OT",
        chapters: 4,
        position: 8),
    BibleBook(
        name: "1 Samuel",
        abbreviation: "1Sam",
        testament: "OT",
        chapters: 31,
        position: 9),
    BibleBook(
        name: "2 Samuel",
        abbreviation: "2Sam",
        testament: "OT",
        chapters: 24,
        position: 10),
    BibleBook(
        name: "1 Kings",
        abbreviation: "1Kgs",
        testament: "OT",
        chapters: 22,
        position: 11),
    BibleBook(
        name: "2 Kings",
        abbreviation: "2Kgs",
        testament: "OT",
        chapters: 25,
        position: 12),
    BibleBook(
        name: "1 Chronicles",
        abbreviation: "1Chr",
        testament: "OT",
        chapters: 29,
        position: 13),
    BibleBook(
        name: "2 Chronicles",
        abbreviation: "2Chr",
        testament: "OT",
        chapters: 36,
        position: 14),
    BibleBook(
        name: "Ezra",
        abbreviation: "Ezra",
        testament: "OT",
        chapters: 10,
        position: 15),
    BibleBook(
        name: "Nehemiah",
        abbreviation: "Neh",
        testament: "OT",
        chapters: 13,
        position: 16),
    BibleBook(
        name: "Esther",
        abbreviation: "Esth",
        testament: "OT",
        chapters: 10,
        position: 17),
    BibleBook(
        name: "Job",
        abbreviation: "Job",
        testament: "OT",
        chapters: 42,
        position: 18),
    BibleBook(
        name: "Psalms",
        abbreviation: "Psa",
        testament: "OT",
        chapters: 150,
        position: 19),
    BibleBook(
        name: "Proverbs",
        abbreviation: "Prov",
        testament: "OT",
        chapters: 31,
        position: 20),
    BibleBook(
        name: "Ecclesiastes",
        abbreviation: "Eccl",
        testament: "OT",
        chapters: 12,
        position: 21),
    BibleBook(
        name: "Song of Solomon",
        abbreviation: "Song",
        testament: "OT",
        chapters: 8,
        position: 22),
    BibleBook(
        name: "Isaiah",
        abbreviation: "Isa",
        testament: "OT",
        chapters: 66,
        position: 23),
    BibleBook(
        name: "Jeremiah",
        abbreviation: "Jer",
        testament: "OT",
        chapters: 52,
        position: 24),
    BibleBook(
        name: "Lamentations",
        abbreviation: "Lam",
        testament: "OT",
        chapters: 5,
        position: 25),
    BibleBook(
        name: "Ezekiel",
        abbreviation: "Ezek",
        testament: "OT",
        chapters: 48,
        position: 26),
    BibleBook(
        name: "Daniel",
        abbreviation: "Dan",
        testament: "OT",
        chapters: 12,
        position: 27),
    BibleBook(
        name: "Hosea",
        abbreviation: "Hos",
        testament: "OT",
        chapters: 14,
        position: 28),
    BibleBook(
        name: "Joel",
        abbreviation: "Joel",
        testament: "OT",
        chapters: 3,
        position: 29),
    BibleBook(
        name: "Amos",
        abbreviation: "Amos",
        testament: "OT",
        chapters: 9,
        position: 30),
    BibleBook(
        name: "Obadiah",
        abbreviation: "Obad",
        testament: "OT",
        chapters: 1,
        position: 31),
    BibleBook(
        name: "Jonah",
        abbreviation: "Jonah",
        testament: "OT",
        chapters: 4,
        position: 32),
    BibleBook(
        name: "Micah",
        abbreviation: "Micah",
        testament: "OT",
        chapters: 7,
        position: 33),
    BibleBook(
        name: "Nahum",
        abbreviation: "Nahum",
        testament: "OT",
        chapters: 3,
        position: 34),
    BibleBook(
        name: "Habakkuk",
        abbreviation: "Hab",
        testament: "OT",
        chapters: 3,
        position: 35),
    BibleBook(
        name: "Zephaniah",
        abbreviation: "Zeph",
        testament: "OT",
        chapters: 3,
        position: 36),
    BibleBook(
        name: "Haggai",
        abbreviation: "Hag",
        testament: "OT",
        chapters: 2,
        position: 37),
    BibleBook(
        name: "Zechariah",
        abbreviation: "Zech",
        testament: "OT",
        chapters: 14,
        position: 38),
    BibleBook(
        name: "Malachi",
        abbreviation: "Mal",
        testament: "OT",
        chapters: 4,
        position: 39),

    // New Testament
    BibleBook(
        name: "Matthew",
        abbreviation: "Matt",
        testament: "NT",
        chapters: 28,
        position: 40),
    BibleBook(
        name: "Mark",
        abbreviation: "Mark",
        testament: "NT",
        chapters: 16,
        position: 41),
    BibleBook(
        name: "Luke",
        abbreviation: "Luke",
        testament: "NT",
        chapters: 24,
        position: 42),
    BibleBook(
        name: "John",
        abbreviation: "John",
        testament: "NT",
        chapters: 21,
        position: 43),
    BibleBook(
        name: "Acts",
        abbreviation: "Acts",
        testament: "NT",
        chapters: 28,
        position: 44),
    BibleBook(
        name: "Romans",
        abbreviation: "Rom",
        testament: "NT",
        chapters: 16,
        position: 45),
    BibleBook(
        name: "1 Corinthians",
        abbreviation: "1Cor",
        testament: "NT",
        chapters: 16,
        position: 46),
    BibleBook(
        name: "2 Corinthians",
        abbreviation: "2Cor",
        testament: "NT",
        chapters: 13,
        position: 47),
    BibleBook(
        name: "Galatians",
        abbreviation: "Gal",
        testament: "NT",
        chapters: 6,
        position: 48),
    BibleBook(
        name: "Ephesians",
        abbreviation: "Eph",
        testament: "NT",
        chapters: 6,
        position: 49),
    BibleBook(
        name: "Philippians",
        abbreviation: "Phil",
        testament: "NT",
        chapters: 4,
        position: 50),
    BibleBook(
        name: "Colossians",
        abbreviation: "Col",
        testament: "NT",
        chapters: 4,
        position: 51),
    BibleBook(
        name: "1 Thessalonians",
        abbreviation: "1Thess",
        testament: "NT",
        chapters: 5,
        position: 52),
    BibleBook(
        name: "2 Thessalonians",
        abbreviation: "2Thess",
        testament: "NT",
        chapters: 3,
        position: 53),
    BibleBook(
        name: "1 Timothy",
        abbreviation: "1Tim",
        testament: "NT",
        chapters: 6,
        position: 54),
    BibleBook(
        name: "2 Timothy",
        abbreviation: "2Tim",
        testament: "NT",
        chapters: 4,
        position: 55),
    BibleBook(
        name: "Titus",
        abbreviation: "Titus",
        testament: "NT",
        chapters: 3,
        position: 56),
    BibleBook(
        name: "Philemon",
        abbreviation: "Phlm",
        testament: "NT",
        chapters: 1,
        position: 57),
    BibleBook(
        name: "Hebrews",
        abbreviation: "Heb",
        testament: "NT",
        chapters: 13,
        position: 58),
    BibleBook(
        name: "James",
        abbreviation: "Jas",
        testament: "NT",
        chapters: 5,
        position: 59),
    BibleBook(
        name: "1 Peter",
        abbreviation: "1Pet",
        testament: "NT",
        chapters: 5,
        position: 60),
    BibleBook(
        name: "2 Peter",
        abbreviation: "2Pet",
        testament: "NT",
        chapters: 3,
        position: 61),
    BibleBook(
        name: "1 John",
        abbreviation: "1John",
        testament: "NT",
        chapters: 5,
        position: 62),
    BibleBook(
        name: "2 John",
        abbreviation: "2John",
        testament: "NT",
        chapters: 1,
        position: 63),
    BibleBook(
        name: "3 John",
        abbreviation: "3John",
        testament: "NT",
        chapters: 1,
        position: 64),
    BibleBook(
        name: "Jude",
        abbreviation: "Jude",
        testament: "NT",
        chapters: 1,
        position: 65),
    BibleBook(
        name: "Revelation",
        abbreviation: "Rev",
        testament: "NT",
        chapters: 22,
        position: 66),
  ];

  static List<BibleBook> get oldTestament =>
      allBooks.where((book) => book.testament == "OT").toList();
  static List<BibleBook> get newTestament =>
      allBooks.where((book) => book.testament == "NT").toList();
}
