import 'package:flutter/material.dart';

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Media Screen', style: Theme.of(context).textTheme.headline4),
    );
  }
}

extension on TextTheme {
  Null get headline4 => null;
}
