import 'package:crossword_app/editor/puzzle_editor_controller.dart';
import 'package:crossword_app/models/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('grid yeniden boyutlandırıldığında tüm hücreler tanımlanır', () {
    final editor = PuzzleEditorController();

    editor.resize(24, 24);

    expect(editor.rows, 24);
    expect(editor.cols, 24);
    expect(editor.cells.length, 576);
    expect(editor.cells.every((cell) => cell.type == CellType.answer), isTrue);
  });

  test('hücre tipi cevap soru siyah cevap sırasında değişir', () {
    final editor = PuzzleEditorController(rows: 2, cols: 2);
    const position = GridPosition(0, 0);

    editor.cycleCell(position);
    expect(editor.cellAt(position).type, CellType.question);
    expect(editor.selectedCell, position);

    editor.cycleCell(position);
    expect(editor.cellAt(position).type, CellType.black);

    editor.cycleCell(position);
    expect(editor.cellAt(position).type, CellType.answer);
  });

  test('cevaplar ilgili hücreleri otomatik işaretler', () {
    final editor = PuzzleEditorController(rows: 5, cols: 5);
    const clue = GridPosition(0, 0);
    editor.cycleCell(clue);

    editor.updateQuestion(
      rightClue: 'bir meyve',
      downClue: 'güneş ışığı',
      rightAnswer: 'ELMA',
      downAnswer: 'ISIK',
    );

    expect(editor.words.length, 2);
    for (var col = 1; col < 5; col++) {
      final cell = editor.cellAt(GridPosition(0, col));
      expect(cell.type, CellType.answer);
      expect(cell.partOf, contains('w_0_0_r'));
    }
    for (var row = 1; row < 5; row++) {
      final cell = editor.cellAt(GridPosition(row, 0));
      expect(cell.type, CellType.answer);
      expect(cell.partOf, contains('w_0_0_d'));
    }
  });

  test('JSON tüm koordinatları ve kelimeleri içerir', () {
    final editor = PuzzleEditorController(rows: 5, cols: 5);
    const clue = GridPosition(0, 0);
    editor.cycleCell(clue);
    editor.updateQuestion(
      rightClue: 'bir meyve',
      downClue: 'güneş ışığı',
      rightAnswer: 'ELMA',
      downAnswer: 'ISIK',
    );

    final puzzle = editor.toJson()['puzzle'] as Map<String, dynamic>;
    expect((puzzle['cells'] as List).length, 25);
    expect((puzzle['words'] as List).length, 2);
    expect(puzzle['grid'], {'rows': 5, 'cols': 5});
  });

  test('grid sınırını aşan cevap kelime oluşturmaz', () {
    final editor = PuzzleEditorController(rows: 3, cols: 3);
    const clue = GridPosition(0, 1);
    editor.cycleCell(clue);

    editor.updateQuestion(
      rightClue: 'uzun',
      downClue: '',
      rightAnswer: 'DORT',
      downAnswer: '',
    );

    expect(editor.words, isEmpty);
    expect(editor.validationMessage, isNotNull);
  });
}
