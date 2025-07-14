import 'package:flutter/material.dart';
import '../chat/imam_chat_screen.dart';
import '../prayer/imam_prayer_inbox.dart';
import '../media/appoint.dart';

class ImamHomeScreen extends StatefulWidget {
  final String imamName;
  const ImamHomeScreen({super.key, required this.imamName});

  @override
  State<ImamHomeScreen> createState() => _ImamHomeScreenState();
}

class _ImamHomeScreenState extends State<ImamHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomePage(),
      const Center(child: Text("📖 Quran Page")),
      const ImamChatScreen(),
      const ImamHadithSetupScreen(),
      const ImamPrayerInboxScreen(),
      const Center(child: Text("👤 Profile Screen")),
    ];
  }

  Widget _buildHomePage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade100, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mosque, size: 80, color: Colors.teal.shade800),
          const SizedBox(height: 20),
          Text(
            "May your day be filled with blessings.",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Use the navigation below to access your tasks.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text("Welcome, ${widget.imamName}"),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 4,
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Quran"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Setup"),
          BottomNavigationBarItem(
              icon: Icon(Icons.star), label: "Dua requests"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
