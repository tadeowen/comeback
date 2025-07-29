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
            debugPrint("Error loading requests: ${snapshot.error}");
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
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

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
                    "Submit your first prayer request to see it here",
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
              final status = data['status'] ?? 'pending';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final formattedDate = timestamp != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)
                  : 'Unknown date';
              final imamId = data['imamId'];
              final hasRated = data['rated'] == true;
              final imamName = data['imamName'] ?? 'Imam';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 40,
                            decoration: BoxDecoration(
                              color: status == 'resolved'
                                  ? Colors.green
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: status == 'resolved'
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: status == 'resolved'
                                ? Colors.green
                                : Colors.orange[100],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Imam: $imamName",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (data['category'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Category: ${data['category']}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      if (status == 'resolved')
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!hasRated && imamId != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ElevatedButton(
                                    onPressed: () => _showRatingDialog(
                                        imamId, doc.reference),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal[700],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text("Rate Imam"),
                                  ),
                                ),
                              ElevatedButton(
                                onPressed: () =>
                                    _confirmDeleteRequest(doc.reference),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("Delete"),
                              ),
                            ],
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

  Future<void> _confirmDeleteRequest(DocumentReference requestRef) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Request"),
        content:
            const Text("Are you sure you want to delete this prayer request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await requestRef.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Request deleted successfully")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting request: $e")),
          );
        }
      }
    }
  }

  void _showRatingDialog(String imamId, DocumentReference requestRef) async {
    double ratingValue = 3.0;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Rate the Imam"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
                    initialRating: 3,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      ratingValue = rating;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isSubmitting) const CircularProgressIndicator(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() => isSubmitting = true);
                    try {
                      // Save rating
                      await _firestore.collection('imamRatings').add({
                        'imamId': imamId,
                        'userId': currentUserId,
                        'requestId': requestRef.id,
                        'rating': ratingValue,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Mark request as rated
                      await requestRef.update({'rated': true});

                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Error submitting rating: $e")),
                        );
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
