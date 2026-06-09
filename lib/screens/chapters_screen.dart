// lib/screens/chapters_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/puzzle_model.dart';
import '../utils/app_theme.dart';
import 'game_screen.dart';

class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  // Örnek bölümler — ilerleyen aşamada API/JSON'dan gelecek
  static final List<ChapterModel> _chapters = [
    const ChapterModel(
      id: 'bolum_1',
      title: 'Bölüm 1',
      category: 'Genel Kültür',
      puzzleAsset: 'assets/puzzles/bolum_1.json',
      isLocked: false,
      completionPercent: 0,
    ),
    const ChapterModel(
      id: 'bolum_2',
      title: 'Bölüm 2',
      category: 'Coğrafya',
      puzzleAsset: 'assets/puzzles/bolum_2.json',
      isLocked: true,
      completionPercent: 0,
    ),
    const ChapterModel(
      id: 'bolum_3',
      title: 'Bölüm 3',
      category: 'Bilim',
      puzzleAsset: 'assets/puzzles/bolum_3.json',
      isLocked: true,
      completionPercent: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Çengel Bulmaca'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                return _ChapterCard(
                  chapter: _chapters[index],
                  onTap: _chapters[index].isLocked
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  GameScreen(chapter: _chapters[index]),
                            ),
                          ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          _HeaderStat(
            icon: Icons.check_circle_outline,
            label: 'Tamamlanan',
            value: '0',
          ),
          const SizedBox(width: 12),
          _HeaderStat(
            icon: Icons.grid_view_rounded,
            label: 'Toplam',
            value: '${_chapters.length}',
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final VoidCallback? onTap;

  const _ChapterCard({required this.chapter, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = chapter.isLocked;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: locked ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: chapter.completionPercent == 100
                    ? AppColors.primary
                    : AppColors.border,
                width: chapter.completionPercent == 100 ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Bölüm numarası
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: locked
                        ? Colors.grey.shade200
                        : chapter.completionPercent == 100
                            ? AppColors.primaryLight
                            : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: locked
                        ? const Icon(Icons.lock_outline,
                            size: 18, color: Colors.grey)
                        : chapter.completionPercent == 100
                            ? Icon(Icons.check_rounded,
                                color: AppColors.primary, size: 22)
                            : Text(
                                chapter.id
                                    .replaceAll('bolum_', ''),
                                style: GoogleFonts.nunito(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 14),
                // Başlık ve kategori
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.title,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        chapter.category,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Durum badge
                _StatusBadge(chapter: chapter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ChapterModel chapter;

  const _StatusBadge({required this.chapter});

  @override
  Widget build(BuildContext context) {
    if (chapter.isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
      );
    }
    if (chapter.completionPercent == 100) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Tamam',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      );
    }
    if (chapter.completionPercent > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '%${chapter.completionPercent}',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade700,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Başla',
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
