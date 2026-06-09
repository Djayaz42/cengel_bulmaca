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
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      color: AppColors.lightTurquoise,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final row in rows)
            for (final letter in row)
              _KeyButton(label: letter, onTap: () => onLetter(letter)),
          _KeyButton(icon: Icons.backspace_outlined, onTap: onDelete),
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
      child: SizedBox(
        width: 44,
        height: 44,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
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
