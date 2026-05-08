import 'package:flutter/material.dart';

import '../../core/theme/vitacase_theme.dart';

class PremiumAppbar extends StatelessWidget {
  const PremiumAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
        ),

        const SizedBox(width: 14),

        const Text(
          "VitaCase",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: VitaColors.primary,
          ),
        ),

        const Spacer(),

        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: VitaColors.border,
            ),
            color: Colors.white,
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: VitaColors.secondary,
          ),
        )
      ],
    );
  }
}
