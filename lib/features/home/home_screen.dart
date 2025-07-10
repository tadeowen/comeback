import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  final String studentName;

  const HomeScreen({super.key, required this.studentName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<String> bibleVerses = [
    "For I know the plans I have for you - Jer 29:11",
    "I can do all things through Christ - Phil 4:13",
    "The Lord is my shepherd - Psalm 23:1",
    "Trust in the Lord with all your heart - Prov 3:5",
    "Be strong and courageous - Joshua 1:9",
    "For God so loved the world that he gave his only son that whoever believes in him shall not perish but have eternal life - John 3:16",
    "In all things God works for the good - Romans 8:28",
    "The Lord will fight for you - Exodus 14:14",
    "Cast all your anxiety on him - 1 Peter 5:7",
    "Delight yourself in the Lord - Psalm 37:4",
    "The Lord is close to the brokenhearted - Psalm 34:18",
    "He heals the brokenhearted - Psalm 147:3",
  ];

  int currentVerseIndex = 0;
  Timer? _verseTimer;
  double _opacity = 1.0;

  final List<Map<String, String>> priests = [
    {"name": "Pr.Bugembe", "image": "assets/images/pr1.jpg"},
    {"name": "Pr.Sempa", "image": "assets/images/pr2.jpg"},
    {"name": "Pr.Phaneroo", "image": "assets/images/pr3.jpg"},
    {"name": "Pr.Kayanja Robert", "image": "assets/images/pr4.jpg"},
    {"name": "Pr.Ssenyonga", "image": "assets/images/pr5.jpg"},
    {"name": "Rev.Lydia Kitayimbwa", "image": "assets/images/pr6.jpg"},
    {"name": "Fr. Josephat Ddungu", "image": "assets/images/pr7.jpg"},
  ];

  final List<Map<String, String>> featuredPriests = [
    {"name": "Pr.Kayanja Robert", "image": "assets/images/pr4.jpg"},
    {"name": "Pr.Ssenyonga", "image": "assets/images/pr5.jpg"},
  ];

  final List<Map<String, String>> chapels = [
    {"name": "St.Augustine's Chapel", "image": "assets/images/ch1.jpg"},
    {"name": "St.Francis' Chapel", "image": "assets/images/ch2.jpg"},
  ];

  List<Map<String, String>> filteredPriests = [];
  List<Map<String, String>> filteredChapels = [];

  final TextEditingController searchController = TextEditingController();

  // For notification badge bounce animation
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    filteredPriests = priests;
    filteredChapels = chapels;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Cycle Bible verses with fade animation
    _verseTimer = Timer.periodic(const Duration(seconds: 6), (_) async {
      // Fade out
      setState(() => _opacity = 0.0);
      await Future.delayed(const Duration(milliseconds: 800));
      // Change verse
      setState(() {
        currentVerseIndex = (currentVerseIndex + 1) % bibleVerses.length;
      });
      // Fade in
      setState(() => _opacity = 1.0);
    });
  }

  @override
  void dispose() {
    _verseTimer?.cancel();
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void filterSearchResults(String query) {
    final resultsPriests = priests.where((priest) {
      final name = priest['name']!.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    final resultsChapels = chapels.where((chapel) {
      final name = chapel['name']!.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPriests = resultsPriests;
      filteredChapels = resultsChapels;
    });
  }

  Stream<int> unreadNotificationCountStream(String email) {
    return FirebaseFirestore.instance
        .collection('prayer_requests')
        .where('studentEmail', isEqualTo: email)
        .where('replyRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  void _showNotificationsDialog(BuildContext context, String userEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Prayer Replies'),
          content: SizedBox(
            width: double.maxFinite,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prayer_requests')
                  .where('studentEmail', isEqualTo: userEmail)
                  .where('replyRead', isEqualTo: false)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No new replies.');
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['requestText'] ?? 'Prayer Request'),
                      subtitle:
                          Text('Reply: ${data['reply'] ?? 'No reply yet.'}'),
                      trailing: Text(
                        data['timestamp'] != null
                            ? (data['timestamp'] as Timestamp)
                                .toDate()
                                .toLocal()
                                .toString()
                                .substring(0, 16)
                            : '',
                        style: const TextStyle(fontSize: 10),
                      ),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('prayer_requests')
                            .doc(docs[index].id)
                            .update({'replyRead': true});
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close')),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              )),
          Text("See All",
              style: TextStyle(
                fontSize: 14,
                color: Colors.deepPurple.shade300,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _buildPriestCard(Map<String, String> priest) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.shade100.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 32,
            backgroundImage: AssetImage(priest["image"]!),
          ),
          const SizedBox(height: 8),
          Text(
            priest["name"]!,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFeaturedPriestCard(Map<String, String> priest) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.shade200.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6))
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FF7), Color(0xFFB9ACF3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              priest["image"]!,
              width: double.infinity,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            priest["name"]!,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildChapelCard(Map<String, String> chapel) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.brown.shade200,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.brown.shade400.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset(
              chapel["image"]!,
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            chapel["name"]!,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.brown),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: Text("Hello ${widget.studentName}!"),
        backgroundColor: Colors.deepPurple,
        elevation: 8,
        actions: [
          StreamBuilder<int>(
            stream: unreadNotificationCountStream(userEmail),
            builder: (context, snapshot) {
              int count = snapshot.data ?? 0;

              return ScaleTransition(
                scale: _bounceAnimation,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () =>
                          _showNotificationsDialog(context, userEmail),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Bible Verse
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2FF7), Color(0xFFB9ACF3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade200.withOpacity(0.6),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Text(
                  bibleVerses[currentVerseIndex],
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Search Bar with shadow and rounded corners
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade100.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterSearchResults,
                decoration: InputDecoration(
                  hintText: 'Search for a priest or chapel...',
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.deepPurple),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                cursorColor: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 28),

            _buildSectionHeader("Priests"),
            const SizedBox(height: 12),

            SizedBox(
              height: 130,
              child: filteredPriests.isEmpty
                  ? const Center(child: Text("No priests found."))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: filteredPriests.map(_buildPriestCard).toList(),
                    ),
            ),

            const SizedBox(height: 28),

            _buildSectionHeader("Featured Priests"),
            const SizedBox(height: 12),

            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    featuredPriests.map(_buildFeaturedPriestCard).toList(),
              ),
            ),

            const SizedBox(height: 28),

            _buildSectionHeader("Chapels"),
            const SizedBox(height: 12),

            SizedBox(
              height: 180,
              child: filteredChapels.isEmpty
                  ? const Center(child: Text("No chapels found."))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: filteredChapels.map(_buildChapelCard).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
