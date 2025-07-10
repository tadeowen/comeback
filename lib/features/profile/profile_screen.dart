import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'No Name';
          final email = data['email'] ?? 'No Email';
          final confirmationCode = data['confirmationCode'];
          final appointment = data['appointment'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'Profile Info',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Name: $name'),
                Text('Email: $email'),
                const SizedBox(height: 20),
                const Divider(),
                const Text(
                  'Prayer Confirmation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                if (confirmationCode != null)
                  ListTile(
                    leading:
                        const Icon(Icons.verified_user, color: Colors.green),
                    title: const Text('Confirmation Code'),
                    subtitle: Text(confirmationCode),
                  ),
                if (appointment != null)
                  ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.teal),
                    title: const Text('Appointment Date'),
                    subtitle: Text(appointment),
                  ),
                if (confirmationCode == null && appointment == null)
                  const Text('No prayer request submitted yet.'),
              ],
            ),
          );
        },
      ),
    );
  }
}
