import 'package:flutter/material.dart';
import 'testament_selection.dart';

void main() {
  print("✅ Running BibleApp"); // Add this
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides DEBUG banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TestamentSelectionScreen(),
    );
  }
}
