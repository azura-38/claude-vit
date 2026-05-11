import 'package:flutter/material.dart';

import 'package:vitacase/core/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.active,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
