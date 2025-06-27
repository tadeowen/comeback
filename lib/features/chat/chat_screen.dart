import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Chat Screen', style: Theme.of(context).textTheme.headline4),
    );
  }
}

extension on TextTheme {
  Null get headline4 => null;
}
