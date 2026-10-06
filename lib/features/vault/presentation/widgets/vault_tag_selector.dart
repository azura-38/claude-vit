import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/data/repositories/custom_tag_repository_impl.dart';
import '../../../../shared/domain/enums/document_tag.dart';
import '../../../../shared/providers/custom_tag_providers.dart';
import 'vault_tag_chip.dart';

class VaultTagSelector extends ConsumerStatefulWidget {
  final List<String> initialSelectedTags;
  final ValueChanged<List<String>> onTagsChanged;
  final bool isDark;

  const VaultTagSelector({
    super.key,
    required this.initialSelectedTags,
    required this.onTagsChanged,
    required this.isDark,
  });

  @override
  ConsumerState<VaultTagSelector> createState() => _VaultTagSelectorState();
}

class _VaultTagSelectorState extends ConsumerState<VaultTagSelector> {
  late final List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List<String>.from(widget.initialSelectedTags);
  }

  void _toggleTag(String tagId) {
    setState(() {
      final index = _selectedTags.indexWhere((t) => t.toLowerCase() == tagId.toLowerCase());
      if (index >= 0) {
        _selectedTags.removeAt(index);
      } else {
        _selectedTags.add(tagId);
      }
      widget.onTagsChanged(List.unmodifiable(_selectedTags));
    });
  }

  Future<void> _showAddCustomTagDialog() async {
    final controller = TextEditingController();
    String? errorText;

    final createdTag = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(context.tr('add_custom_tag')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    maxLength: CustomTagValidator.maxTagLength,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: context.tr('tag_name_hint'),
                      errorText: errorText,
                      isDense: true,
                    ),
                    onSubmitted: (val) async {
                      try {
                        final created = await ref
                            .read(customTagsProvider.notifier)
                            .createCustomTag(val);
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop(created);
                        }
                      } on CustomTagException catch (e) {
                        setDialogState(() {
                          errorText = context.tr(e.messageKey);
                        });
                      } catch (_) {
                        setDialogState(() {
                          errorText = context.tr('tag_name_empty');
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.tr('cancel')),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      final created = await ref
                          .read(customTagsProvider.notifier)
                          .createCustomTag(controller.text);
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(created);
                      }
                    } on CustomTagException catch (e) {
                      setDialogState(() {
                        errorText = context.tr(e.messageKey);
                      });
                    } catch (_) {
                      setDialogState(() {
                        errorText = context.tr('tag_name_empty');
                      });
                    }
                  },
                  child: Text(context.tr('create_tag')),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (createdTag != null && createdTag.isNotEmpty) {
      if (!_selectedTags.any((t) => t.toLowerCase() == createdTag.toLowerCase())) {
        setState(() {
          _selectedTags.add(createdTag);
          widget.onTagsChanged(List.unmodifiable(_selectedTags));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customTags = ref.watch(customTagsProvider).value ?? [];
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Tags header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('quick_tags'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DocumentTag.values.map((tag) {
            final isSelected = _selectedTags.any(
              (t) => t.toLowerCase() == tag.id.toLowerCase(),
            );
            return VaultTagChip(
              label: tag.localizedLabel(context),
              icon: tag.icon,
              isSelected: isSelected,
              bg: isSelected
                  ? (isDark
                      ? AppColors.primaryIndigo.withValues(alpha: 0.3)
                      : AppColors.chipBlue)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F4FA)),
              text: isSelected
                  ? (isDark ? Colors.white : AppColors.primary)
                  : (isDark ? Colors.white60 : AppColors.textSecondary),
              onTap: () => _toggleTag(tag.id),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Custom Tags header with "+ Add" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('custom_tags'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            InkWell(
              onTap: _showAddCustomTagDialog,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: isDark ? AppColors.primaryIndigo : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('add_tag'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.primaryIndigo : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...customTags.map((tag) {
              final isSelected = _selectedTags.any(
                (t) => t.toLowerCase() == tag.toLowerCase(),
              );
              return VaultTagChip(
                label: tag,
                isSelected: isSelected,
                bg: isSelected
                    ? (isDark
                        ? AppColors.medicalBlue.withValues(alpha: 0.3)
                        : const Color(0xFFE8F0FE))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF1F4FA)),
                text: isSelected
                    ? (isDark ? Colors.white : AppColors.medicalBlue)
                    : (isDark ? Colors.white60 : AppColors.textSecondary),
                onTap: () => _toggleTag(tag),
              );
            }),
            // If any selected tag is a custom tag not currently in customTags store
            ..._selectedTags
                .where((st) =>
                    !DocumentTag.values.any((dt) => dt.id.toLowerCase() == st.toLowerCase()) &&
                    !customTags.any((ct) => ct.toLowerCase() == st.toLowerCase()))
                .map((orphanTag) {
              return VaultTagChip(
                label: orphanTag,
                isSelected: true,
                bg: isDark
                    ? AppColors.medicalBlue.withValues(alpha: 0.3)
                    : const Color(0xFFE8F0FE),
                text: isDark ? Colors.white : AppColors.medicalBlue,
                onTap: () => _toggleTag(orphanTag),
                onDelete: () => _toggleTag(orphanTag),
              );
            }),
            if (customTags.isEmpty &&
                !_selectedTags.any((st) => !DocumentTag.values
                    .any((dt) => dt.id.toLowerCase() == st.toLowerCase())))
              Text(
                context.tr('no_tags'),
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white38 : AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
