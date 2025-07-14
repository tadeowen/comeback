import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyPrayerRequestsScreen extends StatefulWidget {
  const MyPrayerRequestsScreen({super.key});

  @override
  State<MyPrayerRequestsScreen> createState() => _MyPrayerRequestsScreenState();
}

class _MyPrayerRequestsScreenState extends State<MyPrayerRequestsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  DateTime getNextWeekdayDateTime(String weekday, String time24h) {
    final now = DateTime.now();

    final weekdaysMap = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    int? targetWeekday = weekdaysMap[weekday];
    if (targetWeekday == null) throw Exception('Invalid weekday');

    int daysUntilNext = (targetWeekday - now.weekday) % 7;
    if (daysUntilNext == 0) daysUntilNext = 7;

    final nextDate = now.add(Duration(days: daysUntilNext));

    final parts = time24h.split(':');
    int hour = int.tryParse(parts[0]) ?? 9;
    int minute = (parts.length > 1) ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(nextDate.year, nextDate.month, nextDate.day, hour, minute);
  }

  Future<void> assignAppointmentIfMissing(
      DocumentSnapshot prayerDoc, Map<String, dynamic> data) async {
    if (data['appointmentDate'] != null) return;

    final imamId = data['imamId'];
    final category = data['category'];
    if (imamId == null || category == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('imamAppointments')
          .where('imamId', isEqualTo: imamId)
          .where('responsibility', isEqualTo: category)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final appointmentData = querySnapshot.docs.first.data();
      final confirmationDay = appointmentData['day'] as String?;
      final confirmationTime = appointmentData['time'] as String?;

      if (confirmationDay == null || confirmationTime == null) return;

      final appointmentDate =
          getNextWeekdayDateTime(confirmationDay, confirmationTime);

      await prayerDoc.reference.update({
        'appointmentDate': Timestamp.fromDate(appointmentDate),
        'confirmationDay': confirmationDay,
        'confirmationTime': confirmationTime,
      });
    } catch (e) {
      debugPrint("Error assigning appointment: $e");
    }
  }

  void showRatingDialog(
      String imamId, DocumentReference prayerRef, String appointmentId) async {
    double ratingValue = 3;

    final check = await _firestore
        .collection('imamRatings')
        .where('imamId', isEqualTo: imamId)
        .where('studentId', isEqualTo: currentUserId)
        .where('appointmentId', isEqualTo: appointmentId)
        .limit(1)
        .get();

    if (check.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You have already rated this appointment.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Rate the Imam'),
          content: RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            maxRating: 5,
            itemCount: 5,
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (value) {
              ratingValue = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('imamRatings').add({
                  'imamId': imamId,
                  'studentId': currentUserId,
                  'appointmentId': appointmentId,
                  'rating': ratingValue,
                  'timestamp': Timestamp.now(),
                });
                await prayerRef.update({'rated': true});
                Navigator.pop(ctx);
              },
              child: const Text('Submit'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Prayer Requests")),
        body: const Center(
            child: Text("You must be logged in to view requests.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Prayer Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('dua_request')
            .where('studentId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            assignAppointmentIfMissing(doc, data);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final message = data['message'] ?? '';
              final category = data['category'] ?? 'No category';
              final visibility = data['visibility'] ?? 'Anonymous';
              final imamId = data['imamId'];
              final hasRated = data['rated'] == true;
              final appointmentId = data['appointmentId'] ?? '';

              final sentTime = (data['timestamp'] as Timestamp?)?.toDate();
              final sentFormatted = sentTime != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(sentTime)
                  : 'Unknown date';

              final appointmentTime =
                  (data['appointmentDate'] as Timestamp?)?.toDate();
              final appointmentFormatted = appointmentTime != null
                  ? DateFormat('EEE, dd MMM yyyy, hh:mm a')
                      .format(appointmentTime)
                  : 'No appointment scheduled';

              final senderInfo = (visibility == 'Public')
                  ? "${data['studentName'] ?? 'Unknown'}\n${data['studentEmail'] ?? ''}"
                  : 'Anonymous';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(message,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text("Category: $category"),
                            backgroundColor: Colors.teal.shade100,
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                          Chip(
                            label: Text("Visibility: $visibility"),
                            backgroundColor: visibility == 'Public'
                                ? Colors.green.shade100
                                : Colors.grey.shade300,
                            labelStyle: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("From: $senderInfo"),
                      const SizedBox(height: 6),
                      Text("Sent at: $sentFormatted",
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 6),
                      Text("Appointment: $appointmentFormatted",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: appointmentTime != null
                                  ? Colors.green
                                  : Colors.red)),
                      const SizedBox(height: 10),
                      if (appointmentTime != null &&
                          DateTime.now().isAfter(appointmentTime) &&
                          !hasRated &&
                          imamId != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => showRatingDialog(
                                imamId, doc.reference, appointmentId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            child: const Text("Rate Imam"),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
