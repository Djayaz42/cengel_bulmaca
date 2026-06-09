// lib/providers/game_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/puzzle_model.dart';

class GameProvider extends ChangeNotifier {
  PuzzleModel? _puzzle;

  // Kullanıcının girdiği harfler: 'row_col' -> 'harf'
  Map<String, String> _userInput = {};

  // Doğru/yanlış durumu: 'row_col' -> true/false
  Map<String, bool> _cellCorrectness = {};

  // Aktif seçili kelime
  WordModel? _selectedWord;

  // Aktif seçili hücre
  ({int row, int col})? _selectedCell;
  ({int row, int col})? _selectedClueCell;

  // Tamamlanma durumu
  bool _isCompleted = false;

  // İpucu sayısı
  int _hintsRemaining = 3;

  // Süre (saniye)
  int _elapsedSeconds = 0;

  PuzzleModel? get puzzle => _puzzle;
  Map<String, String> get userInput => _userInput;
  Map<String, bool> get cellCorrectness => _cellCorrectness;
  WordModel? get selectedWord => _selectedWord;
  ({int row, int col})? get selectedCell => _selectedCell;
  bool get isCompleted => _isCompleted;
  int get hintsRemaining => _hintsRemaining;
  int get elapsedSeconds => _elapsedSeconds;

  String _cellKey(int row, int col) => '${row}_$col';

  Future<void> loadPuzzle(String assetPath) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final jsonData = jsonDecode(jsonStr);
    _puzzle = PuzzleModel.fromJson(jsonData);
    _userInput = {};
    _cellCorrectness = {};
    _selectedWord = null;
    _selectedCell = null;
    _selectedClueCell = null;
    _isCompleted = false;
    _elapsedSeconds = 0;

    // Kaydedilmiş ilerleme varsa yükle
    await _loadProgress();
    notifyListeners();
  }

  void selectCell(int row, int col) {
    if (_puzzle == null) return;

    final cell = _puzzle!.cellAt(row, col);
    if (cell == null) return;

    if (cell.type == CellType.question) {
      _selectWordFromClue(row, col);
      return;
    }

    if (cell.type != CellType.answer) return;
    _selectedClueCell = null;

    // Aynı hücreye tekrar basılırsa yön değiştir
    if (_selectedCell?.row == row && _selectedCell?.col == col) {
      _toggleWordDirection(row, col);
      return;
    }

    _selectedCell = (row: row, col: col);

    // Bu hücreye ait kelimeleri bul
    final wordsForCell = _wordsForAnswerCell(row, col);

    if (wordsForCell.isNotEmpty) {
      // Önceki seçili kelimenin yönünü koru, yoksa ilkini seç
      if (_selectedWord != null &&
          wordsForCell.any((w) => w.id == _selectedWord!.id)) {
        // aynı kelimede kal
      } else {
        _selectedWord = wordsForCell.first;
      }
    }

    notifyListeners();
  }

  void _selectWordFromClue(int row, int col) {
    final words = _puzzle!.words
        .where((word) => word.clueRow == row && word.clueCol == col)
        .toList()
      ..sort((a, b) => _directionOrder(a).compareTo(_directionOrder(b)));

    if (words.isEmpty) return;

    final sameClue =
        _selectedClueCell?.row == row && _selectedClueCell?.col == col;
    if (sameClue && words.length > 1) {
      final currentIndex = words.indexWhere(
        (word) => word.id == _selectedWord?.id,
      );
      _selectedWord = words[(currentIndex + 1) % words.length];
    } else {
      _selectedWord = words.first;
    }

    _selectedClueCell = (row: row, col: col);
    _selectedCell = (
      row: _selectedWord!.startRow,
      col: _selectedWord!.startCol,
    );
    notifyListeners();
  }

  void _toggleWordDirection(int row, int col) {
    final wordsForCell = _wordsForAnswerCell(row, col);

    if (wordsForCell.length < 2) return;

    final currentIndex = wordsForCell.indexWhere(
      (w) => w.id == _selectedWord?.id,
    );
    final nextIndex = (currentIndex + 1) % wordsForCell.length;
    _selectedWord = wordsForCell[nextIndex];
    notifyListeners();
  }

  List<WordModel> _wordsForAnswerCell(int row, int col) {
    final words = _puzzle!.words.where((word) {
      final cells = _puzzle!.cellsForWord(word);
      return cells.any((cell) => cell.row == row && cell.col == col);
    }).toList()
      ..sort((a, b) => _directionOrder(a).compareTo(_directionOrder(b)));
    return words;
  }

  int _directionOrder(WordModel word) => word.direction == 'right' ? 0 : 1;

  void enterLetter(String letter) {
    if (_selectedCell == null || _puzzle == null) return;

    final key = _cellKey(_selectedCell!.row, _selectedCell!.col);
    _userInput[key] = letter.toUpperCase();

    // Doğruluk kontrolü
    _checkCell(_selectedCell!.row, _selectedCell!.col);

    // Bir sonraki boş hücreye geç
    _moveToNextCell();

    notifyListeners();
  }

  void deleteLetter() {
    if (_selectedCell == null) return;

    final key = _cellKey(_selectedCell!.row, _selectedCell!.col);
    if (_userInput.containsKey(key) && _userInput[key]!.isNotEmpty) {
      _userInput.remove(key);
      _cellCorrectness.remove(key);
    } else {
      _moveToPrevCell();
    }

    notifyListeners();
  }

  void _checkCell(int row, int col) {
    if (_puzzle == null) return;
    final key = _cellKey(row, col);
    final entered = _userInput[key] ?? '';

    // Bu hücrenin doğru harfini bul
    for (final word in _puzzle!.words) {
      final cells = _puzzle!.cellsForWord(word);
      for (int i = 0; i < cells.length; i++) {
        if (cells[i].row == row && cells[i].col == col) {
          final correctChar = word.answer[i];
          _cellCorrectness[key] = (entered == correctChar);
          break;
        }
      }
    }

    _checkCompletion();
  }

  void _checkCompletion() {
    if (_puzzle == null) return;

    bool allCorrect = true;
    for (final word in _puzzle!.words) {
      final cells = _puzzle!.cellsForWord(word);
      for (int i = 0; i < cells.length; i++) {
        final key = _cellKey(cells[i].row, cells[i].col);
        final isCorrect = _cellCorrectness[key] ?? false;
        if (!isCorrect) {
          allCorrect = false;
          break;
        }
      }
      if (!allCorrect) break;
    }

    if (allCorrect && !_isCompleted) {
      _isCompleted = true;
      _saveProgress();
    }
  }

  void _moveToNextCell() {
    if (_selectedWord == null || _selectedCell == null || _puzzle == null) {
      return;
    }

    final cells = _puzzle!.cellsForWord(_selectedWord!);
    final currentIndex = cells.indexWhere(
      (c) => c.row == _selectedCell!.row && c.col == _selectedCell!.col,
    );

    if (currentIndex < cells.length - 1) {
      _selectedCell = cells[currentIndex + 1];
    }
  }

  void _moveToPrevCell() {
    if (_selectedWord == null || _selectedCell == null || _puzzle == null) {
      return;
    }

    final cells = _puzzle!.cellsForWord(_selectedWord!);
    final currentIndex = cells.indexWhere(
      (c) => c.row == _selectedCell!.row && c.col == _selectedCell!.col,
    );

    if (currentIndex > 0) {
      _selectedCell = cells[currentIndex - 1];
    }
  }

  void useHint() {
    if (_hintsRemaining <= 0 || _selectedWord == null || _puzzle == null) {
      return;
    }

    final cells = _puzzle!.cellsForWord(_selectedWord!);
    for (int i = 0; i < cells.length; i++) {
      final key = _cellKey(cells[i].row, cells[i].col);
      if (!(_cellCorrectness[key] ?? false)) {
        _userInput[key] = _selectedWord!.answer[i];
        _cellCorrectness[key] = true;
        _hintsRemaining--;
        _checkCompletion();
        notifyListeners();
        return;
      }
    }
  }

  void tickTimer() {
    if (!_isCompleted) {
      _elapsedSeconds++;
      notifyListeners();
    }
  }

  String get formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get filledCells => _cellCorrectness.values.where((v) => v).length;

  int get totalAnswerCells {
    if (_puzzle == null) return 0;
    return _puzzle!.words.fold(0, (sum, w) => sum + w.length);
  }

  // Hücrenin seçili kelimeye ait olup olmadığı
  bool isCellInSelectedWord(int row, int col) {
    if (_selectedWord == null || _puzzle == null) return false;
    final cells = _puzzle!.cellsForWord(_selectedWord!);
    return cells.any((c) => c.row == row && c.col == col);
  }

  // İlerlemeyi kaydet
  Future<void> _saveProgress() async {
    if (_puzzle == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_userInput);
    await prefs.setString('progress_${_puzzle!.id}', data);
    await prefs.setBool('completed_${_puzzle!.id}', _isCompleted);
  }

  // İlerlemeyi yükle
  Future<void> _loadProgress() async {
    if (_puzzle == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('progress_${_puzzle!.id}');
    if (data != null) {
      _userInput = Map<String, String>.from(jsonDecode(data));
      _isCompleted = prefs.getBool('completed_${_puzzle!.id}') ?? false;
      // Doğruluk durumunu yeniden hesapla
      for (final entry in _userInput.entries) {
        final parts = entry.key.split('_');
        _checkCell(int.parse(parts[0]), int.parse(parts[1]));
      }
    }
  }
}
