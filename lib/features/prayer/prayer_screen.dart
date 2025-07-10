import 'package:flutter/material.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final List<String> _prayerPoints = [
    'Healing',
    'Forgiveness',
    'Success in Exams',
    'Family Peace',
    'Guidance',
    'Other',
  ];

  final List<String> _leaders = [
    'Fr. Andrew',
    'Sr. Mary',
    'Imam Yusuf',
    'Sheikh Musa'
  ];

  String? _selectedPrayerPoint;
  String? _selectedLeader;
  String _customPrayer = '';
  String? _confirmationCode;

  final _formKey = GlobalKey<FormState>();

  String _generateConfirmationCode() {
    final now = DateTime.now();
    return 'CONF-${now.millisecondsSinceEpoch}';
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      final requestText = _selectedPrayerPoint == 'Other'
          ? _customPrayer
          : _selectedPrayerPoint;

      setState(() {
        _confirmationCode = _generateConfirmationCode();
      });

      // Simulate Firestore or backend submission here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prayer request submitted to $_selectedLeader'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Submit Prayer Request'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Prayer Point',
                  border: OutlineInputBorder(),
                ),
                value: _selectedPrayerPoint,
                onChanged: (value) {
                  setState(() {
                    _selectedPrayerPoint = value;
                  });
                },
                items: _prayerPoints
                    .map((point) => DropdownMenuItem(
                          value: point,
                          child: Text(point),
                        ))
                    .toList(),
                validator: (value) =>
                    value == null ? 'Please choose a prayer point' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedPrayerPoint == 'Other')
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Custom Prayer Request',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (val) => _customPrayer = val,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter your prayer request'
                      : null,
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Choose Religious Leader',
                  border: OutlineInputBorder(),
                ),
                value: _selectedLeader,
                onChanged: (value) {
                  setState(() {
                    _selectedLeader = value;
                  });
                },
                items: _leaders
                    .map((leader) => DropdownMenuItem(
                          value: leader,
                          child: Text(leader),
                        ))
                    .toList(),
                validator: (value) =>
                    value == null ? 'Please choose a leader' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitRequest,
                child: const Text('Submit Request'),
              ),
              if (_confirmationCode != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading:
                        const Icon(Icons.verified_user, color: Colors.green),
                    title: Text('Confirmation Code'),
                    subtitle: Text(_confirmationCode!),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
