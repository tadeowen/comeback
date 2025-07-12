import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl for date formatting

class ImamPrayerInboxScreen extends StatelessWidget {
  const ImamPrayerInboxScreen({super.key});

  // Get all prayer requests where imamId matches current user
  Stream<QuerySnapshot> getPrayerRequestsForCurrentImam() {
    final imamId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint("📥 Current Imam UID: $imamId");

    if (imamId == null) {
      // Return empty stream if not logged in yet
      return const Stream<QuerySnapshot>.empty();
    }

    return FirebaseFirestore.instance
        .collection('dua_request')
        .where('imamId', isEqualTo: imamId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📨 Received Prayer Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: getPrayerRequestsForCurrentImam(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("❌ Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No prayer requests yet."));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;

              final message = data['message'] ?? '';
              final isPublic = data['visibility'] == 'Public';
              final category = data['category'] ?? 'No category';
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedTime =
                  DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
              final displayName = isPublic
                  ? "${data['studentName'] ?? 'Unnamed'}\n${data['studentEmail'] ?? ''}"
                  : "Anonymous";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    message,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text("Category: $category",
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.teal)),
                      const SizedBox(height: 6),
                      Text("From: $displayName"),
                      const SizedBox(height: 4),
                      Text("Sent at: $formattedTime",
                          style: const TextStyle(fontSize: 12)),
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
