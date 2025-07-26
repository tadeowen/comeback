import 'package:flutter/material.dart';
import 'testament_selection.dart';

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complete Bible App',
      debugShowCheckedModeBanner: false, // ✅ This hides the DEBUG banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TestamentSelectionScreen(),
    );
  }
}
