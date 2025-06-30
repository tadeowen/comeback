import 'dart:math';
import 'package:flutter/material.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final TextEditingController _requestController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _assignedDay;
  String? _confirmationCode;

  final Map<String, String> _keywords = {
    'family': 'Monday',
    'academic': 'Tuesday',
    'study': 'Tuesday',
    'school': 'Tuesday',
    'relationship': 'Wednesday',
    'marriage': 'Wednesday',
    'healing': 'Thursday',
    'sickness': 'Thursday',
    'demon': 'Friday',
    'deliverance': 'Friday',
    'general': 'Saturday',
    'elderly': 'Sunday',
    'old': 'Sunday',
  };

  void _processRequest() {
    final request = _requestController.text.toLowerCase();
    final ageText = _ageController.text;

    if (request.isEmpty || ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both age and request')),
      );
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid age')),
      );
      return;
    }

    String matchedDay = 'Saturday'; // default: general
    if (age >= 60) {
      matchedDay = 'Sunday';
    } else {
      for (final keyword in _keywords.keys) {
        if (request.contains(keyword)) {
          matchedDay = _keywords[keyword]!;
          break;
        }
      }
    }

    final code = _generateCode(5);

    setState(() {
      _assignedDay = matchedDay;
      _confirmationCode = code;
    });
  }

  String _generateCode(int length) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rand = Random();
    return List.generate(length, (_) => letters[rand.nextInt(letters.length)])
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Submit Your Prayer Request',
              style: theme.headline5?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your Age',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _requestController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your Prayer Request',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processRequest,
              child: const Text('Submit Request'),
            ),
            const SizedBox(height: 24),
            if (_assignedDay != null && _confirmationCode != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your prayer has been scheduled for:',
                      style: theme.subtitle1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _assignedDay!,
                      style: theme.headline6?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Confirmation Code:',
                      style: theme.subtitle1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _confirmationCode!,
                      style: theme.headline5?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
