import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chat Screen',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (user != null)
            Text(
              'Anonymous UID: ${user.uid}',
              style: Theme.of(context).textTheme.bodyLarge,
            )
          else
            const Text('No user signed in'),
        ],
      ),
    );
  }
}
