import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Screens
import 'features/login/login_screen.dart';
import 'features/login/register_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/islam_home_screen.dart';
import 'features/media/media_screen.dart';
import 'features/prayer/prayer_screen.dart';
import 'features/chat/chat_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

// Theme
import 'core/theme.dart';
import 'core/themeNotifier.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

  // Local Notifications Setup
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'Church App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.themeMode,
          home: AuthWrapper(), // Changed to auth wrapper
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in
        if (snapshot.hasData) {
          return const MainNavigation();
        }

        // User is not logged in
        return const LoginScreen();
      },
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
  String studentName = 'User';
  String religion = 'Christianity';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch additional user data from Firestore if needed
      // Example:
      // final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      // setState(() {
      //   studentName = doc['name'] ?? 'User';
      //   religion = doc['religion'] ?? 'Christianity';
      // });
    }
    setState(() => _isLoading = false);
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Widget home = (religion == 'Islam')
        ? IslamHomeScreen(studentName: studentName)
        : HomeScreen(studentName: studentName);

    final List<Widget> screens = [
      home,
      //const PrayerRoomsScreen(),
      const BibleHomePage(),
      const PrayerScreen(),
      const ChatScreen(),
      ProfileScreen(onLogout: _handleLogout), // Modified profile screen
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $studentName'),
        automaticallyImplyLeading: false,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.video_library), label: 'Media'),
          BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new), label: 'Prayer'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')));
    }
  }
}
