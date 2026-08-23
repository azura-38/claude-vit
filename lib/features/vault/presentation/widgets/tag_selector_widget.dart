import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/shared/providers/tags_provider.dart';

class TagSelectorWidget extends ConsumerWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagSelectorWidget({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  void _toggleTag(String tag) {
    final updated = List<String>.from(selectedTags);
    if (updated.contains(tag)) {
      updated.remove(tag);
    } else {
      updated.add(tag);
    }
    onTagsChanged(updated);
  }

  Future<void> _showAddTagDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final newTag = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(context.tr('addTag'), style: const TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: context.tr('customTagHint'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(dialogContext, text);
                }
              },
              child: Text(context.tr('addTag')),
            ),
          ],
        );
      },
    );

    if (newTag != null && newTag.isNotEmpty) {
      await ref.read(tagsProvider.notifier).addCustomTag(newTag);
      if (!selectedTags.contains(newTag)) {
        final updated = List<String>.from(selectedTags)..add(newTag);
        onTagsChanged(updated);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableTags = ref.watch(tagsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('tags'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddTagDialog(context, ref),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.tr('addTag'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...availableTags.map((tag) {
              final isSelected = selectedTags.contains(tag);
              return FilterChip(
                selected: isSelected,
                label: Text(tag, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                backgroundColor: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.brandMist,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white12 : Colors.black12),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (_) => _toggleTag(tag),
              );
            }),
          ],
        ),
      ],
    );
  }
}
