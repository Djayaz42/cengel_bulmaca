// lib/widgets/grid_cell_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/puzzle_model.dart';
import '../utils/app_theme.dart';

class GridCellWidget extends StatelessWidget {
  final CellModel cell;
  final String userLetter;
  final bool isSelected;
  final bool isInSelectedWord;
  final bool isCorrect;
  final bool hasInput;
  final VoidCallback? onTap;

  const GridCellWidget({
    super.key,
    required this.cell,
    this.userLetter = '',
    this.isSelected = false,
    this.isInSelectedWord = false,
    this.isCorrect = false,
    this.hasInput = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (cell.type) {
      CellType.black => _BlackCell(),
      CellType.question => _QuestionCell(cell: cell, onTap: onTap),
      CellType.answer => _AnswerCell(
          userLetter: userLetter,
          isSelected: isSelected,
          isInSelectedWord: isInSelectedWord,
          isCorrect: isCorrect,
          hasInput: hasInput,
          onTap: onTap,
        ),
      CellType.image => _ImageCell(cell: cell),
    };
  }
}

class _BlackCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.blackCell);
  }
}

class _QuestionCell extends StatelessWidget {
  final CellModel cell;
  final VoidCallback? onTap;

  const _QuestionCell({required this.cell, this.onTap});

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.questionCell;
    if (cell.bgColor != null) {
      try {
        bgColor = Color(
          int.parse(cell.bgColor!.replaceFirst('#', '0xFF')),
        );
      } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(2),
        child: Stack(
          children: [
            // Soru metinleri
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cell.questionTextRight != null)
                  _QuestionText(
                    text: cell.questionTextRight!,
                    arrow: ArrowDirection.right,
                  ),
                if (cell.questionTextDown != null) ...[
                  if (cell.questionTextRight != null)
                    const Divider(
                      height: 3,
                      thickness: 0.5,
                      color: Colors.white38,
                    ),
                  _QuestionText(
                    text: cell.questionTextDown!,
                    arrow: ArrowDirection.down,
                  ),
                ],
                // Tek soru (eski format uyumluluğu)
                if (cell.questionTextRight == null &&
                    cell.questionTextDown == null)
                  _QuestionText(
                    text: '',
                    arrow: cell.arrowDirection,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionText extends StatelessWidget {
  final String text;
  final ArrowDirection arrow;

  const _QuestionText({required this.text, required this.arrow});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 7.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (arrow != ArrowDirection.none) ...[
          const SizedBox(width: 1),
          _ArrowIcon(direction: arrow),
        ],
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  final ArrowDirection direction;

  const _ArrowIcon({required this.direction});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (direction) {
      case ArrowDirection.right:
        icon = Icons.arrow_forward;
      case ArrowDirection.down:
        icon = Icons.arrow_downward;
      case ArrowDirection.rightDown:
        icon = Icons.south_east;
      default:
        return const SizedBox.shrink();
    }
    return Icon(icon, color: Colors.white, size: 8);
  }
}

class _AnswerCell extends StatelessWidget {
  final String userLetter;
  final bool isSelected;
  final bool isInSelectedWord;
  final bool isCorrect;
  final bool hasInput;
  final VoidCallback? onTap;

  const _AnswerCell({
    required this.userLetter,
    required this.isSelected,
    required this.isInSelectedWord,
    required this.isCorrect,
    required this.hasInput,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;

    if (isSelected) {
      bgColor = AppColors.selectedCell;
      textColor = Colors.white;
      border = Border.all(color: AppColors.primaryDark, width: 2);
    } else if (isCorrect && hasInput) {
      bgColor = AppColors.correctCell;
      textColor = AppColors.correctCellText;
      border = Border.all(color: Colors.green.shade300, width: 1);
    } else if (isInSelectedWord) {
      bgColor = AppColors.selectedWordCell;
      textColor = AppColors.textPrimary;
      border = Border.all(color: AppColors.primary.withOpacity(0.4), width: 1);
    } else {
      bgColor = AppColors.answerCell;
      textColor = AppColors.answerCellText;
      border = Border.all(color: AppColors.border, width: 0.5);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          userLetter,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ImageCell extends StatelessWidget {
  final CellModel cell;

  const _ImageCell({required this.cell});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: cell.imageAsset != null
          ? Image.asset(
              cell.imageAsset!,
              fit: BoxFit.contain,
            )
          : Center(
              child: Icon(
                Icons.image_outlined,
                color: AppColors.textSecondary,
              ),
            ),
    );
  }
}
