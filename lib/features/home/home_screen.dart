import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final String studentName;
  const HomeScreen({super.key, required this.studentName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<String> fetchBibleVerse(String reference) async {
  final url = Uri.parse('https://bible-api.com/$reference');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return "${data['text'].trim()} – ${data['reference']}";
  } else {
    return "Verse not found.";
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final verses = [
    "“For I know the plans I have for you,” declares the Lord – Jeremiah 29:11",
    "“I can do all things through Christ who strengthens me.” – Philippians 4:13",
    "“Be still and know that I am God.” – Psalm 46:10",
    "“The Lord is my shepherd, I lack nothing.” – Psalm 23:1"
  ];
  int verseIndex = 0;
  Timer? verseTimer;
  double opacity = 1.0;

  final searchCtrl = TextEditingController();
  String searchQuery = '';

  late AnimationController animCtrl;
  late Animation<double> bounce;

  @override
  void initState() {
    super.initState();
    animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    bounce = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: animCtrl, curve: Curves.easeInOut),
    );

    verseTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      setState(() => opacity = 0);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        verseIndex = (verseIndex + 1) % verses.length;
        opacity = 1.0;
      });
    });
  }

  @override
  void dispose() {
    verseTimer?.cancel();
    animCtrl.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  Stream<int> get notificationCount {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return FirebaseFirestore.instance
        .collection('prayer_requests')
        .where('studentEmail', isEqualTo: email)
        .where('replyRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  void searchChanged(String q) => setState(() => searchQuery = q.toLowerCase());

  void openPriestDetail(String id) {
    Navigator.pushNamed(context, '/priestDetail', arguments: id);
  }

  void openChurchDetail(String church) {
    Navigator.pushNamed(context, '/churchDetail', arguments: church);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: Text("Hello, ${widget.studentName}"),
        backgroundColor: Colors.deepPurple,
        actions: [
          StreamBuilder<int>(
            stream: notificationCount,
            builder: (_, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: ScaleTransition(
                        scale: bounce,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // comeback Verse Carousel
              AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B2FF7), Color(0xFFB9ACF3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Text(
                    verses[verseIndex],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              //  Search Field
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: searchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Search for priests, churches...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Priests by Church
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('leaders')
                    .orderBy('church')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs.where((d) {
                    final name = (d['name'] ?? '').toString().toLowerCase();
                    final church =
                        (d['church'] ?? 'Other').toString().toLowerCase();

                    return name.contains(searchQuery) ||
                        church.contains(searchQuery);
                  }).toList();

                  final grouped = <String, List<QueryDocumentSnapshot>>{};
                  for (var d in docs) {
                    final church = (d['church'] ?? 'Other').toString();

                    grouped.putIfAbsent(church, () => []).add(d);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: grouped.entries.map((entry) {
                      final church = entry.key;
                      final list = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => openChurchDetail(church),
                            child: Text(
                              church,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: list.length,
                              itemBuilder: (_, i) {
                                final d = list[i];
                                final img = d['imageUrl'] ??
                                    'https://via.placeholder.com/150';
                                final name = d['name'] ?? 'Unnamed';
                                return GestureDetector(
                                  onTap: () => openPriestDetail(d.id),
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 6)
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(img),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Icon(Icons.church_outlined,
                                            size: 18, color: Colors.deepPurple),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }).toList(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
