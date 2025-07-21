import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserStatsPage extends StatelessWidget {
  final String? userId;

  const UserStatsPage({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? effectiveUserId =
        userId ?? FirebaseAuth.instance.currentUser?.uid;

    if (effectiveUserId == null) {
      return _buildAuthRequiredScreen(context);
    }

    return _UserStatsContent(userId: effectiveUserId);
  }

  Widget _buildAuthRequiredScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Statistics"),
        backgroundColor: Colors.teal[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                    const SizedBox(height: 24),
                    Text(
                      "Authentication Required",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "You must be logged in to view your statistics",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: const Text(
                        "Go to Login",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserStatsContent extends StatelessWidget {
  final String userId;

  const _UserStatsContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Statistics"),
        backgroundColor: Colors.teal[800],
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                print('First document: ${snapshot.data!.docs.first.data()}');
              }
            }
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (snapshot.hasError) {
            return Center(
              child: ErrorCard(error: snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: EmptyStateCard(userId: userId),
            );
          }

          final stats = _calculateStats(snapshot.data!.docs);
          return _buildStatsContent(context, stats);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[800]!),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading your statistics...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserHeader(context),
          const SizedBox(height: 16),
          _buildStatsRow(stats),
          const SizedBox(height: 16),
          _buildTopCategoryCard(stats),
          const SizedBox(height: 16),
          _buildTopImamCard(stats),
          const SizedBox(height: 16),
          _buildResolutionProgress(context, stats['resolutionRate']),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal[100],
                border: Border.all(
                  color: Colors.teal[300]!,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Statistics",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "User ID: ${userId.substring(0, 8)}...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Total Requests",
            value: stats['totalRequests'].toString(),
            icon: Icons.numbers,
            gradient: LinearGradient(
              colors: [
                Colors.orange[600]!,
                Colors.orange[400]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: "Resolved",
            value: stats['resolvedRequests'].toString(),
            icon: Icons.check_circle,
            gradient: LinearGradient(
              colors: [
                Colors.green[600]!,
                Colors.green[400]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            subtitle: "${stats['resolutionRate']}%",
          ),
        ),
      ],
    );
  }

  Widget _buildTopCategoryCard(Map<String, dynamic> stats) {
    return StatCard(
      title: "Top Category",
      value: _truncateText(stats['topCategory'] ?? "None", 15),
      icon: Icons.category,
      gradient: LinearGradient(
        colors: [
          Colors.teal[600]!,
          Colors.teal[400]!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      subtitle: stats['topCategory'] != "None"
          ? "${stats['topCategoryFrequency']} requests"
          : "",
      fullWidth: true,
    );
  }

  Widget _buildTopImamCard(Map<String, dynamic> stats) {
    return StatCard(
      title: "Top Imam",
      value: _truncateText(stats['topImam'] ?? "None", 15),
      icon: Icons.person,
      gradient: LinearGradient(
        colors: [
          Colors.blue[600]!,
          Colors.blue[400]!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      subtitle: stats['topImam'] != "None"
          ? "${stats['topImamFrequency']} requests"
          : "",
      fullWidth: true,
    );
  }

  Widget _buildResolutionProgress(BuildContext context, String rate) {
    final percentage = double.tryParse(rate) ?? 0;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Resolution Progress",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  "$rate%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 50 ? Colors.teal[400]! : Colors.orange[400]!,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "0%",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "50%",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "100%",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
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
  final Gradient? gradient;
  final bool fullWidth;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.gradient,
    this.fullWidth = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullWidth ? null : 140, // Fixed height for row cards
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              icon,
              size: fullWidth ? 40 : 30,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: fullWidth ? 16 : 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: fullWidth ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: fullWidth ? 14 : 12,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String error;

  const ErrorCard({required this.error, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.red[50],
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber, size: 60, color: Colors.red[400]),
                const SizedBox(height: 24),
                const Text(
                  "Error Loading Data",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error.length > 100 ? "${error.substring(0, 100)}..." : error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    // Add retry logic here
                  },
                  child: const Text(
                    "Try Again",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  final String userId;

  const EmptyStateCard({required this.userId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox, size: 60, color: Colors.teal[400]),
                const SizedBox(height: 24),
                const Text(
                  "No Prayer Requests Found",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "You haven't made any prayer requests yet.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "User ID: ${userId.substring(0, 8)}...",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    // Add navigation to create request
                  },
                  child: const Text(
                    "Make Your First Request",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
