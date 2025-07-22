import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _messageController = TextEditingController();

  final List<String> _prayerOptions = [
    'Healing',
    'Forgiveness',
    'Success in Exams',
    'Family Peace',
    'Guidance',
    'Other'
  ];

  final List<String> _selectedPreferences = [];
  int _requestCount = 0;

  void _submitPreferences() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && _formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('leaders').doc(uid).set({
        'name': widget.priestName,
        'preferences': _selectedPreferences,
        'Denomination'
            'date': _dateController.text,
        'time': _timeController.text,
        'lastUpdated': Timestamp.now(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved')),
      );
    }
  }

  Future<void> _markAsPrayedAndNotify(String requestId, String userId) async {
    try {
      final message = _messageController.text.trim().isEmpty
          ? 'Your prayer request has been prayed for by ${widget.priestName}.'
          : _messageController.text.trim();

      await FirebaseFirestore.instance
          .collection('prayer_requests')
          .doc(requestId)
          .update({'status': 'prayed'});

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'message': message,
        'timestamp': Timestamp.now(),
        'read': false,
      });

      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student notified.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending notification: $e')),
      );
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('EEEE, MMMM d').format(picked);
    }
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      _timeController.text = picked.format(context);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.priestName}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prayer Analysis',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Total Requests Assigned: $_requestCount'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Set Your Prayer Preferences'),
              initiallyExpanded: true,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 10,
                        children: _prayerOptions.map((option) {
                          final isSelected =
                              _selectedPreferences.contains(option);
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
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a date'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a time'
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
              ],
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
                          .where('status', isEqualTo: 'pending')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final requests = snapshot.data?.docs ?? [];
                        _requestCount = requests.length;

                        if (requests.isEmpty) {
                          return const Center(
                              child: Text('No pending requests'));
                        }

                        return ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final doc = requests[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final requestId = doc.id;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(data['requestText'] ?? 'No Title'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Submitted: ${data['timestamp'].toDate()}'),
                                    TextFormField(
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                          hintText: 'Reply message'),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  tooltip: 'Mark as prayed and notify',
                                  onPressed: () => _markAsPrayedAndNotify(
                                      requestId, data['userId'] ?? ''),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
