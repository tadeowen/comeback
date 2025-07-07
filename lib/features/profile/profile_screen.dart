import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? _user;
  DocumentSnapshot? _profileData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _user = _auth.currentUser;
    if (_user != null) {
      try {
        final snapshot =
            await _firestore.collection('users').doc(_user!.uid).get();
        if (mounted) {
          setState(() {
            _profileData = snapshot;
            _loading = false;
          });
        }
      } catch (e) {
        debugPrint('❌ Failed to load profile: $e');
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _editProfile() {
    if (_user == null || _profileData == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          userId: _user!.uid,
          initialData: _profileData!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _profileData?.data() as Map<String, dynamic>? ?? {};
    final name = data['name'] ?? 'No name';
    final age = data['age']?.toString() ?? 'Unknown';
    final photoUrl = data['photoUrl'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/images/placeholder_avatar.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(name, style: theme.headlineSmall),
            Text('Age: $age'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
