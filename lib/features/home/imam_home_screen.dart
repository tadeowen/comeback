import 'package:flutter/material.dart';
import '../chat/imam_chat_screen.dart';
import '../media/appoint.dart';
import '../media/imam_bar_graph.dart';
import '../media/quran.dart';
import '../profile/imam_profile.dart';

class ImamHomeScreen extends StatefulWidget {
  final String imamName;
  const ImamHomeScreen({super.key, required this.imamName});

  @override
  State<ImamHomeScreen> createState() => _ImamHomeScreenState();
}

class _ImamHomeScreenState extends State<ImamHomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  String _duaText = "";
  String _duaTranslation = "";

  // 10 authentic Duas that cycle based on day of month
  final List<Map<String, String>> _dailyDuas = [
    {
      "arabic": "اللهم بك أصبحنا وبك أمسينا، وبك نحيا وبك نموت، وإليك النشور",
      "translation":
          "O Allah, by You we enter the morning and by You we enter the evening, by You we live and by You we die, and to You is the final return."
    },
    {
      "arabic": "اللهم إني أسألك علماً نافعاً، ورزقاً طيباً، وعملاً متقبلاً",
      "translation":
          "O Allah, I ask You for beneficial knowledge, good provision, and accepted deeds"
    },
    {
      "arabic":
          "اللهم احفظني من بين يدي ومن خلفي وعن يميني وعن شمالي ومن فوقي وأعوذ بعظمتك أن أغتال من تحتي",
      "translation":
          "O Allah, protect me from my front, behind me, from my right and my left, and from above me, and I seek refuge in Your greatness from being taken unaware from beneath me"
    },
    {
      "arabic":
          "اللهم إني أعوذ بك من الهم والحزن، والعجز والكسل، والجبن والبخل، وضلع الدين وغلبة الرجال",
      "translation":
          "O Allah, I seek refuge in You from grief and sadness, from weakness and laziness, from miserliness and cowardice, from being overcome by debt and overpowered by men"
    },
    {
      "arabic": "اللهم آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار",
      "translation":
          "O Allah, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire"
    },
    {
      "arabic": "اللهم إني أسألك العفو والعافية في الدنيا والآخرة",
      "translation":
          "O Allah, I ask You for pardon and well-being in this life and the next"
    },
    {
      "arabic":
          "اللهم إني أعوذ بك من زوال نعمتك، وتحول عافيتك، وفجاءة نقمتك، وجميع سخطك",
      "translation":
          "O Allah, I seek refuge in You from the decline of Your blessings, the withdrawal of Your protection, the suddenness of Your punishment, and all that may incur Your wrath"
    },
    {
      "arabic":
          "اللهم إني أعوذ بك من علم لا ينفع، ومن قلب لا يخشع، ومن نفس لا تشبع، ومن دعوة لا يستجاب لها",
      "translation":
          "O Allah, I seek refuge in You from knowledge that does not benefit, from a heart that does not humble itself, from a soul that is never satisfied, and from a supplication that is not answered"
    },
    {
      "arabic": "اللهم إني أعوذ بك من منكرات الأخلاق والأعمال والأهواء",
      "translation":
          "O Allah, I seek refuge in You from objectionable character, deeds, and desires"
    },
    {
      "arabic":
          "اللهم طهر قلبي من النفاق، وعملي من الرياء، ولساني من الكذب، وعيني من الخيانة",
      "translation":
          "O Allah, purify my heart from hypocrisy, my deeds from showing off, my tongue from lies, and my eyes from treachery"
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadDailyDua();
    _pages = [
      _buildHomePage(),
      const QuranHomePage(),
      const ImamChatScreen(),
      const ImamHadithSetupScreen(),
      const ImamRatingAnalyticsScreen(),
      const MuslimSettingsScreen(imamName: 'Imam'), // Pass the imam's name
    ];
  }

  void _loadDailyDua() {
    // Get day of month (1-31) to cycle through Duas
    final dayOfMonth = DateTime.now().day;
    final duaIndex = (dayOfMonth - 1) % _dailyDuas.length; // 0-based index

    setState(() {
      _duaText = _dailyDuas[duaIndex]['arabic']!;
      _duaTranslation = _dailyDuas[duaIndex]['translation']!;
    });
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque, size: 80, color: Colors.teal.shade800),
            const SizedBox(height: 20),
            Text(
              "Assalamu Alaikum, ${widget.imamName}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 30),

            // Dua Card
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Daily Dua (Day ${DateTime.now().day})",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Text(
                          _duaText,
                          style: const TextStyle(
                            fontSize: 22,
                            height: 1.8,
                            fontFamily: 'Amiri',
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _duaTranslation,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "May your day be filled with blessings.",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Use the navigation below to access your tasks.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text("Welcome, ${widget.imamName}"),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 4,
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Quran"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Setup"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Status"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
