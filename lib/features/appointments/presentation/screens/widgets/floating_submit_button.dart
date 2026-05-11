import 'package:flutter/material.dart';

class FloatingSubmitButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;
  final String label;

  const FloatingSubmitButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
    this.label = 'Create Appointment',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFF94A3B8) : const Color(0xFF005DA7),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 93, 167, 0.24),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child:
              isLoading
                  ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
        ),
      ),
    );
  }
}
