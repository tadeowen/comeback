import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../media/quran_page.dart';
import '../media/quran_sevice_class.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with error handling
  try {
    await Hive.initFlutter();
    await Hive.openBox('quran_cache');
    print('Hive initialized successfully');
  } catch (e) {
    print('Hive initialization error: $e');
  }

  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const QuranHomePage(),
    );
  }
}

class QuranHomePage extends StatefulWidget {
  const QuranHomePage({Key? key}) : super(key: key);

  @override
  State<QuranHomePage> createState() => _QuranHomePageState();
}

class _QuranHomePageState extends State<QuranHomePage> {
  final QuranService _quranService = QuranService();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final isOnline = await _quranService.isOnline;
    if (mounted) {
      setState(() => _isOnline = isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: const Text('Quran Pages'),
        actions: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            color: _isOnline ? Colors.white : Colors.amber,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        itemCount: 604,
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          return ListTile(
            title: Text('Page $pageNumber'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranPage(pageNumber: pageNumber),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.download),
        onPressed: () async {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Downloading essential pages...')),
          );
          try {
            await _quranService.preCacheEssentialPages();
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Essential pages cached!')),
            );
          } catch (e) {
            scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('Failed: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }
}
