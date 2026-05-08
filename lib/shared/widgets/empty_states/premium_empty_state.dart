import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/vitacase_theme.dart';
import '../motion/vita_pressable.dart';

class PremiumEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final IconData icon;

  const PremiumEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onButtonPressed,
    this.icon = Icons.shield_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [VitaColors.primary, VitaColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: VitaColors.primary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Icon(icon, size: 48, color: Colors.white),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
            
            const SizedBox(height: 32),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: VitaColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 100.ms).fadeIn(),
            
            const SizedBox(height: 16),
            
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: VitaColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 200.ms).fadeIn(),
            
            const SizedBox(height: 48),
            
            VitaPressable(
              onPressed: onButtonPressed,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: VitaColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: VitaColors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms, delay: 300.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}
