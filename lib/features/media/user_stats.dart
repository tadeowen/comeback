import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatsPage extends StatelessWidget {
  final String userId;

  const UserStatsPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Statistics")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserStats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final stats = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                StatCard(
                  title: "Most Selected Category",
                  value: stats['topCategory'] ?? "None",
                  icon: Icons.category,
                ),
                StatCard(
                  title: "Most Selected Imam",
                  value: stats['topImam'] ?? "None",
                  icon: Icons.person,
                  // Add any additional information or styling here
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUserStats(String userId) async {
    final QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('user_selections')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'category')
        .get();

    final QuerySnapshot imamSnapshot = await FirebaseFirestore.instance
        .collection('user_selections')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'imam')
        .get();

    // Calculate most frequent category/imam
    String topCategory =
        _findMostFrequent(categorySnapshot.docs, 'selectedName');
    String topImam = _findMostFrequent(imamSnapshot.docs, 'selectedName');

    return {
      'topCategory': topCategory,
      'topImam': topImam,
    };
  }

  String _findMostFrequent(List<QueryDocumentSnapshot> docs, String field) {
    if (docs.isEmpty) return "None";
    final frequencyMap = <String, int>{};
    for (final doc in docs) {
      final key = doc[field] as String;
      frequencyMap[key] = (frequencyMap[key] ?? 0) + 1;
    }
    return frequencyMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
