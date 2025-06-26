import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'widgets/custom_bottom_nav.dart';
import 'features/home/home_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/media/media_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/prayer/prayer_screen.dart'; // Make sure this exists

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
    HomeScreen(),
    PrayerScreen(), // Make sure you have this screen implemented
    ChatScreen(),
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
      theme: appTheme,
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
