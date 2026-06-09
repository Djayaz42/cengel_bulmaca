// lib/widgets/turkish_keyboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class TurkishKeyboard extends StatelessWidget {
  final Function(String) onLetter;
  final VoidCallback onDelete;
  final VoidCallback? onHint;
  final int hintsRemaining;

  const TurkishKeyboard({
    super.key,
    required this.onLetter,
    required this.onDelete,
    this.onHint,
    this.hintsRemaining = 0,
  });

  static const List<List<String>> _rows = [
    ['E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._rows.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final row = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (rowIndex == 2) ...[
                    // İpucu tuşu
                    _HintKey(
                      hintsRemaining: hintsRemaining,
                      onTap: onHint,
                    ),
                    const SizedBox(width: 4),
                  ],
                  ...row.map((letter) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _LetterKey(
                          letter: letter,
                          onTap: () => onLetter(letter),
                        ),
                      )),
                  if (rowIndex == 2) ...[
                    const SizedBox(width: 4),
                    // Silme tuşu
                    _DeleteKey(onTap: onDelete),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LetterKey extends StatelessWidget {
  final String letter;
  final VoidCallback onTap;

  const _LetterKey({required this.letter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          letter,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DeleteKey extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteKey({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined, size: 18),
      ),
    );
  }
}

class _HintKey extends StatelessWidget {
  final int hintsRemaining;
  final VoidCallback? onTap;

  const _HintKey({required this.hintsRemaining, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = hintsRemaining > 0 && onTap != null;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 46,
        height: 42,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primaryLight : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: enabled ? AppColors.primaryDark : Colors.grey,
            ),
            Text(
              '$hintsRemaining',
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: enabled ? AppColors.primaryDark : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
