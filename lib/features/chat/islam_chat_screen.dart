import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IslamChatScreen extends StatefulWidget {
  const IslamChatScreen({super.key});

  @override
  State<IslamChatScreen> createState() => _IslamChatScreenState();
}

class _IslamChatScreenState extends State<IslamChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isAnonymous = false;

  Future<void> _sendMessage() async {
    final user = _auth.currentUser;
    if (user == null || _controller.text.trim().isEmpty) return;

    await user.reload(); // ✅ Make sure we have the latest displayName
    final refreshedUser = _auth.currentUser;
    final nameToUse = _isAnonymous
        ? 'Anonymous'
        : (refreshedUser?.displayName?.trim().isNotEmpty == true
            ? refreshedUser!.displayName
            : 'Unknown User');

    await FirebaseFirestore.instance.collection('chats').add({
      'text': _controller.text.trim(),
      'uid': refreshedUser?.uid,
      'name': nameToUse,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 📨 Messages
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!.docs;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (ctx, index) {
                  final msg = messages[index];
                  final isMe = msg['uid'] == _auth.currentUser?.uid;
                  final name = msg['name']?.toString() ?? 'Anonymous';
                  final text = msg['text']?.toString() ?? '';

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? (isDark ? Colors.green[800] : Colors.green[100])
                            : (isDark ? Colors.grey[800] : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (name != 'Anonymous')
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          Text(
                            text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // 💬 Input + Switch
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _isAnonymous = !_isAnonymous);
                    },
                    icon: Icon(
                      _isAnonymous ? Icons.visibility_off : Icons.visibility,
                      color: const Color.fromARGB(255, 112, 63, 197),
                    ),
                    label: Text(
                      _isAnonymous ? 'Anonymous' : 'Public',
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message...',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
