// lib/models/puzzle_model.dart

enum CellType { question, answer, black, image }
enum ArrowDirection { right, down, rightDown, none }

class CellModel {
  final int row;
  final int col;
  final CellType type;

  // Soru hücresi alanları
  final String? questionTextRight;  // sağa bakan soru
  final String? questionTextDown;   // aşağı bakan soru
  final ArrowDirection arrowDirection;
  final String? bgColor;

  // Cevap hücresi alanları
  final List<String> partOf; // hangi word id'lerine ait

  // Resim hücresi alanları
  final String? imageAsset;
  final int spanRows;
  final int spanCols;
  final String? imageCaption;

  const CellModel({
    required this.row,
    required this.col,
    required this.type,
    this.questionTextRight,
    this.questionTextDown,
    this.arrowDirection = ArrowDirection.none,
    this.bgColor,
    this.partOf = const [],
    this.imageAsset,
    this.spanRows = 1,
    this.spanCols = 1,
    this.imageCaption,
  });

  factory CellModel.fromJson(Map<String, dynamic> json) {
    return CellModel(
      row: json['row'],
      col: json['col'],
      type: _parseCellType(json['type']),
      questionTextRight: json['question_text_right'],
      questionTextDown: json['question_text_down'],
      arrowDirection: _parseArrow(json['arrow']),
      bgColor: json['bg_color'],
      partOf: List<String>.from(json['part_of'] ?? []),
      imageAsset: json['image_asset'],
      spanRows: json['span_rows'] ?? 1,
      spanCols: json['span_cols'] ?? 1,
      imageCaption: json['image_caption'],
    );
  }

  static CellType _parseCellType(String? type) {
    switch (type) {
      case 'question': return CellType.question;
      case 'answer': return CellType.answer;
      case 'image': return CellType.image;
      default: return CellType.black;
    }
  }

  static ArrowDirection _parseArrow(dynamic arrow) {
    if (arrow == null) return ArrowDirection.none;
    switch (arrow.toString()) {
      case 'right': return ArrowDirection.right;
      case 'down': return ArrowDirection.down;
      case 'right_down': return ArrowDirection.rightDown;
      default: return ArrowDirection.none;
    }
  }
}

class WordModel {
  final String id;
  final String direction; // 'right' | 'down'
  final int startRow;
  final int startCol;
  final String answer;
  final int clueRow;
  final int clueCol;

  const WordModel({
    required this.id,
    required this.direction,
    required this.startRow,
    required this.startCol,
    required this.answer,
    required this.clueRow,
    required this.clueCol,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'],
      direction: json['direction'],
      startRow: json['start_row'],
      startCol: json['start_col'],
      answer: (json['answer'] as String).toUpperCase(),
      clueRow: json['clue_cell']['row'],
      clueCol: json['clue_cell']['col'],
    );
  }

  int get length => answer.length;
}

class PuzzleModel {
  final String id;
  final String title;
  final String category;
  final int rows;
  final int cols;
  final List<CellModel> cells;
  final List<WordModel> words;

  const PuzzleModel({
    required this.id,
    required this.title,
    required this.category,
    required this.rows,
    required this.cols,
    required this.cells,
    required this.words,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    final puzzle = json['puzzle'];
    return PuzzleModel(
      id: puzzle['id'],
      title: puzzle['title'],
      category: puzzle['category'],
      rows: puzzle['grid']['rows'],
      cols: puzzle['grid']['cols'],
      cells: (puzzle['cells'] as List)
          .map((c) => CellModel.fromJson(c))
          .toList(),
      words: (puzzle['words'] as List)
          .map((w) => WordModel.fromJson(w))
          .toList(),
    );
  }

  // Belirli koordinattaki hücreyi bul
  CellModel? cellAt(int row, int col) {
    try {
      return cells.firstWhere((c) => c.row == row && c.col == col);
    } catch (_) {
      return null;
    }
  }

  // Bir word'e ait tüm koordinatları döndür
  List<({int row, int col})> cellsForWord(WordModel word) {
    final result = <({int row, int col})>[];
    for (int i = 0; i < word.length; i++) {
      if (word.direction == 'right') {
        result.add((row: word.startRow, col: word.startCol + i));
      } else {
        result.add((row: word.startRow + i, col: word.startCol));
      }
    }
    return result;
  }
}

class ChapterModel {
  final String id;
  final String title;
  final String category;
  final String puzzleAsset; // assets/puzzles/bolum_1.json
  final bool isLocked;
  final int completionPercent;

  const ChapterModel({
    required this.id,
    required this.title,
    required this.category,
    required this.puzzleAsset,
    this.isLocked = false,
    this.completionPercent = 0,
  });
}
