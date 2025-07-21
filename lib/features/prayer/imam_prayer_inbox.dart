import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImamPrayerInboxScreen extends StatefulWidget {
  const ImamPrayerInboxScreen({super.key});

  @override
  State<ImamPrayerInboxScreen> createState() => _ImamPrayerInboxScreenState();
}

class _ImamPrayerInboxScreenState extends State<ImamPrayerInboxScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Public',
    'Private',
    'Answered',
    'Unanswered',
    'Pending',
    'Resolved',
  ];
  bool _isLoading = false;

  Stream<QuerySnapshot> getPrayerRequestsForCurrentImam() {
    final imamId = FirebaseAuth.instance.currentUser?.uid;
    debugPrint("📥 Current Imam UID: $imamId");

    if (imamId == null) {
      return const Stream<QuerySnapshot>.empty();
    }

    Query query = FirebaseFirestore.instance
        .collection('dua_request')
        .where('imamId', isEqualTo: imamId)
        .orderBy('timestamp', descending: true);

    // Apply filters
    if (_selectedFilter == 'Public') {
      query = query.where('visibility', isEqualTo: 'Public');
    } else if (_selectedFilter == 'Private') {
      query = query.where('visibility', isEqualTo: 'Private');
    } else if (_selectedFilter == 'Answered') {
      query = query.where('isAnswered', isEqualTo: true);
    } else if (_selectedFilter == 'Unanswered') {
      query = query.where('isAnswered', isEqualTo: false);
    } else if (_selectedFilter == 'Pending') {
      query = query.where('status', isEqualTo: 'pending');
    } else if (_selectedFilter == 'Resolved') {
      query = query.where('status', isEqualTo: 'resolved');
    }

    return query.snapshots();
  }

  Future<void> _markAsAnswered(String requestId) async {
    try {
      setState(() => _isLoading = true);
      await FirebaseFirestore.instance
          .collection('dua_request')
          .doc(requestId)
          .update({
        'isAnswered': true,
        'status': 'resolved', // This updates the status for the student view
        'answeredAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as answered & resolved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        setState(() => _isLoading = true);
        await FirebaseFirestore.instance
            .collection('dua_request')
            .doc(requestId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📨 Prayer Requests Inbox"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => _filterOptions.map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No ${_selectedFilter == 'All' ? '' : _selectedFilter.toLowerCase() + ' '}requests found',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final doc = requests[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final message = data['message'] ?? '';
                    final isPublic = data['visibility'] == 'Public';
                    final category = data['category'] ?? 'No category';
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final formattedTime =
                        DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
                    final displayName = isPublic
                        ? "${data['studentName'] ?? 'Unnamed'}\n${data['studentEmail'] ?? ''}"
                        : "Anonymous";
                    final isAnswered = data['isAnswered'] ?? false;
                    final status = data['status'] ?? 'pending';
                    final answeredAt = data['answeredAt'] != null
                        ? DateFormat('dd MMM yyyy, hh:mm a')
                            .format((data['answeredAt'] as Timestamp).toDate())
                        : null;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      color: isAnswered ? Colors.grey[100] : null,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _showRequestDetails(context, data);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      message,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isAnswered)
                                    const Icon(Icons.check_circle,
                                        color: Colors.green, size: 20),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Chip(
                                    label: Text(category),
                                    backgroundColor: Colors.teal[50],
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Chip(
                                    label:
                                        Text(isPublic ? 'Public' : 'Private'),
                                    backgroundColor: isPublic
                                        ? Colors.blue[50]
                                        : Colors.purple[50],
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Chip(
                                    label: Text(status.toUpperCase()),
                                    backgroundColor: status == 'resolved'
                                        ? Colors.green[50]
                                        : Colors.orange[50],
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text("From: $displayName",
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text("Sent at: $formattedTime",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              if (isAnswered && answeredAt != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text("Answered at: $answeredAt",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontStyle: FontStyle.italic)),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isAnswered)
                                    TextButton(
                                      onPressed: () => _markAsAnswered(doc.id),
                                      child: const Text('Mark as Answered'),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        size: 20, color: Colors.red),
                                    onPressed: () => _deleteRequest(doc.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> data) {
    final isPublic = data['visibility'] == 'Public';
    final displayName = isPublic
        ? "${data['studentName'] ?? 'Unnamed'}\n${data['studentEmail'] ?? ''}"
        : "Anonymous";
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    final formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
    final isAnswered = data['isAnswered'] ?? false;
    final status = data['status'] ?? 'pending';
    final answeredAt = data['answeredAt'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a')
            .format((data['answeredAt'] as Timestamp).toDate())
        : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prayer Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data['message'] ?? '', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildDetailRow('Category:', data['category'] ?? 'No category'),
              _buildDetailRow('Visibility:', isPublic ? 'Public' : 'Private'),
              _buildDetailRow('Status:', status.toUpperCase(),
                  color: status == 'resolved' ? Colors.green : Colors.orange),
              _buildDetailRow('From:', displayName),
              _buildDetailRow('Sent at:', formattedTime),
              if (isAnswered && answeredAt != null)
                _buildDetailRow('Answered at:', answeredAt,
                    color: Colors.green),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: color ?? Colors.black)),
          ),
        ],
      ),
    );
  }
}
