enum CellType { question, answer, black }

enum WordDirection { right, down }

class GridPosition {
  const GridPosition(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) {
    return other is GridPosition && row == other.row && col == other.col;
  }

  @override
  int get hashCode => Object.hash(row, col);
}

class PuzzleCell {
  const PuzzleCell({
    required this.position,
    required this.type,
    this.questionRight,
    this.questionDown,
    this.backgroundColor,
    this.partOf = const [],
  });

  final GridPosition position;
  final CellType type;
  final String? questionRight;
  final String? questionDown;
  final String? backgroundColor;
  final List<String> partOf;

  factory PuzzleCell.fromJson(Map<String, dynamic> json) {
    return PuzzleCell(
      position: GridPosition(json['row'] as int, json['col'] as int),
      type: CellType.values.byName(json['type'] as String),
      questionRight: json['question_text_right'] as String?,
      questionDown: json['question_text_down'] as String?,
      backgroundColor: json['bg_color'] as String?,
      partOf: List<String>.from(json['part_of'] as List? ?? const []),
    );
  }
}

class PuzzleWord {
  const PuzzleWord({
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

  int get length => answer.length;

  List<GridPosition> get positions {
    return List.generate(length, (index) {
      return direction == WordDirection.right
          ? GridPosition(start.row, start.col + index)
          : GridPosition(start.row + index, start.col);
    });
  }

  factory PuzzleWord.fromJson(Map<String, dynamic> json) {
    final clue = json['clue_cell'] as Map<String, dynamic>;
    return PuzzleWord(
      id: json['id'] as String,
      direction: WordDirection.values.byName(json['direction'] as String),
      start: GridPosition(json['start_row'] as int, json['start_col'] as int),
      answer: (json['answer'] as String).toUpperCase(),
      clueCell: GridPosition(clue['row'] as int, clue['col'] as int),
    );
  }
}

class Puzzle {
  Puzzle({
    required this.id,
    required this.title,
    required this.category,
    required this.rows,
    required this.cols,
    required this.cells,
    required this.words,
  }) : _cellsByPosition = {for (final cell in cells) cell.position: cell};

  final String id;
  final String title;
  final String category;
  final int rows;
  final int cols;
  final List<PuzzleCell> cells;
  final List<PuzzleWord> words;
  final Map<GridPosition, PuzzleCell> _cellsByPosition;

  PuzzleCell? cellAt(GridPosition position) => _cellsByPosition[position];

  List<PuzzleWord> wordsAt(GridPosition position) {
    final result = words
        .where((word) => word.positions.contains(position))
        .toList();
    result.sort((a, b) => a.direction.index.compareTo(b.direction.index));
    return result;
  }

  List<PuzzleWord> wordsForClue(GridPosition position) {
    final result = words.where((word) => word.clueCell == position).toList();
    result.sort((a, b) => a.direction.index.compareTo(b.direction.index));
    return result;
  }

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    final data = json['puzzle'] as Map<String, dynamic>;
    final grid = data['grid'] as Map<String, dynamic>;
    return Puzzle(
      id: data['id'] as String,
      title: data['title'] as String,
      category: data['category'] as String,
      rows: grid['rows'] as int,
      cols: grid['cols'] as int,
      cells: (data['cells'] as List)
          .map((cell) => PuzzleCell.fromJson(cell as Map<String, dynamic>))
          .toList(),
      words: (data['words'] as List)
          .map((word) => PuzzleWord.fromJson(word as Map<String, dynamic>))
          .toList(),
    );
  }
}
