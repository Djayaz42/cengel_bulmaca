import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/puzzle.dart';

class GameController extends ChangeNotifier {
  GameController(this.puzzle);

  final Puzzle puzzle;
  final Map<GridPosition, String> _letters = {};
  bool _showValidationErrors = false;

  PuzzleWord? selectedWord;
  GridPosition? selectedCell;
  GridPosition? _selectedClue;

  static Future<GameController> load(String assetPath) async {
    final source = await rootBundle.loadString(assetPath);
    final json = jsonDecode(source) as Map<String, dynamic>;
    return GameController(Puzzle.fromJson(json));
  }

  Map<GridPosition, String> get letters => Map.unmodifiable(_letters);
  bool get showValidationErrors => _showValidationErrors;

  String letterAt(GridPosition position) => _letters[position] ?? '';

  String? correctLetterAt(GridPosition position) {
    for (final word in puzzle.wordsAt(position)) {
      final index = word.positions.indexOf(position);
      if (index >= 0) return word.answer[index];
    }
    return null;
  }

  bool? isCellCorrect(GridPosition position) {
    final letter = letterAt(position);
    if (letter.isEmpty) return null;
    return letter == correctLetterAt(position);
  }

  bool shouldHighlightError(GridPosition position) {
    return _showValidationErrors &&
        puzzle.cellAt(position)?.type == CellType.answer &&
        isCellCorrect(position) != true;
  }

  bool isInSelectedWord(GridPosition position) {
    return selectedWord?.positions.contains(position) ?? false;
  }

  void selectCell(GridPosition position) {
    final cell = puzzle.cellAt(position);
    if (cell == null || cell.type == CellType.black) return;

    if (cell.type == CellType.question) {
      _selectFromClue(position);
      return;
    }

    final words = puzzle.wordsAt(position);
    if (words.isEmpty) return;

    final repeated = selectedCell == position;
    if (repeated && words.length > 1) {
      selectedWord = _nextWord(words);
    } else if (selectedWord == null || !words.contains(selectedWord)) {
      selectedWord = words.first;
    }

    _selectedClue = null;
    selectedCell = position;
    notifyListeners();
  }

  void _selectFromClue(GridPosition position) {
    final words = puzzle.wordsForClue(position);
    if (words.isEmpty) return;

    if (_selectedClue == position && words.length > 1) {
      selectedWord = _nextWord(words);
    } else {
      selectedWord = words.first;
    }

    _selectedClue = position;
    selectedCell = selectedWord!.start;
    notifyListeners();
  }

  PuzzleWord _nextWord(List<PuzzleWord> words) {
    final currentIndex = selectedWord == null
        ? -1
        : words.indexOf(selectedWord!);
    return words[(currentIndex + 1) % words.length];
  }

  void enterLetter(String letter) {
    final position = selectedCell;
    final word = selectedWord;
    if (position == null || word == null || letter.isEmpty) return;

    _letters[position] = letter.toUpperCase();
    _showValidationErrors = false;
    final index = word.positions.indexOf(position);
    if (index >= 0 && index < word.positions.length - 1) {
      selectedCell = word.positions[index + 1];
    }
    notifyListeners();
  }

  void deleteLetter() {
    final position = selectedCell;
    final word = selectedWord;
    if (position == null || word == null) return;

    if (_letters.remove(position) == null) {
      final index = word.positions.indexOf(position);
      if (index > 0) {
        selectedCell = word.positions[index - 1];
        _letters.remove(selectedCell);
      }
    }
    _showValidationErrors = false;
    notifyListeners();
  }

  void clear() {
    _letters.clear();
    _showValidationErrors = false;
    notifyListeners();
  }

  int checkAnswers() {
    _showValidationErrors = true;
    final wrongCells = <GridPosition>{};
    for (final word in puzzle.words) {
      for (final position in word.positions) {
        if (isCellCorrect(position) != true) {
          wrongCells.add(position);
        }
      }
    }
    notifyListeners();
    return wrongCells.length;
  }

  bool get isComplete {
    for (final word in puzzle.words) {
      for (var index = 0; index < word.positions.length; index++) {
        if (_letters[word.positions[index]] != word.answer[index]) {
          return false;
        }
      }
    }
    return true;
  }
}
