import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;

  int totalRequests = 0;
  int completedRequests = 0;
  int pendingRequests = 0;

  @override
  void initState() {
    super.initState();
    _fetchPrayerStats();
  }

  Future<void> _fetchPrayerStats() async {
    if (_user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('prayer_requests')
        .where('userId', isEqualTo: _user!.uid)
        .get();

    final all = snap.docs;
    final pending = all.where((d) => d['status'] == 'pending');
    final done = all.where((d) => d['status'] == 'prayed');

    setState(() {
      totalRequests = all.length;
      pendingRequests = pending.length;
      completedRequests = done.length;
    });
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) _signOut();
  }

  Future<void> _showEditDialog(Map<String, dynamic> data, String userId) async {
    _ageController.text = data['age']?.toString() ?? '';
    _phoneController.text = data['phone'] ?? '';

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Enter age' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'age': int.parse(_ageController.text),
                  'phone': _phoneController.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = _user?.uid;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: confirmLogout),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists)
            return const Center(child: Text('No user data found'));

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final name = data['name'] ?? 'No Name';
          final email = data['email'] ?? 'No Email';
          final age = data['age']?.toString() ?? 'Not set';
          final phone = data['phone'] ?? 'Not set';
          final religion = data['religion'] ?? 'Not specified';
          final role = data['role'] ?? 'Student';
          final photoUrl = data['photoUrl'];
          final code = data['confirmationCode'];
          final appointment = data['appointment'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 48)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              Center(child: Text(name, style: const TextStyle(fontSize: 20))),
              Center(child: Text(role)),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone'),
                  subtitle: Text(phone),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('Age'),
                  subtitle: Text(age),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text('Religion'),
                  subtitle: Text(religion),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                onPressed: () => _showEditDialog(data, userId),
              ),
              const Divider(height: 32),
              const Text('Prayer Info',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (code != null)
                ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.green),
                  title: const Text('Confirmation Code'),
                  subtitle: Text(code),
                ),
              if (appointment != null)
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: const Text('Appointment'),
                  subtitle: Text(appointment),
                ),
              if (code == null && appointment == null)
                const Center(child: Text('No prayer request submitted.')),
              const Divider(height: 32),
              const Text(' Your Request Stands',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Total Requests'),
                  trailing: Text('$totalRequests'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Completed'),
                  trailing: Text('$completedRequests'),
                ),
              ),
              Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.pending_actions, color: Colors.orange),
                  title: const Text('Pending'),
                  trailing: Text('$pendingRequests'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.qr_code),
                  label: const Text('View QR Code '),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon!')),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
