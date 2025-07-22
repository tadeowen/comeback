import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class BibleService {
  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> preCacheEssentialChapters() async {
    final box = Hive.box('bible_cache');
    for (int i = 1; i <= 10; i++) {
      box.put('chapter_$i', 'This is the cached content of chapter $i.');
    }
  }

  String? getCachedChapter(int number) {
    final box = Hive.box('bible_cache');
    return box.get('chapter_$number');
  }
}
