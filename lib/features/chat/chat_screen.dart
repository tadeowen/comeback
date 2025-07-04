import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  bool? _isAnonymous;
  String _profileName = 'Anonymous';
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _askUserPreference();
    _controller.addListener(_handleTyping);
  }

  void _handleTyping() {
    setState(() {
      _isTyping = _controller.text.isNotEmpty;
    });
  }

  Future<void> _askUserPreference() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      _profileName = doc['name'] ?? 'Anonymous';
    }

    await Future.delayed(Duration.zero);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Chat Privacy'),
          content: const Text('Do you want to chat anonymously or show your name?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isAnonymous = true;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Anonymous'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isAnonymous = false;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Show My Name'),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final senderName = _isAnonymous == true ? 'Anonymous' : _profileName;

    await FirebaseFirestore.instance.collection('chats').add({
      'text': _controller.text.trim(),
      'createdAt': Timestamp.now(),
      'sender': senderName,
      'userId': user?.uid ?? 'anonymous',
    });

    _controller.clear();
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF8BC34A) : const Color(0xFF795548),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              data['sender'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data['text'],
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chatDocs = chatSnapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    final data = chatDocs[index];
                    final isMe = data['userId'] == user?.uid;
                    return _buildMessageBubble(
                      data.data() as Map<String, dynamic>,
                      isMe,
                    );
                  },
                );
              },
            ),
          ),

          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'You are typing...',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF8BC34A),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
