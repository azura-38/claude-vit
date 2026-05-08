import 'package:flutter/material.dart';
import '../../../../../core/theme/vitacase_theme.dart';

class SmartInfoBanner extends StatelessWidget {
  final String text;

  const SmartInfoBanner({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VitaColors.primaryLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          )
        ],
      ),
    );
  }
}
