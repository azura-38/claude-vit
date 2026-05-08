import 'package:flutter/material.dart';

class VaultActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color text;
  final VoidCallback onTap;

  const VaultActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.bg,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(icon, color: text),

              const SizedBox(width: 10),

              Text(
                label,
                style: TextStyle(
                  color: text,
                  fontWeight:
                      FontWeight.w700,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
