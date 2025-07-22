import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _prayerPoints = [
    'Healing',
    'Forgiveness',
    'Success in Exams',
    'Family Peace',
    'Guidance',
    'Other',
  ];

  String? _selectedPrayerPoint;
  String _customPrayer = '';
  String? _confirmationCode;
  String? _assignedLeader;
  bool _isSubmitting = false;

  String _generateConfirmationCode() {
    final now = DateTime.now();
    return 'CONF-${now.millisecondsSinceEpoch}';
  }

  Future<String?> _getStudentReligion() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc['religion'];
  }

  Future<DocumentSnapshot?> _getBestMatchingLeader(
      String prayerPoint, String religion) async {
    final query = await FirebaseFirestore.instance
        .collection('leaders')
        .where('preferences', arrayContains: prayerPoint)
        .where('religion', isEqualTo: religion)
        .orderBy('lastAssigned', descending: false) // Least recently assigned
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? query.docs.first : null;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email;
    if (uid == null || email == null) return;

    final prayerText =
        _selectedPrayerPoint == 'Other' ? _customPrayer : _selectedPrayerPoint!;
    final confirmationCode = _generateConfirmationCode();

    try {
      final religion = await _getStudentReligion();
      if (religion == null)
        throw Exception('Could not determine user religion.');

      final leaderDoc =
          await _getBestMatchingLeader(_selectedPrayerPoint!, religion);
      if (leaderDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No available leader found for this request.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final leaderName = leaderDoc['name'];
      final leaderId = leaderDoc.id;

      // Save the request
      await FirebaseFirestore.instance.collection('prayer_requests').add({
        'requestText': prayerText,
        'customRequest': _customPrayer,
        'leader': leaderName,
        'leaderId': leaderId,
        'confirmationCode': confirmationCode,
        'userId': uid,
        'studentEmail': email,
        'status': 'pending',
        'replyRead': false,
        'timestamp': Timestamp.now(),
      });

      // Update student record
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'confirmationCode': confirmationCode,
        'assignedLeader': leaderName,
      });

      // Update leader's last assigned timestamp
      await FirebaseFirestore.instance
          .collection('leaders')
          .doc(leaderId)
          .update({
        'lastAssigned': Timestamp.now(),
      });

      setState(() {
        _confirmationCode = confirmationCode;
        _assignedLeader = leaderName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prayer request submitted successfully')),
      );
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
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
                  setState(() => _selectedPrayerPoint = value);
                },
                items: _prayerPoints
                    .map((point) => DropdownMenuItem<String>(
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
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isSubmitting ? null : _submitRequest,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Request'),
              ),
              if (_confirmationCode != null && _assignedLeader != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading:
                        const Icon(Icons.verified_user, color: Colors.green),
                    title: const Text('Confirmation Code'),
                    subtitle: Text(_confirmationCode!),
                  ),
                ),
                Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text('Assigned Leader'),
                    subtitle: Text(_assignedLeader!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
