import 'package:flutter/material.dart';

import '../../domain/models/user_profile.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'metric_box.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class BmiCard extends StatelessWidget {
  final UserProfile profile;

  const BmiCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              MetricBox(
                title: context.l10n.currentWeight,
                value: profile.weight.toString(),
                unit: "kg",
              ),

              const SizedBox(width: 16),

              MetricBox(
                title: context.l10n.height,
                value: profile.height.toInt().toString(),
                unit: "cm",
              ),
            ],
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.bmiIndex,
                    style: const TextStyle(color: AppColors.secondary),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    profile.bmi.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  profile.bmiStatus,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF60A5FA),
                  Color(0xFF34D399),
                  Color(0xFFFBBF24),
                  Color(0xFFF87171),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("18.5"), Text("25"), Text("30")],
          ),

          const SizedBox(height: 22),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: context.l10n.bmiRangePrefix),
                TextSpan(
                  text: context.l10n.bmiRangeHealthy,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: context.l10n.bmiRangeSuffix,
                ),
              ],
            ),
            style: const TextStyle(height: 1.6, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
