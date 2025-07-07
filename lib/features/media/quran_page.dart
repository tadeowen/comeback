import 'package:flutter/material.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  // Example Quran data: Surah names and some verses with translations
  final Map<String, List<Map<String, String>>> quranData = {
    'Al-Fatiha': [
      {
        'arabic': 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        'translation':
            'In the name of Allah, the Most Gracious, the Most Merciful.'
      },
      {
        'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'translation': 'All praise is due to Allah, Lord of the worlds.'
      },
      {
        'arabic': 'الرَّحْمَنِ الرَّحِيمِ',
        'translation': 'The Most Gracious, the Most Merciful.'
      },
      // Add more verses if needed
    ],
    'Al-Ikhlas': [
      {
        'arabic': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        'translation': 'Say, "He is Allah, [who is] One,"'
      },
      {
        'arabic': 'اللَّهُ الصَّمَدُ',
        'translation': 'Allah, the Eternal Refuge.'
      },
      {
        'arabic': 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
        'translation': 'He neither begets nor is born,'
      },
      {
        'arabic': 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
        'translation': 'Nor is there to Him any equivalent."'
      },
    ],
  };

  String selectedSurah = 'Al-Fatiha';

  @override
  Widget build(BuildContext context) {
    final verses = quranData[selectedSurah]!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Qur’an - $selectedSurah'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          // Surah dropdown selector
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButtonFormField<String>(
              value: selectedSurah,
              items: quranData.keys
                  .map((surah) => DropdownMenuItem(
                        value: surah,
                        child: Text(surah),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedSurah = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Select Surah',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: verses.length,
              itemBuilder: (context, index) {
                final verse = verses[index];
                return Card(
                  color: Colors.blue[50],
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          verse['arabic']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri', // Optional: use a Quran font
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          verse['translation']!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
