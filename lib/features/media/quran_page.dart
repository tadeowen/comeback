import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../media/quran_sevice_class.dart';

class QuranPage extends StatefulWidget {
  final int pageNumber;

  const QuranPage({Key? key, required this.pageNumber}) : super(key: key);

  @override
  _QuranPageState createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  late Future<Map<String, dynamic>> _pageData;
  final QuranService _quranService = QuranService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() => _isLoading = true);
    try {
      _pageData = _quranService
          .getQuranPage(widget.pageNumber)
          .timeout(const Duration(seconds: 15));

      final data = await _pageData;

      if (data['verses'] == null || data['verses'].isEmpty) {
        throw Exception('Received empty verses data from server');
      }
    } on TimeoutException {
      _pageData = Future.error('Request timed out. Please try again.');
    } on HiveError catch (e) {
      _pageData = Future.error('Storage error: ${e.message}');
    } catch (e) {
      _pageData = Future.error('Failed to load page: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quran Page ${widget.pageNumber}'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPage,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _pageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }

          final pageData = snapshot.data ?? {};
          final verses = pageData['verses'] ?? [];

          return _buildPageContent(verses);
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load page',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _loadPage,
                child: const Text('Retry'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () async {
                  await _quranService.clearCorruptedCache();
                  _loadPage();
                },
                child: const Text('Clear Cache'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(List<dynamic> verses) {
    if (verses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'No verses found for this page',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Page ${widget.pageNumber} might not exist or data is corrupted',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPage,
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final verse = verses[index];
                final verseText = verse['text_uthmani'] ??
                    verse['text'] ??
                    '[Verse text not available]';
                final verseNumber =
                    verse['verse_number'] ?? verse['number'] ?? '?';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        verseText,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Uthmani',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verse $verseNumber',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                  ),
                );
              },
              childCount: verses.length,
            ),
          ),
        ],
      ),
    );
  }
}
