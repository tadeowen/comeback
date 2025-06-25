import 'package:flutter/material.dart';
class CustomButtomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  // ignore: use_super_parameters
  const CustomBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTap,

  }) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap:onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: 'Prayer'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label:'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Media'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),

      ],
    );
  }
}