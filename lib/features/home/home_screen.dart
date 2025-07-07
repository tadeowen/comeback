import 'dart:async';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String studentName;

  const HomeScreen({super.key, required this.studentName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  final List<Map<String, String>> priests = [
    {"name": "Pr.Bugembe", "image": "assets/images/pr1.jpg"},
    {"name": "Pr.Sempa", "image": "assets/images/pr2.jpg"},
    {"name": "Pr.Phaneroo", "image": "assets/images/pr3.jpg"},
    {"name": "Pr.Kayanja Robert", "image": "assets/images/pr4.jpg"},
    {"name": "Pr.Ssenyonga", "image": "assets/images/pr5.jpg"},
    {"name": "Rev.Lydia Kitayimbwa", "image": "assets/images/pr6.jpg"}
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

  @override
  void initState() {
    super.initState();
    filteredPriests = priests;
    filteredChapels = chapels;

    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        currentVerseIndex = (currentVerseIndex + 1) % bibleVerses.length;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text("Hello ${widget.studentName}!"),
        backgroundColor: Colors.brown,
        actions: const [
          Icon(Icons.notifications),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bible Verse Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                bibleVerses[currentVerseIndex],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            TextField(
              controller: searchController,
              onChanged: filterSearchResults,
              decoration: InputDecoration(
                hintText: 'Search for a priest or chapel...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.brown.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priests Section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Priests",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("See All"),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: filteredPriests.isEmpty
                  ? const Center(child: Text("No priests found."))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: filteredPriests.map((priest) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(priest["image"]!),
                                radius: 30,
                              ),
                              const SizedBox(height: 5),
                              Text(priest["name"]!,
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 24),

            // Featured Priests
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Featured Priests",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("See All"),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: featuredPriests.map((priest) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(priest["image"]!,
                              width: 120, height: 100, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 5),
                        Text(priest["name"]!,
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Chapels Section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Chapels",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("See All"),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: filteredChapels.isEmpty
                  ? const Center(child: Text("No chapels found."))
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: filteredChapels.map((chapel) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(chapel["image"]!,
                                    width: 120, height: 100, fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 5),
                              Text(chapel["name"]!,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
