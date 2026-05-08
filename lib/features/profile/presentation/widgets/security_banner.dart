import 'package:flutter/material.dart';

class SecurityBanner extends StatelessWidget {
  const SecurityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF005DA7),
            Color(0xFFBFD9FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                Text(
                  "Your Data is Vaulted",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Bank-grade encryption for all medical records.",
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.6,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
