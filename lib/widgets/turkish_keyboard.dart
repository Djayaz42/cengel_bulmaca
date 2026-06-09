import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TurkishKeyboard extends StatelessWidget {
  const TurkishKeyboard({
    required this.onLetter,
    required this.onDelete,
    super.key,
  });

  final ValueChanged<String> onLetter;
  final VoidCallback onDelete;

  static const rows = [
    ['E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'],
    ['Z', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 10),
      color: AppColors.lightTurquoise,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final letter in row)
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _KeyButton(
                          label: letter,
                          onTap: () => onLetter(letter),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          SizedBox(
            width: 86,
            child: _KeyButton(icon: Icons.backspace_outlined, onTap: onDelete),
          ),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.onTap, this.label, this.icon});

  final VoidCallback onTap;
  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Center(
            child: icon != null
                ? Icon(icon, color: AppColors.darkTurquoise, size: 20)
                : Text(
                    label!,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
