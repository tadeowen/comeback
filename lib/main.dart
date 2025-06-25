import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme.dart';
import 'widgets/custom_bottom_nav.dart';
import 'features/home/home_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/media/media_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await firebase.initializeApp();
   runApp(const Comeback());

}
class _ComebackState extends StatefulWidget{
  const Comeback({Key? key}):super(key: key);

  @override
  State<Comeback> createState() => _ComebackState();


}

class _ComebackState extends State<Comeback> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    PrayerScreen(),
    ChatScreen(),
    MediaScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

@override
Widget build(BuildContext )
{
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