import 'package:flutter/material.dart';

class BiblePage extends StatelessWidget {
  final int chapterNumber;
  const BiblePage({Key? key, required this.chapterNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chapter $chapterNumber')),
      body: Center(
        child: Text(
          'Content of Bible Chapter $chapterNumber',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
