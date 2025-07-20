import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

class QuranService {
  static const String _baseUrl = 'https://api.quran.com/api/v4';
  static bool _hiveInitialized = false;

  final _cacheManager = CacheManager(
    Config(
      'quran_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 604,
    ),
  );

  Future<bool> get isOnline async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getQuranPage(int pageNumber) async {
    try {
      await _ensureHiveReady();

      // Check Hive cache first
      if (_hiveInitialized) {
        final box = Hive.box('quran_cache');
        if (box.containsKey('page_$pageNumber')) {
          final cachedData = box.get('page_$pageNumber');
          if (cachedData != null && cachedData['verses'] != null) {
            return cachedData;
          }
        }
      }

      // If online, fetch from API
      if (await isOnline) {
        final response = await http.get(
          Uri.parse('$_baseUrl/quran/verses/uthmani?page_number=$pageNumber'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;

          // Validate the response structure
          if (data['verses'] == null) {
            throw Exception('Invalid API response format - missing verses');
          }

          await _cachePage(pageNumber, data);
          return data;
        }
        throw Exception(
            'API request failed with status ${response.statusCode}');
      }

      // Try fallback cache
      return await _getFallbackData(pageNumber);
    } catch (e) {
      print('Error in getQuranPage: $e');
      rethrow;
    }
  }

  Future<void> _ensureHiveReady() async {
    if (!_hiveInitialized) {
      try {
        if (!Hive.isBoxOpen('quran_cache')) {
          await Hive.openBox('quran_cache');
        }
        _hiveInitialized = true;
      } catch (e) {
        print('Hive initialization error: $e');
        _hiveInitialized = false;
      }
    }
  }

  Future<void> _cachePage(int pageNumber, Map<String, dynamic> data) async {
    try {
      // Cache in Hive
      if (_hiveInitialized) {
        final box = Hive.box('quran_cache');
        await box.put('page_$pageNumber', data);
      }

      // Cache in file system
      await _cacheManager.putFile(
        '$_baseUrl/quran/verses/uthmani?page_number=$pageNumber',
        utf8.encode(json.encode(data)),
        key: 'page_$pageNumber',
      );
    } catch (e) {
      print('Caching error: $e');
    }
  }

  Future<Map<String, dynamic>> _getFallbackData(int pageNumber) async {
    try {
      final file = await _cacheManager.getFileFromCache('page_$pageNumber');
      if (file != null) {
        final content = await file.file.readAsString();
        return json.decode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Fallback error: $e');
    }
    throw Exception('No data available (offline and no cache)');
  }

  Future<void> preCacheEssentialPages() async {
    if (await isOnline) {
      try {
        final pagesToCache = [
          ...List.generate(10, (i) => i + 1),
          ...List.generate(10, (i) => 604 - i)
        ];

        await Future.wait(
          pagesToCache.map((page) => getQuranPage(page).catchError((e) {
                print('Error caching page $page: $e');
                return null;
              })),
        );
      } catch (e) {
        print('Pre-caching error: $e');
        rethrow;
      }
    }
  }

  Future<void> clearCorruptedCache() async {
    try {
      await Hive.deleteBoxFromDisk('quran_cache');
      await _cacheManager.emptyCache();
      _hiveInitialized = false;
      await _ensureHiveReady();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
