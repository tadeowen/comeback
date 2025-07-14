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
        SnackBar(
          content: const Text('You have already rated this appointment.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.orange[800],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rate the Imam',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                ),
                const SizedBox(height: 20),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  maxRating: 5,
                  itemCount: 5,
                  itemSize: 40,
                  glowColor: Colors.amber[300],
                  unratedColor: Colors.grey[300],
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (value) {
                    ratingValue = value;
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;
    if (userId == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("My Prayer Requests"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal[800],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.teal[800]),
              const SizedBox(height: 20),
              Text(
                "You must be logged in to view requests.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Prayer Requests"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('dua_request')
            .where('studentId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[800]!),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.red[800]),
                  const SizedBox(height: 20),
                  Text(
                    "Error loading requests",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            assignAppointmentIfMissing(doc, data);
          }

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.teal[300]),
                  const SizedBox(height: 20),
                  Text(
                    "No prayer requests yet",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Your prayer requests will appear here",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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

              return FutureBuilder<DocumentSnapshot>(
                future: imamId != null
                    ? _firestore.collection('users').doc(imamId).get()
                    : null,
                builder: (context, imamSnapshot) {
                  String imamName = 'No Imam assigned';
                  if (imamSnapshot.hasData && imamSnapshot.data!.exists) {
                    final imamData =
                        imamSnapshot.data!.data() as Map<String, dynamic>?;
                    if (imamData != null && imamData['name'] != null) {
                      imamName = imamData['name'] as String;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 4,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.teal[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        sentFormatted,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.teal.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.teal[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: visibility == 'Public'
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: visibility == 'Public'
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      visibility,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: visibility == 'Public'
                                            ? Colors.green[800]
                                            : Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (imamName != 'No Imam assigned') ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        imamName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[800],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "From: $senderInfo",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        appointmentTime != null
                                            ? Icons.calendar_today_outlined
                                            : Icons.calendar_today,
                                        size: 16,
                                        color: appointmentTime != null
                                            ? Colors.teal[600]
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          appointmentFormatted,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: appointmentTime != null
                                                ? Colors.teal[800]
                                                : Colors.grey[700],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (appointmentTime != null &&
                                DateTime.now().isAfter(appointmentTime) &&
                                !hasRated &&
                                imamId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () => showRatingDialog(
                                        imamId, doc.reference, appointmentId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 2,
                                      shadowColor: Colors.teal.withOpacity(0.3),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rate_rounded, size: 18),
                                        SizedBox(width: 8),
                                        Text("Rate Imam"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
