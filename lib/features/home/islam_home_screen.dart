import 'package:flutter/material.dart';
import '../media/quran_page.dart';
import '../profile/islam_profile_screen.dart'; // Optional, in case profile is needed

class IslamHomeScreen extends StatefulWidget {
  final String studentName;

  const IslamHomeScreen({super.key, required this.studentName});

  @override
  State<IslamHomeScreen> createState() => _IslamHomeScreenState();
}

class _IslamHomeScreenState extends State<IslamHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const PrayerAndAyahPage(),
      const QuranPage(),
      const Center(child: Text("🤲 Duas")),
      const Center(child: Text("💡 Hadith")),
      MuslimSettingsScreen(
          studentName: widget.studentName), // ✅ Real settings screen
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.studentName}!'),
        backgroundColor: Colors.green[700],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Qur’an'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Duas'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Hadith'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class PrayerAndAyahPage extends StatelessWidget {
  const PrayerAndAyahPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🕌 Prayer Times (Today)', style: theme.titleMedium),
          const SizedBox(height: 8),
          _buildPrayerTimesCard(),
          const SizedBox(height: 24),
          Text('📖 Ayah of the Day', style: theme.titleMedium),
          _buildAyahCard(),
          const SizedBox(height: 24),
          Text('🤲 Dua of the Day', style: theme.titleMedium),
          _buildDuaCard(),
        ],
      ),
    );
  }

  static Widget _buildPrayerTimesCard() {
    return Card(
      color: Colors.green[50],
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fajr: 5:12 AM'),
            Text('Dhuhr: 12:45 PM'),
            Text('Asr: 4:20 PM'),
            Text('Maghrib: 6:50 PM'),
            Text('Isha: 8:10 PM'),
          ],
        ),
      ),
    );
  }

  static Widget _buildAyahCard() {
    return Card(
      color: Colors.blue[50],
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '"Indeed, with hardship comes ease." (Qur’an 94:6)',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDuaCard() {
    return Card(
      color: Colors.orange[50],
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              'اللّهُـمَّ أَنْتَ رَبِّـي لا إلهَ إلاّ أَنْتَ',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'O Allah, You are my Lord. There is no deity except You.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
