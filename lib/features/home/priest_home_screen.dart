import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PriestHomeScreen extends StatefulWidget {
  final String priestName;

  const PriestHomeScreen({super.key, required this.priestName});

  @override
  State<PriestHomeScreen> createState() => _PriestHomeScreenState();
}

class _PriestHomeScreenState extends State<PriestHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final List<String> _prayerOptions = [
    'Healing',
    'Forgiveness',
    'Success in Exams',
    'Family Peace',
    'Guidance',
  ];

  List<String> _selectedPreferences = [];

  void _submitPreferences() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && _formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('leaders').doc(uid).set({
        'preferences': _selectedPreferences,
        'date': _dateController.text,
        'time': _timeController.text,
        'lastUpdated': Timestamp.now(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved')),
      );
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Priest Dashboard - Welcome, ${widget.priestName}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Set Your Prayer Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    children: _prayerOptions.map((option) {
                      final isSelected = _selectedPreferences.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedPreferences.add(option);
                            } else {
                              _selectedPreferences.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date (e.g., Friday, July 12)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter date'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time (e.g., 2:00 PM)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter time'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitPreferences,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    child: const Text('Save Preferences'),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text('Pending Prayer Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: uid == null
                  ? const Center(child: Text('Not signed in'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('prayer_requests')
                          .where('leader', isEqualTo: widget.priestName)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final requests = snapshot.data?.docs ?? [];
                        if (requests.isEmpty) {
                          return const Center(
                              child: Text('No pending requests'));
                        }

                        return ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final data =
                                requests[index].data() as Map<String, dynamic>;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(data['requestText'] ?? 'No Title'),
                                subtitle: Text(
                                    'Submitted: ${data['timestamp'].toDate()}'),
                                trailing: const Icon(Icons.bookmark_border),
                              ),
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
