
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context)
  {
    return Center(
      child: Text(
        'Home Screen',
        style: Theme.of(context).textTheme.headline4,

      ),
    );
  }
}

extension on TextTheme {
  get headline4 => null;
}