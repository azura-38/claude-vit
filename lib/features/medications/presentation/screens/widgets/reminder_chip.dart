import 'package:flutter/material.dart';
import '../../../../../core/theme/vitacase_theme.dart';

class ReminderChip extends StatelessWidget {
  final String time;
  final VoidCallback onRemove;

  const ReminderChip({
    super.key,
    required this.time,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: VitaColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: VitaColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VitaColors.primary.withValues(alpha: 0.08),
              ),
              child: const Icon(Icons.close, size: 16),
            ),
          )
        ],
      ),
    );
  }
}
