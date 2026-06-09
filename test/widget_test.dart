import 'package:crossword_app/providers/game_provider.dart';
import 'package:crossword_app/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameProvider game;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    game = GameProvider();
    await game.loadPuzzle('assets/puzzles/bolum_1.json');
  });

  test('5x5 bulmacada iki kelimenin tüm hücreleri tanımlıdır', () {
    final puzzle = game.puzzle!;

    expect(puzzle.rows, 5);
    expect(puzzle.cols, 5);
    expect(puzzle.words.length, 2);
    expect(puzzle.cellsForWord(puzzle.words[0]).length, 4);
    expect(puzzle.cellsForWord(puzzle.words[1]).length, 4);
    expect(puzzle.cellsForWord(puzzle.words[1]).last, (row: 4, col: 0));
  });

  test('soru hücresi ilk tıkta right, ikinci tıkta down seçer', () {
    game.selectCell(0, 0);
    expect(game.selectedWord?.direction, 'right');
    expect(game.selectedCell, (row: 0, col: 1));

    game.selectCell(0, 0);
    expect(game.selectedWord?.direction, 'down');
    expect(game.selectedCell, (row: 1, col: 0));
  });

  test('aşağı kelimede giriş bir sonraki satıra ilerler ve sonda kalır', () {
    game.selectCell(0, 0);
    game.selectCell(0, 0);

    game.enterLetter('I');
    expect(game.selectedCell, (row: 2, col: 0));

    game.selectCell(4, 0);
    game.enterLetter('K');
    expect(game.selectedCell, (row: 4, col: 0));
  });

  test('seçim renkleri koyu turkuaz ve açık sarıdır', () {
    expect(AppColors.selectedCell, const Color(0xFF007A6E));
    expect(AppColors.selectedWordCell, const Color(0xFFFFF3B0));
  });
}
