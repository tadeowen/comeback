import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../media/quran_page.dart';
import '../chat/islam_chat_screen.dart';
import '../prayer/islam_prayer_request.dart';
// import '../profile/islam_profile_screen.dart'; // Optional

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
      // MuslimSettingsScreen(studentName: widget.studentName), // Your real settings screen here
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
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Qur’an'),
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

          // 🔍 Search Field
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

          // 📡 Imam List
          SizedBox(
            height: 170,
            child: StreamBuilder<QuerySnapshot>(
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
                  return const Text('No featured Imams found.');
                }

                final imams = snapshot.data!.docs.where((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchTerm);
                }).toList();

                if (imams.isEmpty) {
                  return const Center(
                      child: Text('No Imams match your search.'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imams.length,
                  itemBuilder: (context, index) {
                    final imam = imams[index].data()! as Map<String, dynamic>;
                    final name = imam['name'] ?? 'Unnamed Imam';
                    final picUrl = imam['profilePicUrl'] as String?;

                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: picUrl != null && picUrl.isNotEmpty
                                ? NetworkImage(picUrl)
                                : const AssetImage(
                                        'assets/default_imam_avatar.png')
                                    as ImageProvider,
                            backgroundColor: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
