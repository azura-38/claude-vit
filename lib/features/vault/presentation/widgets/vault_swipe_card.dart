import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../domain/models/vault_document.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'vault_tag_chip.dart';

class VaultSwipeCard extends StatelessWidget {
  final VaultDocument document;
  final VoidCallback onTap;

  const VaultSwipeCard({
    super.key,
    required this.document,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: .45,
        children: [
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: const Color(0xFFE9EDF5),
            foregroundColor: AppColors.secondary,
            icon: Icons.edit_outlined,
            label: "Edit",
          ),

          SlidableAction(
            onPressed: (_) {},
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: "Delete",
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4FA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "OCT",
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),

                    Text(
                      document.date.day.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "${document.physician} • ${document.hospital}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.secondary),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        VaultTagChip(
                          label: document.category,
                          bg: AppColors.chipBlue,
                          text: AppColors.primary,
                        ),

                        if (document.pending)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: VaultTagChip(
                              label: "Pending",
                              bg: const Color(0xFFFFF2D8),
                              text: const Color(0xFFA06900),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
