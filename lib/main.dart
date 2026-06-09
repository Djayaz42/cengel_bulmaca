import 'package:flutter/material.dart';

import 'screens/chapter_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CrosswordApp());
}

class CrosswordApp extends StatelessWidget {
  const CrosswordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Çengel Bulmaca',
      theme: AppTheme.data,
      home: const ChapterListScreen(),
    );
  }
}
