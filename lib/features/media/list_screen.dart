import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'appoint.dart'; // Make sure this import points to your setup screen file

class ImamAppointmentsListScreen extends StatelessWidget {
  const ImamAppointmentsListScreen({super.key});

  void _deleteAppointment(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Appointment"),
        content:
            const Text("Are you sure you want to delete this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('imamAppointments')
          .doc(docId)
          .delete();
    }
  }

  void _editAppointment(
      BuildContext context, String docId, Map<String, dynamic> data) {
    final TextEditingController responsibilityController =
        TextEditingController(text: data['responsibility']);
    String selectedDay = data['day'] ?? 'Monday';
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.tryParse(data['time']?.split(':')?.first ?? '10') ?? 10,
      minute: 0,
    );

    final List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Edit Appointment"),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: responsibilityController,
                      decoration:
                          const InputDecoration(labelText: "Responsibility"),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      items: daysOfWeek.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedDay = val);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select Day',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() => selectedTime = picked);
                        }
                      },
                      child: Text("Pick Time: ${selectedTime.format(context)}"),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Confirm Save"),
                    content:
                        const Text("Are you sure you want to save changes?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await FirebaseFirestore.instance
                      .collection('imamAppointments')
                      .doc(docId)
                      .update({
                    'responsibility': responsibilityController.text.trim(),
                    'day': selectedDay,
                    'time': selectedTime.format(context),
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.teal.shade100,
      Colors.amber.shade100,
      Colors.cyan.shade100,
      Colors.lightGreen.shade100,
      Colors.deepOrange.shade100,
      Colors.pink.shade100,
      Colors.indigo.shade100,
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final imamId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to ImamHadithSetupScreen, replacing this screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ImamHadithSetupScreen()),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('imamAppointments')
            .where('imamId', isEqualTo: imamId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No appointments found."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                return InputChip(
                  backgroundColor: _getRandomColor(),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['responsibility'] ?? 'No description',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Day: ${data['day'] ?? 'N/A'}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Time: ${data['time'] ?? 'N/A'}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onDeleted: () => _deleteAppointment(context, doc.id),
                  deleteIconColor: Colors.black,
                  onPressed: () => _editAppointment(context, doc.id, data),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
