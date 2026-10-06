import 'package:flutter/material.dart';

class PremiumInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const PremiumInput({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: const Color(0xFFF2F3FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
