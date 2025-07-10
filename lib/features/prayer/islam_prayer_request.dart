import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IslamPrayerRequest extends StatefulWidget {
  const IslamPrayerRequest({super.key});

  @override
  State<IslamPrayerRequest> createState() => _IslamPrayerRequestState();
}

class _IslamPrayerRequestState extends State<IslamPrayerRequest> {
  final TextEditingController _messageController = TextEditingController();
  String? selectedImamId;
  List<Map<String, dynamic>> imams = [];
  String visibilityOption = 'Anonymous';

  @override
  void initState() {
    super.initState();
    fetchImams();
  }

  Future<void> fetchImams() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Imam')
        .where('religion', isEqualTo: 'Islam')
        .get();

    setState(() {
      imams = snapshot.docs
          .map((doc) => {'id': doc.id, 'name': doc['name']})
          .toList();
    });
  }

  Future<void> sendPrayerRequest() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a prayer request")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (imams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Imams available.")),
      );
      return;
    }

    final targetImamId =
        selectedImamId ?? imams[Random().nextInt(imams.length)]['id'];

    final requestData = {
      'studentId': user.uid,
      'imamId': targetImamId,
      'message': _messageController.text.trim(),
      'timestamp': Timestamp.now(),
      'visibility': visibilityOption,
      if (visibilityOption == 'Public') ...{
        'studentName': user.displayName ?? 'Unknown',
        'studentEmail': user.email ?? 'Not available',
      }
    };

    await FirebaseFirestore.instance.collection('dua_request').add(requestData);

    print("📨 Sent request to imamId: $targetImamId"); // Debug log

    _messageController.clear();
    setState(() {
      selectedImamId = null;
      visibilityOption = 'Anonymous';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prayer request sent!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Prayer Request")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Imam"),
              value: selectedImamId,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text("Any available Imam"),
                ),
                ...imams.map((imam) => DropdownMenuItem(
                      value: imam['id'],
                      child: Text(imam['name']),
                    ))
              ],
              onChanged: (value) {
                setState(() {
                  selectedImamId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Choose Visibility"),
              value: visibilityOption,
              items: const [
                DropdownMenuItem(value: 'Anonymous', child: Text("Anonymous")),
                DropdownMenuItem(value: 'Public', child: Text("Public")),
              ],
              onChanged: (value) {
                setState(() {
                  visibilityOption = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Your prayer request",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: sendPrayerRequest,
              icon: const Icon(Icons.send),
              label: const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}
