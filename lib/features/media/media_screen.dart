// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PrayerRoomsScreen extends StatelessWidget {
//   const PrayerRoomsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
//     final DateTime now = DateTime.now();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Prayer Rooms'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text(
//               'Your Active Appointments',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             // 🔄 Real-time Scheduled Sessions for this Priest
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('sessions')
//                     .where('priestId', isEqualTo: uid)
//                     .where('startTime',
//                         isGreaterThan:
//                             now.subtract(const Duration(minutes: 10)))
//                     .orderBy('startTime')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }

//                   final docs = snapshot.data?.docs ?? [];
//                   if (docs.isEmpty) {
//                     return const Center(child: Text('No active sessions.'));
//                   }

//                   return ListView.builder(
//                     itemCount: docs.length,
//                     itemBuilder: (context, index) {
//                       final doc = docs[index];
//                       final data = doc.data() as Map<String, dynamic>;
//                       return PrayerRoomCard(
//                         sessionId: doc.id,
//                         sessionData: data,
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PrayerRoomCard extends StatelessWidget {
//   final String sessionId;
//   final Map<String, dynamic> sessionData;

//   const PrayerRoomCard({
//     super.key,
//     required this.sessionId,
//     required this.sessionData,
//   });

//   // 📌 Lock code generated from a mathematical hash on time
//   String get lockCode {
//     final int seed =
//         (sessionData['startTime'] as Timestamp).toDate().millisecondsSinceEpoch;
//     final int generated = Random(seed).nextInt(900000) + 100000;
//     return generated.toString();
//   }

//   // ✅ Session Validity Checker
//   bool get isLive {
//     final start = (sessionData['startTime'] as Timestamp).toDate();
//     final end = (sessionData['endTime'] as Timestamp).toDate();
//     final now = DateTime.now();

//     return now.isAfter(start.subtract(const Duration(minutes: 10))) &&
//         now.isBefore(end.add(const Duration(minutes: 10)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String studentName = sessionData['studentName'] ?? 'Student';
//     final DateTime start = (sessionData['startTime'] as Timestamp).toDate();

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         leading: Icon(
//           isLive ? Icons.lock_open : Icons.lock_clock,
//           size: 30,
//           color: isLive ? Colors.green : Colors.orange,
//         ),
//         title: Text(
//           '$studentName • ${start.hour}:${start.minute.toString().padLeft(2, '0')}',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           isLive
//               ? 'Room active. Lock code: $lockCode'
//               : 'Scheduled at ${start.toLocal().toString().substring(0, 16)}',
//         ),
//         trailing: isLive
//             ? ElevatedButton.icon(
//                 onPressed: () => _joinRoom(context),
//                 icon: const Icon(Icons.login),
//                 label: const Text('Join'),
//               )
//             : null,
//         onTap: isLive ? () => _showCodeDialog(context) : null,
//       ),
//     );
//   }

//   void _showCodeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Room Lock Code'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Share this code with your student:'),
//             const SizedBox(height: 12),
//             SelectableText(
//               lockCode,
//               style: const TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 2,
//                 color: Colors.deepPurple,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             child: const Text('Done'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   void _joinRoom(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => LiveRoomPage(
//           roomId: sessionId,
//           lockCode: lockCode,
//         ),
//       ),
//     );
//   }
// }

// class LiveRoomPage extends StatelessWidget {
//   final String roomId;
//   final String lockCode;

//   const LiveRoomPage({
//     super.key,
//     required this.roomId,
//     required this.lockCode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // Replace with voice/video/chat logic later
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Prayer Room'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.mic, size: 80, color: Colors.deepPurple.shade300),
//             const SizedBox(height: 20),
//             Text(
//               'Live session for room ID:\n$roomId',
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 20),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Access code: $lockCode',
//               style: const TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.deepPurple,
//               ),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.exit_to_app),
//               label: const Text('Leave Room'),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'bible_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const BibleHomePage(),
    );
  }
}

class BibleHomePage extends StatefulWidget {
  const BibleHomePage({super.key});

  @override
  State<BibleHomePage> createState() => _BibleHomePageState();
}

class _BibleHomePageState extends State<BibleHomePage> {
  List<String> chapters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  Future<void> loadChapters() async {
    // Simulate chapter list instead of fetching book names
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      chapters = List<String>.generate(50, (index) => 'Chapter ${index + 1}');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bible Chapters')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapterNumber = index + 1;
                return ListTile(
                  title: Text('Chapter $chapterNumber'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BiblePage(chapterNumber: chapterNumber),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
