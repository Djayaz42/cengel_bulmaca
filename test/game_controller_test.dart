import 'package:crossword_app/controllers/game_controller.dart';
import 'package:crossword_app/models/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameController controller;

  setUp(() {
    controller = GameController(Puzzle.fromJson(_puzzleJson));
  });

  test('soru hücresi sağdan aşağıya toggle olur', () {
    controller.selectCell(const GridPosition(0, 0));
    expect(controller.selectedWord?.direction, WordDirection.right);
    expect(controller.selectedCell, const GridPosition(0, 1));

    controller.selectCell(const GridPosition(0, 0));
    expect(controller.selectedWord?.direction, WordDirection.down);
    expect(controller.selectedCell, const GridPosition(1, 0));
  });

  test('harf girişi seçili kelimenin yönünde ilerler', () {
    controller.selectCell(const GridPosition(0, 0));
    controller.enterLetter('E');
    expect(controller.selectedCell, const GridPosition(0, 2));

    controller.selectCell(const GridPosition(0, 0));
    controller.enterLetter('I');
    expect(controller.selectedCell, const GridPosition(2, 0));
  });

  test('aynı cevap hücresine iki kez tıklamak yön değiştirir', () {
    final crossing = Puzzle.fromJson(_crossingPuzzleJson);
    final game = GameController(crossing);

    game.selectCell(const GridPosition(1, 1));
    expect(game.selectedWord?.direction, WordDirection.right);

    game.selectCell(const GridPosition(1, 1));
    expect(game.selectedWord?.direction, WordDirection.down);
  });

  test('iki kelime doğru girildiğinde oyun tamamlanır', () {
    controller.selectCell(const GridPosition(0, 0));
    for (final letter in 'ELMA'.split('')) {
      controller.enterLetter(letter);
    }
    controller.selectCell(const GridPosition(0, 0));
    for (final letter in 'ISIK'.split('')) {
      controller.enterLetter(letter);
    }

    expect(controller.isComplete, isTrue);
  });
}

final _puzzleJson = <String, dynamic>{
  'puzzle': {
    'id': 'bolum_1',
    'title': 'Bölüm 1',
    'category': 'Test',
    'grid': {'rows': 5, 'cols': 5},
    'cells': [
      {
        'row': 0,
        'col': 0,
        'type': 'question',
        'question_text_right': 'bir meyve',
        'question_text_down': 'güneş ışığı',
      },
      for (var col = 1; col < 5; col++)
        {'row': 0, 'col': col, 'type': 'answer'},
      for (var row = 1; row < 5; row++)
        {'row': row, 'col': 0, 'type': 'answer'},
    ],
    'words': [
      {
        'id': 'w1',
        'direction': 'right',
        'start_row': 0,
        'start_col': 1,
        'answer': 'ELMA',
        'clue_cell': {'row': 0, 'col': 0},
      },
      {
        'id': 'w2',
        'direction': 'down',
        'start_row': 1,
        'start_col': 0,
        'answer': 'ISIK',
        'clue_cell': {'row': 0, 'col': 0},
      },
    ],
  },
};

final _crossingPuzzleJson = <String, dynamic>{
  'puzzle': {
    'id': 'crossing',
    'title': 'Crossing',
    'category': 'Test',
    'grid': {'rows': 3, 'cols': 3},
    'cells': [
      {'row': 1, 'col': 0, 'type': 'answer'},
      {'row': 1, 'col': 1, 'type': 'answer'},
      {'row': 1, 'col': 2, 'type': 'answer'},
      {'row': 0, 'col': 1, 'type': 'answer'},
      {'row': 2, 'col': 1, 'type': 'answer'},
    ],
    'words': [
      {
        'id': 'right',
        'direction': 'right',
        'start_row': 1,
        'start_col': 0,
        'answer': 'AAA',
        'clue_cell': {'row': 0, 'col': 0},
      },
      {
        'id': 'down',
        'direction': 'down',
        'start_row': 0,
        'start_col': 1,
        'answer': 'AAA',
        'clue_cell': {'row': 0, 'col': 0},
      },
    ],
  },
};
