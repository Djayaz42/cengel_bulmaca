import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/puzzle.dart';
import '../theme/app_theme.dart';

class CrosswordGrid extends StatelessWidget {
  const CrosswordGrid({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final puzzle = controller.puzzle;
    return AspectRatio(
      aspectRatio: puzzle.cols / puzzle.rows,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / puzzle.cols;
          final cellHeight = constraints.maxHeight / puzzle.rows;
          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.ink, width: 2),
            ),
            child: Stack(
              children: [
                for (var row = 0; row < puzzle.rows; row++)
                  for (var col = 0; col < puzzle.cols; col++)
                    Positioned(
                      left: col * cellWidth,
                      top: row * cellHeight,
                      width: cellWidth,
                      height: cellHeight,
                      child: _GridCell(
                        controller: controller,
                        position: GridPosition(row, col),
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.controller, required this.position});

  final GameController controller;
  final GridPosition position;

  @override
  Widget build(BuildContext context) {
    final cell = controller.puzzle.cellAt(position);
    final type = cell?.type ?? CellType.black;
    const border = Border.fromBorderSide(
      BorderSide(color: AppColors.ink, width: 0.55),
    );

    if (type == CellType.black) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.blackCell, border: border),
      );
    }

    if (type == CellType.question) {
      return InkWell(
        onTap: () => controller.selectCell(position),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.turquoise,
            border: border,
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cell?.questionRight != null)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${cell!.questionRight} →',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (cell?.questionRight != null && cell?.questionDown != null)
                const Divider(height: 1, thickness: 0.6, color: Colors.white70),
              if (cell?.questionDown != null)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${cell!.questionDown} ↓',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    final selected = controller.selectedCell == position;
    final inWord = controller.isInSelectedWord(position);
    final correctness = controller.isCellCorrect(position);
    final showError = controller.shouldHighlightError(position);
    final background = correctness == true
        ? Colors.green.shade100
        : correctness == false
        ? Colors.red.shade100
        : selected
        ? AppColors.darkTurquoise
        : inWord
        ? AppColors.selectedWord
        : Colors.white;

    return InkWell(
      onTap: () => controller.selectCell(position),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: showError
              ? Border.all(color: Colors.red.shade700, width: 2)
              : border,
        ),
        alignment: Alignment.center,
        child: Text(
          controller.letterAt(position),
          style: TextStyle(
            color: selected && correctness == null
                ? Colors.white
                : AppColors.ink,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
