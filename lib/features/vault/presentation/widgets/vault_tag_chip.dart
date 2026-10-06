import 'package:flutter/material.dart';

class VaultTagChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color text;
  final String? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const VaultTagChip({
    super.key,
    required this.label,
    required this.bg,
    required this.text,
    this.icon,
    this.onTap,
    this.onDelete,
    this.isSelected = false,
    this.fontSize = 13,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: isSelected
            ? Border.all(color: text, width: 1.5)
            : Border.all(color: text.withValues(alpha: 0.15), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && icon!.isNotEmpty) ...[
            Text(icon!, style: TextStyle(fontSize: fontSize)),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: text,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close_rounded,
                size: fontSize + 2,
                color: text.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
