import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserStatsPage extends StatelessWidget {
  final String? userId; // Make userId optional

  const UserStatsPage({
    Key? key,
    this.userId, // Remove required since we'll handle null case
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get user ID either from parameter or from FirebaseAuth
    final String? effectiveUserId =
        userId ?? FirebaseAuth.instance.currentUser?.uid;

    if (effectiveUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Statistics"),
          backgroundColor: Colors.teal[800],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.red[800]),
              const SizedBox(height: 20),
              const Text(
                "You must be logged in to view statistics",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return _UserStatsContent(userId: effectiveUserId);
  }
}

class _UserStatsContent extends StatelessWidget {
  final String userId;

  const _UserStatsContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Statistics"),
          backgroundColor: Colors.teal[800],
        ),
        body: SingleChildScrollView(
          // Add this wrapper
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('dua_request')
                .where('studentId', isEqualTo: userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (kDebugMode) {
                print('User ID: $userId');
                print('Connection state: ${snapshot.connectionState}');
                if (snapshot.hasError) print('Error: ${snapshot.error}');
                if (snapshot.hasData) {
                  print('Found ${snapshot.data!.docs.length} documents');
                  if (snapshot.data!.docs.isNotEmpty) {
                    print(
                        'First document: ${snapshot.data!.docs.first.data()}');
                  }
                }
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: Colors.teal[800]));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 50, color: Colors.teal[800]),
                      const SizedBox(height: 12),
                      const Text(
                        "No prayer requests found",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "User ID: $userId",
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final stats = _calculateStats(snapshot.data!.docs);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Add this
                  children: [
                    StatCard(
                      title: "Most Requested Category",
                      value: stats['topCategory'] ?? "None",
                      icon: Icons.category,
                      color: Colors.teal,
                      subtitle: stats['topCategory'] != "None"
                          ? "(${stats['topCategoryFrequency']} requests)"
                          : "",
                    ),
                    StatCard(
                      title: "Most Requested Imam",
                      value: stats['topImam'] ?? "None",
                      icon: Icons.person,
                      color: Colors.blue,
                      subtitle: stats['topImam'] != "None"
                          ? "(${stats['topImamFrequency']} requests)"
                          : "",
                    ),
                    StatCard(
                      title: "Total Requests",
                      value: stats['totalRequests'].toString(),
                      icon: Icons.numbers,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: "Resolved Requests",
                      value:
                          "${stats['resolvedRequests']} (${stats['resolutionRate']}%)",
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }

  Map<String, dynamic> _calculateStats(List<QueryDocumentSnapshot> docs) {
    final categoryResult = _findMostFrequent(docs, 'category');
    final imamResult = _findMostFrequent(docs, 'imamName');

    final resolvedRequests = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status']?.toString().toLowerCase() == 'resolved';
    }).length;

    final resolutionRate =
        (resolvedRequests / docs.length * 100).toStringAsFixed(1);

    return {
      'topCategory': categoryResult['value'],
      'topCategoryFrequency': categoryResult['frequency'],
      'topImam': imamResult['value'],
      'topImamFrequency': imamResult['frequency'],
      'totalRequests': docs.length,
      'resolvedRequests': resolvedRequests,
      'resolutionRate': resolutionRate,
    };
  }

  Map<String, dynamic> _findMostFrequent(
      List<QueryDocumentSnapshot> docs, String field) {
    final frequencyMap = <String, int>{};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final value = data[field];
      if (value != null) {
        final key = value.toString();
        frequencyMap[key] = (frequencyMap[key] ?? 0) + 1;
      }
    }

    if (frequencyMap.isEmpty) {
      return {'value': 'None', 'frequency': 0};
    }

    final mostFrequent =
        frequencyMap.entries.reduce((a, b) => a.value > b.value ? a : b);
    return {
      'value': mostFrequent.key,
      'frequency': mostFrequent.value,
    };
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color ?? Colors.teal[800]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color ?? Colors.teal[800],
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
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
