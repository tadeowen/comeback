import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'features/home/home_screen.dart' as home;
import 'features/chat/chat_screen.dart' as chat;
import 'features/media/media_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/prayer/prayer_screen.dart';

// UI & Theme
import 'widgets/custom_bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Comeback());
}

class Comeback extends StatefulWidget {
  const Comeback({super.key});

  @override
  State<Comeback> createState() => _ComebackState();
}

class _ComebackState extends State<Comeback> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    home.HomeScreen(),
    PrayerScreen(),
    chat.ChatScreen(),
    MediaScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Come back',
      theme: ThemeData.light(),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: CustomBottomNav(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
