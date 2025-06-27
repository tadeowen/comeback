import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Screen', style: Theme.of(context).textTheme.headline4),
    );
  }
}

extension on TextTheme {
  Null get headline4 => null;
}
