import 'package:flutter/material.dart';

import '../../../../core/theme/vitacase_theme.dart';

class DocumentTypeCard extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const DocumentTypeCard({
    super.key,
    required this.active,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: active
              ? VitaColors.primary.withValues(alpha: .06)
              : Colors.white,
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: active
                ? VitaColors.primary
                : VitaColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active
                  ? VitaColors.primary
                  : VitaColors.secondary,
              size: 32,
            ),

            const SizedBox(height: 14),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
                color: active
                    ? VitaColors.primary
                    : VitaColors.secondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
