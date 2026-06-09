import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/puzzle.dart';

class EditorCell {
  EditorCell({
    required this.position,
    this.type = CellType.answer,
    this.questionRight = '',
    this.questionDown = '',
  });

  final GridPosition position;
  CellType type;
  String questionRight;
  String questionDown;
  final Set<String> partOf = {};
}

class EditorWord {
  const EditorWord({
    required this.id,
    required this.direction,
    required this.start,
    required this.answer,
    required this.clueCell,
  });

  final String id;
  final WordDirection direction;
  final GridPosition start;
  final String answer;
  final GridPosition clueCell;
}

class PuzzleEditorController extends ChangeNotifier {
  PuzzleEditorController({int rows = 11, int cols = 11})
    : _rows = rows,
      _cols = cols {
    _resetCells();
  }

  int _rows;
  int _cols;
  String puzzleId = 'bolum_1';
  String title = 'Bölüm 1';
  String category = 'Genel';
  GridPosition? selectedCell;
  String? validationMessage;

  final Map<GridPosition, EditorCell> _cells = {};
  final Map<String, EditorWord> _words = {};

  int get rows => _rows;
  int get cols => _cols;
  List<EditorCell> get cells => _cells.values.toList(growable: false);
  List<EditorWord> get words => _words.values.toList(growable: false);

  EditorCell cellAt(GridPosition position) => _cells[position]!;

  void resize(int rows, int cols) {
    _rows = rows.clamp(1, 50);
    _cols = cols.clamp(1, 50);
    selectedCell = null;
    validationMessage = null;
    _resetCells();
    notifyListeners();
  }

  void cycleCell(GridPosition position) {
    final cell = cellAt(position);
    if (cell.type == CellType.answer) {
      _removeWordsUsing(position);
      cell.type = CellType.question;
      selectedCell = position;
    } else if (cell.type == CellType.question) {
      _removeWordsForClue(position);
      _removeWordsUsing(position);
      cell
        ..type = CellType.black
        ..questionRight = ''
        ..questionDown = '';
      if (selectedCell == position) selectedCell = null;
    } else {
      cell.type = CellType.answer;
      selectedCell = null;
    }
    validationMessage = null;
    notifyListeners();
  }

  void selectQuestion(GridPosition position) {
    if (cellAt(position).type != CellType.question) return;
    selectedCell = position;
    notifyListeners();
  }

  void updateQuestion({
    required String rightClue,
    required String downClue,
    required String rightAnswer,
    required String downAnswer,
  }) {
    final position = selectedCell;
    if (position == null) return;
    final cell = cellAt(position);
    if (cell.type != CellType.question) return;

    cell
      ..questionRight = rightClue.trim()
      ..questionDown = downClue.trim();
    validationMessage = null;
    _replaceWord(position, WordDirection.right, rightAnswer);
    _replaceWord(position, WordDirection.down, downAnswer);
    notifyListeners();
  }

  void updateMetadata({
    required String id,
    required String puzzleTitle,
    required String puzzleCategory,
  }) {
    puzzleId = id.trim().isEmpty ? 'bolum_1' : id.trim();
    title = puzzleTitle.trim().isEmpty ? 'Bölüm 1' : puzzleTitle.trim();
    category = puzzleCategory.trim().isEmpty ? 'Genel' : puzzleCategory.trim();
    notifyListeners();
  }

  void _replaceWord(
    GridPosition clue,
    WordDirection direction,
    String rawAnswer,
  ) {
    final id = _wordId(clue, direction);
    _removeWord(id);
    final answer = rawAnswer.trim().toUpperCase();
    if (answer.isEmpty) return;

    final start = direction == WordDirection.right
        ? GridPosition(clue.row, clue.col + 1)
        : GridPosition(clue.row + 1, clue.col);
    final endRow = direction == WordDirection.down
        ? start.row + answer.length - 1
        : start.row;
    final endCol = direction == WordDirection.right
        ? start.col + answer.length - 1
        : start.col;
    if (start.row >= rows ||
        start.col >= cols ||
        endRow >= rows ||
        endCol >= cols) {
      validationMessage =
          '${direction == WordDirection.right ? 'Sağa' : 'Aşağı'} cevap '
          'grid sınırını aşıyor.';
      return;
    }

    final word = EditorWord(
      id: id,
      direction: direction,
      start: start,
      answer: answer,
      clueCell: clue,
    );
    _words[id] = word;
    for (final position in _positionsFor(word)) {
      final target = cellAt(position);
      if (target.type == CellType.question) {
        _removeWordsForClue(position);
        target
          ..questionRight = ''
          ..questionDown = '';
      }
      target
        ..type = CellType.answer
        ..partOf.add(id);
    }
  }

  void _removeWordsForClue(GridPosition clue) {
    _removeWord(_wordId(clue, WordDirection.right));
    _removeWord(_wordId(clue, WordDirection.down));
  }

  void _removeWordsUsing(GridPosition position) {
    final ids = _words.values
        .where((word) => _positionsFor(word).contains(position))
        .map((word) => word.id)
        .toList();
    for (final id in ids) {
      _removeWord(id);
    }
  }

  void _removeWord(String id) {
    final oldWord = _words.remove(id);
    if (oldWord == null) return;
    for (final position in _positionsFor(oldWord)) {
      cellAt(position).partOf.remove(id);
    }
  }

  Iterable<GridPosition> _positionsFor(EditorWord word) sync* {
    for (var index = 0; index < word.answer.length; index++) {
      yield word.direction == WordDirection.right
          ? GridPosition(word.start.row, word.start.col + index)
          : GridPosition(word.start.row + index, word.start.col);
    }
  }

  String _wordId(GridPosition clue, WordDirection direction) {
    final suffix = direction == WordDirection.right ? 'r' : 'd';
    return 'w_${clue.row}_${clue.col}_$suffix';
  }

  Map<String, dynamic> toJson() {
    final sortedCells = cells
      ..sort((a, b) {
        final rowCompare = a.position.row.compareTo(b.position.row);
        return rowCompare != 0
            ? rowCompare
            : a.position.col.compareTo(b.position.col);
      });
    final sortedWords = words..sort((a, b) => a.id.compareTo(b.id));

    return {
      'puzzle': {
        'id': puzzleId,
        'title': title,
        'category': category,
        'grid': {'rows': rows, 'cols': cols},
        'cells': [
          for (final cell in sortedCells)
            {
              'row': cell.position.row,
              'col': cell.position.col,
              'type': cell.type.name,
              if (cell.type == CellType.question) ...{
                if (cell.questionRight.isNotEmpty)
                  'question_text_right': cell.questionRight,
                if (cell.questionDown.isNotEmpty)
                  'question_text_down': cell.questionDown,
                'bg_color': '#00A896',
              },
              if (cell.type == CellType.answer && cell.partOf.isNotEmpty)
                'part_of': cell.partOf.toList()..sort(),
            },
        ],
        'words': [
          for (final word in sortedWords)
            {
              'id': word.id,
              'direction': word.direction.name,
              'start_row': word.start.row,
              'start_col': word.start.col,
              'answer': word.answer,
              'clue_cell': {'row': word.clueCell.row, 'col': word.clueCell.col},
            },
        ],
        'images': <dynamic>[],
      },
    };
  }

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  void _resetCells() {
    _cells
      ..clear()
      ..addEntries([
        for (var row = 0; row < rows; row++)
          for (var col = 0; col < cols; col++)
            MapEntry(
              GridPosition(row, col),
              EditorCell(position: GridPosition(row, col)),
            ),
      ]);
    _words.clear();
  }
}
