import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ImamRatingScreen extends StatefulWidget {
  final String appointmentId;
  final String imamId;
  final DateTime appointmentDate;

  const ImamRatingScreen({
    super.key,
    required this.appointmentId,
    required this.imamId,
    required this.appointmentDate,
  });

  @override
  State<ImamRatingScreen> createState() => _ImamRatingScreenState();
}

class _ImamRatingScreenState extends State<ImamRatingScreen> {
  int _selectedRating = 0;
  bool _submitted = false;

  Future<void> _submitRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ratingData = {
      'imamId': widget.imamId,
      'studentId': user.uid,
      'rating': _selectedRating,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // ✅ Save rating to imamRatings collection
    await FirebaseFirestore.instance.collection('imamRatings').add(ratingData);

    // ✅ Mark appointment as rated
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentId)
        .update({'rated': true});

    // ✅ Update average rating for this imam
    await _updateImamAverage(widget.imamId);

    setState(() => _submitted = true);
  }

  Future<void> _updateImamAverage(String imamId) async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('imamRatings')
        .where('imamId', isEqualTo: imamId)
        .get();

    if (ratingsSnapshot.docs.isEmpty) return;

    double total = 0;
    for (var doc in ratingsSnapshot.docs) {
      total += (doc['rating'] as num).toDouble();
    }

    double average = total / ratingsSnapshot.docs.length;

    // ✅ Update avgRating and totalRatings in imams collection
    await FirebaseFirestore.instance.collection('users').doc(imamId).update({
      'avgRating': average,
      'totalRatings': ratingsSnapshot.docs.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = now.year == widget.appointmentDate.year &&
        now.month == widget.appointmentDate.month &&
        now.day == widget.appointmentDate.day;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate Your Imam"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: _submitted
            ? const Text(
                "Thanks for rating!",
                style: TextStyle(fontSize: 18),
              )
            : !isToday
                ? const Text(
                    "You can rate only on the day of your appointment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "How would you rate your experience?",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              color: _selectedRating > index
                                  ? Colors.orange
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedRating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _selectedRating > 0 ? _submitRating : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                        child: const Text("Submit Rating"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
