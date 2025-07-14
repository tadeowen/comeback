import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ImamDetailScreen extends StatefulWidget {
  final String imamId;
  final String imamName;
  final String? profilePicUrl;

  const ImamDetailScreen({
    super.key,
    required this.imamId,
    required this.imamName,
    this.profilePicUrl,
  });

  @override
  State<ImamDetailScreen> createState() => _ImamDetailScreenState();
}

class _ImamDetailScreenState extends State<ImamDetailScreen> {
  final Color starColor = Colors.amber;
  final double starSize = 36;

  List<String> responsibilities = [];
  String? selectedCategory;
  final TextEditingController messageController = TextEditingController();
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadResponsibilities();
  }

  Future<void> _loadResponsibilities() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.imamId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      final List<dynamic>? resp = data['responsibilities'];
      if (resp != null) {
        setState(() {
          responsibilities = resp.cast<String>();
          if (responsibilities.isNotEmpty) {
            selectedCategory = responsibilities[0];
          }
        });
      }
    }
  }

  Future<void> _submitPrayerRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (selectedCategory == null || messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a category and enter a message')),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to submit a request')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('dua_request').add({
        'imamId': widget.imamId,
        'imamName': widget.imamName,
        'category': selectedCategory,
        'message': messageController.text.trim(),
        'timestamp': Timestamp.now(),
        'studentId': user.uid,
        'studentEmail': user.email,
        'status': 'pending',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prayer request submitted successfully!')),
      );
      messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.imamName),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: widget.profilePicUrl != null &&
                            widget.profilePicUrl!.isNotEmpty
                        ? NetworkImage(widget.profilePicUrl!)
                        : const AssetImage('assets/default_imam_avatar.png')
                            as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.imamName,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // ✅ FIXED: Load ratings from top-level 'imamRatings'
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('imamRatings')
                        .where('imamId', isEqualTo: widget.imamId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Text('No ratings yet');
                      }

                      final ratings = docs
                          .map((doc) => doc['rating'])
                          .where((r) => r != null)
                          .map((r) => (r as num).toDouble())
                          .toList();

                      final avgRating = ratings.isNotEmpty
                          ? ratings.reduce((a, b) => a + b) / ratings.length
                          : 0.0;

                      return Column(
                        children: [
                          RatingBarIndicator(
                            rating: avgRating,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: starColor,
                            ),
                            itemCount: 5,
                            itemSize: starSize,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${avgRating.toStringAsFixed(1)} from ${ratings.length} review${ratings.length > 1 ? "s" : ""}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (responsibilities.isEmpty) ...[
              const Text(
                'No responsibilities found for this Imam.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ] else ...[
              Text(
                'Imam Responsibilities:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: responsibilities
                    .map((resp) => Chip(label: Text(resp)))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Submit a Prayer Request',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: responsibilities
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedCategory = val),
                decoration: const InputDecoration(
                  labelText: 'Select category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Enter your prayer request message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitPrayerRequest,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Prayer Request'),
              ),
              const SizedBox(height: 32),
              Text(
                'Your Previous Requests to This Imam',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('dua_request')
                    .where('imamId', isEqualTo: widget.imamId)
                    .where('studentId', isEqualTo: currentUser?.uid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Text('No previous prayer requests submitted.');
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final message = doc['message'] ?? '';
                      final category = doc['category'] ?? '';
                      final status = doc['status'] ?? 'pending';
                      final time = (doc['timestamp'] as Timestamp).toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.message),
                          title: Text(category),
                          subtitle: Text(message),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                status.toString().toUpperCase(),
                                style: TextStyle(
                                  color: status == 'approved'
                                      ? Colors.green
                                      : (status == 'rejected'
                                          ? Colors.red
                                          : Colors.orange),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${time.day}/${time.month}/${time.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
