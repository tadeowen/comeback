import 'package:flutter/material.dart';
import '../chat/imam_chat_screen.dart';

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
      Center(child: Text("Welcome, ${widget.imamName}")),
      const Center(child: Text("📖 Quran Page")),
      const ImamChatScreen(),
      const Center(child: Text("👤 Profile Screen")),
      const Center(child: Text("📜 Hadith")),
      const Center(child: Text("🤲 Duas")),
    ];
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Imam - ${widget.imamName}"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Quran"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Hadith"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Duas"),
        ],
      ),
    );
  }
}
