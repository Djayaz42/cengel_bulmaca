// lib/widgets/crossword_grid.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_model.dart';
import '../providers/game_provider.dart';
import 'grid_cell_widget.dart';

class CrosswordGrid extends StatelessWidget {
  const CrosswordGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.puzzle;
    if (puzzle == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / puzzle.cols;

        return SizedBox(
          width: constraints.maxWidth,
          height: cellSize * puzzle.rows,
          child: Stack(
            children: [
              // Izgara arka planı
              _buildGrid(puzzle, cellSize, game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(
    PuzzleModel puzzle,
    double cellSize,
    GameProvider game,
  ) {
    // Resim hücrelerini takip et (span için)
    final Set<String> coveredByImage = {};

    // Önce resim hücrelerini işaretle
    for (final cell in puzzle.cells) {
      if (cell.type == CellType.image &&
          (cell.spanRows > 1 || cell.spanCols > 1)) {
        for (int r = cell.row; r < cell.row + cell.spanRows; r++) {
          for (int c = cell.col; c < cell.col + cell.spanCols; c++) {
            if (!(r == cell.row && c == cell.col)) {
              coveredByImage.add('${r}_$c');
            }
          }
        }
      }
    }

    final List<Widget> positioned = [];

    for (int row = 0; row < puzzle.rows; row++) {
      for (int col = 0; col < puzzle.cols; col++) {
        final key = '${row}_$col';
        if (coveredByImage.contains(key)) continue;

        final cell = puzzle.cellAt(row, col);

        // Hücre tanımsızsa siyah göster
        final cellModel = cell ??
            CellModel(
              row: row,
              col: col,
              type: CellType.black,
            );

        final userLetter = game.userInput['${row}_$col'] ?? '';
        final isSelected =
            game.selectedCell?.row == row && game.selectedCell?.col == col;
        final isInSelectedWord = game.isCellInSelectedWord(row, col);
        final isCorrect = game.cellCorrectness['${row}_$col'] ?? false;
        final hasInput = userLetter.isNotEmpty;

        // Resim hücresi için genişletilmiş alan
        double width = cellSize;
        double height = cellSize;
        if (cellModel.type == CellType.image) {
          width = cellSize * cellModel.spanCols;
          height = cellSize * cellModel.spanRows;
        }

        positioned.add(
          Positioned(
            left: col * cellSize,
            top: row * cellSize,
            width: width,
            height: height,
            child: GridCellWidget(
              cell: cellModel,
              userLetter: userLetter,
              isSelected: isSelected,
              isInSelectedWord: isInSelectedWord,
              isCorrect: isCorrect,
              hasInput: hasInput,
              onTap: cellModel.type == CellType.answer ||
                      cellModel.type == CellType.question
                  ? () => game.selectCell(row, col)
                  : null,
            ),
          ),
        );
      }
    }

    return Stack(children: positioned);
  }
}
