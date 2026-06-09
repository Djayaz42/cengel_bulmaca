// lib/screens/game_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/puzzle_model.dart';
import '../providers/game_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/crossword_grid.dart';
import '../widgets/turkish_keyboard.dart';
import 'completion_screen.dart';

class GameScreen extends StatefulWidget {
  final ChapterModel chapter;

  const GameScreen({super.key, required this.chapter});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final game = context.read<GameProvider>();
    await game.loadPuzzle(widget.chapter.puzzleAsset);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final game = context.read<GameProvider>();
      game.tickTimer();
      if (game.isCompleted) {
        _timer?.cancel();
        _navigateToCompletion();
      }
    });
  }

  void _navigateToCompletion() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CompletionScreen(chapter: widget.chapter),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<GameProvider>(
        builder: (context, game, _) {
          if (game.puzzle == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Column(
            children: [
              _buildProgressBar(game),
              Expanded(
                child: _buildGameArea(game),
              ),
              _buildClueBar(game),
              TurkishKeyboard(
                onLetter: game.enterLetter,
                onDelete: game.deleteLetter,
                onHint: game.useHint,
                hintsRemaining: game.hintsRemaining,
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.chapter.title),
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Consumer<GameProvider>(
          builder: (_, game, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    game.formattedTime,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(GameProvider game) {
    final progress = game.totalAnswerCells > 0
        ? game.filledCells / game.totalAnswerCells
        : 0.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${game.filledCells}/${game.totalAnswerCells}',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea(GameProvider game) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const CrosswordGrid(),
          ),
        ),
      ),
    );
  }

  Widget _buildClueBar(GameProvider game) {
    final word = game.selectedWord;
    if (word == null) return const SizedBox(height: 8);

    final clueCell = game.puzzle?.cellAt(word.clueRow, word.clueCol);
    String clueText = '';
    if (clueCell != null) {
      clueText = word.direction == 'right'
          ? clueCell.questionTextRight ?? ''
          : clueCell.questionTextDown ?? '';
    }

    final dirLabel = word.direction == 'right' ? '→' : '↓';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dirLabel,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              clueText,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
