import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- add this import
import 'firebase_options.dart';

// Screens
import 'features/home/home_screen.dart';
import 'features/media/media_screen.dart';
import 'features/prayer/prayer_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/login/login.dart';
import 'features/profile/profile_screen.dart';

// Theme
import 'core/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e, stack) {
    debugPrint("❌ Firebase init failed: $e");
    debugPrintStack(stackTrace: stack);
  }

  runApp(const ComebackApp());
}

class ComebackApp extends StatelessWidget {
  const ComebackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comeback',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FirebaseAuth.instance.currentUser == null
          ? const Login()
          : const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String? studentName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        setState(() {
          studentName = doc['name'] ?? 'User';
          isLoading = false;
        });
      } catch (e) {
        // If error, fallback to default name
        setState(() {
          studentName = 'User';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        studentName = 'User';
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      HomeScreen(studentName: studentName ?? 'User'),
      const MediaScreen(),
      const PrayerScreen(),
      const ChatScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_music), label: 'Media'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Prayer'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
