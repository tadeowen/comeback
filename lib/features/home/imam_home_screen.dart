import 'package:flutter/material.dart';

class ImamHomeScreen extends StatelessWidget {
  final String imamName;
  const ImamHomeScreen({super.key, required this.imamName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Imam Home")),
      body: Center(child: Text("Welcome, $imamName")),
    );
  }
}
