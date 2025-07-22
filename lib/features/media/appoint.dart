import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../prayer/imam_prayer_inbox.dart';
import 'list_screen.dart'; // Ensure this points to your appointments list screen

class ImamHadithSetupScreen extends StatefulWidget {
  const ImamHadithSetupScreen({super.key});

  @override
  State<ImamHadithSetupScreen> createState() => _ImamHadithSetupScreenState();
}

class _ImamHadithSetupScreenState extends State<ImamHadithSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  String _responsibility = '';
  String? _selectedDay;
  TimeOfDay? _selectedTime;

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  void _submitData() async {
    if (_formKey.currentState!.validate() &&
        _selectedDay != null &&
        _selectedTime != null) {
      final imamId = FirebaseAuth.instance.currentUser?.uid;
      final appointment = {
        'imamId': imamId,
        'responsibility': _responsibility,
        'day': _selectedDay,
        'time': _selectedTime!.format(context),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('imamAppointments')
          .add(appointment);

      // Show dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text("Success"),
          content: Text("Your appointment has been saved."),
        ),
      );

      // After 2 seconds, close dialog and navigate
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop(); // Close dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ImamAppointmentsListScreen(),
          ),
        );
      });

      setState(() {
        _responsibility = '';
        _selectedDay = null;
        _selectedTime = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Imam Appointment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'What will you handle?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe your responsibility';
                    }
                    return null;
                  },
                  onChanged: (val) => _responsibility = val,
                ),
                const SizedBox(height: 16),

                // Green dropdown styled like a button
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDay,
                      hint: const Text(
                        'Select Day',
                        style: TextStyle(color: Colors.white),
                      ),
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.white,
                      items: _daysOfWeek.map((day) {
                        return DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedDay = val);
                      },
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Green time picker button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _pickTime,
                    child: Text(
                      _selectedTime == null
                          ? "Pick Time"
                          : _selectedTime!.format(context),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Save Appointment button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Save Appointment",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // View appointments button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImamAppointmentsListScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "View My Appointments",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Additional button to navigate to list screen
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ImamPrayerInboxScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Go to Appointments List",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
