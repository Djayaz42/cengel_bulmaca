import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/crossword_grid.dart';
import '../widgets/turkish_keyboard.dart';
import 'completion_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.puzzleAsset, super.key});

  final String puzzleAsset;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameController? _controller;
  bool _completionShown = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final controller = await GameController.load(widget.puzzleAsset);
    if (!mounted) return;
    controller.addListener(_onGameChanged);
    setState(() => _controller = controller);
  }

  void _onGameChanged() {
    if (!mounted) return;
    setState(() {});
    if (_controller!.isComplete && !_completionShown) {
      _completionShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => CompletionScreen(title: _controller!.puzzle.title),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onGameChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(
        title: Text(controller?.puzzle.title ?? 'Bulmaca'),
        actions: [
          IconButton(
            tooltip: 'Temizle',
            onPressed: controller?.clear,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: controller == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Column(
                    children: [
                      _CluePanel(controller: controller),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                            child: CrosswordGrid(controller: controller),
                          ),
                        ),
                      ),
                      TurkishKeyboard(
                        onLetter: controller.enterLetter,
                        onDelete: controller.deleteLetter,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _CluePanel extends StatelessWidget {
  const _CluePanel({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final word = controller.selectedWord;
    var clue = 'Bir hücre veya soru kutusu seçin';
    if (word != null) {
      final clueCell = controller.puzzle.cellAt(word.clueCell);
      clue = word.direction.name == 'right'
          ? clueCell?.questionRight ?? ''
          : clueCell?.questionDown ?? '';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightTurquoise, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            word?.direction.name == 'down'
                ? Icons.south_rounded
                : Icons.east_rounded,
            color: AppColors.darkTurquoise,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              clue,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
