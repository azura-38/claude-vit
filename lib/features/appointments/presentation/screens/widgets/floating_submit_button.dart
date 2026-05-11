import 'package:flutter/material.dart';

class FloatingSubmitButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingSubmitButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF005DA7),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 93, 167, 0.24),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Create Appointment',
            style: TextStyle(
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
