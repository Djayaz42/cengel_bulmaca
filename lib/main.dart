import 'package:flutter/material.dart';

import 'screens/chapter_list_screen.dart';
import 'screens/editor_screen.dart';
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
      routes: {
        '/': (_) => const ChapterListScreen(),
        '/editor': (_) => const EditorScreen(),
      },
      initialRoute: Uri.base.path == '/editor' ? '/editor' : '/',
    );
  }
}
