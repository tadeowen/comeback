import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../media/quran_page.dart';
import '../chat/islam_chat_screen.dart';
import '../prayer/islam_prayer_request.dart';

class IslamHomeScreen extends StatefulWidget {
  final String studentName;

  const IslamHomeScreen({super.key, required this.studentName});

  @override
  State<IslamHomeScreen> createState() => _IslamHomeScreenState();
}

class _IslamHomeScreenState extends State<IslamHomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      FeaturedImamsHome(studentName: widget.studentName),
      const QuranPage(),
      const IslamPrayerRequest(),
      const Center(child: Text("💡 Hadith")),
      const IslamChatScreen(),
      const Center(child: Text("Settings Placeholder")),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.studentName}!'),
        backgroundColor: Colors.green[700],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Quran'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Prayer Request'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Hadith'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class FeaturedImamsHome extends StatefulWidget {
  final String studentName;

  const FeaturedImamsHome({super.key, required this.studentName});

  @override
  State<FeaturedImamsHome> createState() => _FeaturedImamsHomeState();
}

class _FeaturedImamsHomeState extends State<FeaturedImamsHome> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🕌 Prayer Times (Today)', style: theme.titleMedium),
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fajr: 5:12 AM'),
                  Text('Dhuhr: 12:45 PM'),
                  Text('Asr: 4:20 PM'),
                  Text('Maghrib: 6:50 PM'),
                  Text('Isha: 8:10 PM'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('🌟 Featured Imams', style: theme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Imams by name...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              setState(() => _searchTerm = value.toLowerCase().trim());
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Imam')
                .where('religion', isEqualTo: 'Islam')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No featured Imams found.'));
              }

              final imams = snapshot.data!.docs.where((doc) {
                final data = doc.data()! as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                return name.contains(_searchTerm);
              }).toList();

              if (imams.isEmpty) {
                return const Center(child: Text('No Imams match your search.'));
              }

              return SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imams.length,
                  itemBuilder: (context, index) {
                    final imamDoc = imams[index];
                    final imam = imamDoc.data()! as Map<String, dynamic>;
                    final name = imam['name'] ?? 'Unnamed Imam';
                    final picUrl = imam['profilePicUrl'] as String?;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImamDetailScreen(
                              imamId: imamDoc.id,
                              imamName: name,
                              profilePicUrl: picUrl,
                            ),
                          ),
                        );
                      },
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('imamRatings')
                            .where('imamId', isEqualTo: imamDoc.id)
                            .snapshots(),
                        builder: (context, ratingSnapshot) {
                          if (!ratingSnapshot.hasData) {
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.only(right: 12),
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            );
                          }

                          final ratings = ratingSnapshot.data!.docs;
                          final totalRatings = ratings.length;
                          double avgRating = 0;

                          if (totalRatings > 0) {
                            final totalStars = ratings.fold(0, (sum, doc) {
                              final rating = doc['rating'] as num;
                              return sum + rating.toInt();
                            });
                            avgRating = totalStars / totalRatings;
                          }

                          return Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundImage: picUrl != null &&
                                          picUrl.isNotEmpty
                                      ? NetworkImage(picUrl)
                                      : const AssetImage(
                                              'assets/default_imam_avatar.png')
                                          as ImageProvider,
                                  backgroundColor: Colors.grey[300],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      avgRating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Text(
                                  '($totalRatings)',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ImamDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(imamName),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('imamRatings')
            .where('imamId', isEqualTo: imamId)
            .snapshots(),
        builder: (context, ratingSnapshot) {
          if (!ratingSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final ratings = ratingSnapshot.data!.docs;
          final totalReviews = ratings.length;
          double averageRating = 0;

          if (totalReviews > 0) {
            final totalStars = ratings.fold(0, (sum, doc) {
              final rating = doc['rating'] as num;
              return sum + rating.toInt();
            });
            averageRating = totalStars / totalReviews;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Imam Profile Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: profilePicUrl != null &&
                                profilePicUrl!.isNotEmpty
                            ? NetworkImage(profilePicUrl!)
                            : const AssetImage('assets/default_imam_avatar.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        imamName,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Ratings Summary Section
                Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    RatingBarIndicator(
                      rating: averageRating,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 32.0,
                      direction: Axis.horizontal,
                    ),
                    Text(
                      '$totalReviews review${totalReviews != 1 ? "s" : ""}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                  ],
                ),

                // Individual Reviews Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'User Reviews',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (totalReviews == 0)
                  const Center(child: Text('No reviews yet'))
                else
                  ...ratings.map((ratingDoc) {
                    final rating = ratingDoc.data() as Map<String, dynamic>;
                    final stars = (rating['rating'] as num).toInt();
                    final timestamp =
                        (rating['timestamp'] as Timestamp).toDate();
                    final reviewerId = rating['studentId'] as String;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(reviewerId)
                          .get(),
                      builder: (context, userSnapshot) {
                        String reviewerName = 'Anonymous';
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          final userData = userSnapshot.data!.data()
                              as Map<String, dynamic>?;
                          if (userData != null && userData['name'] != null) {
                            reviewerName = userData['name'] as String;
                          }
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        reviewerName
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      reviewerName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star,
                                      color: i < stars
                                          ? Colors.amber
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Reviewed on ${timestamp.toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
