import 'package:flutter/material.dart';

class PriestHomeScreen extends StatelessWidget {
  final String priestName;
  const PriestHomeScreen({required this.priestName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Priest Home")),
      body: Center(child: Text("Welcome, $priestName")),
    );
  }
}
