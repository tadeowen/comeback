import 'package:flutter/material.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Prayer Screen',
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}

extension on TextTheme {
  Null get headline4 => null;
}
