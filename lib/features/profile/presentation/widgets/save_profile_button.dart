import 'package:flutter/material.dart';

class SaveProfileButton extends StatelessWidget {
  final VoidCallback onTap;

  const SaveProfileButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: const Color(0xFF005DA7),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color:
                  Color.fromRGBO(0, 93, 167, 0.25),
              blurRadius: 24,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: const Center(
          child: Text(
            'Save Changes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
