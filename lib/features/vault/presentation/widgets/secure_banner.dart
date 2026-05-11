import 'package:flutter/material.dart';

import 'package:vitacase/core/constants/app_colors.dart';

class SecureBanner extends StatelessWidget {
  const SecureBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.primary),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Secure Local Storage",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),

                SizedBox(height: 4),

                Text(
                  "Your file will be encrypted before saving.",
                  style: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
