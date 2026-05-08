import 'package:flutter/material.dart';

import '../../../../core/theme/vitacase_theme.dart';

class DetailSectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Map<String, String>> rows;

  const DetailSectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: VitaColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          ...rows.map(
            (row) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    row["label"]!,
                    style: const TextStyle(
                      color: VitaColors.secondary,
                    ),
                  ),

                  Flexible(
                    child: Text(
                      row["value"]!,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
