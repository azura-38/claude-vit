import 'package:flutter/material.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/domain/enums/document_category.dart';
import '../../../../shared/domain/enums/document_tag.dart';
import 'vault_tag_chip.dart';

enum VaultSortMode { newest, oldest, nameAZ }

class VaultControls extends StatelessWidget {
  const VaultControls({
    super.key,
    required this.isDark,
    required this.controller,
    required this.query,
    required this.selectedCategory,
    required this.sortMode,
    required this.allLabel,
    required this.sortLabel,
    required this.categoryLabel,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onSortChanged,
    required this.onClear,
    this.selectedTag,
    this.availableTags = const [],
    this.onTagChanged,
  });

  final bool isDark;
  final TextEditingController controller;
  final String query;
  final DocumentCategory? selectedCategory;
  final VaultSortMode sortMode;
  final String allLabel;
  final String Function(VaultSortMode mode) sortLabel;
  final String Function(DocumentCategory category) categoryLabel;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DocumentCategory?> onCategoryChanged;
  final ValueChanged<VaultSortMode> onSortChanged;
  final VoidCallback onClear;
  final String? selectedTag;
  final List<String> availableTags;
  final ValueChanged<String?>? onTagChanged;

  bool get _hasActiveFilter =>
      query.trim().isNotEmpty ||
      selectedCategory != null ||
      sortMode != VaultSortMode.newest ||
      selectedTag != null;

  @override
  Widget build(BuildContext context) {
    // Custom tags that are not standard Quick Tags
    final quickTagIds = DocumentTag.values.map((t) => t.id.toLowerCase()).toSet();
    final customTagList = availableTags
        .where((t) => !quickTagIds.contains(t.toLowerCase()))
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: context.l10n.docsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              suffixIcon: query.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.brandMist,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 290;

              final categoryField = DropdownButtonFormField<DocumentCategory?>(
                isExpanded: true,
                isDense: true,
                initialValue: selectedCategory,
                iconSize: 20,
                decoration: InputDecoration(
                  labelText: context.l10n.category,
                  filled: true,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.brandMist,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem<DocumentCategory?>(
                    value: null,
                    child: Text(
                      allLabel,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  ...DocumentCategory.values.map(
                    (category) => DropdownMenuItem<DocumentCategory?>(
                      value: category,
                      child: Text(
                        categoryLabel(category),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
                onChanged: onCategoryChanged,
              );

              final sortField = DropdownButtonFormField<VaultSortMode>(
                isExpanded: true,
                isDense: true,
                initialValue: sortMode,
                iconSize: 20,
                decoration: InputDecoration(
                  labelText: context.l10n.sortLabel,
                  filled: true,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.brandMist,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: VaultSortMode.values
                    .map(
                      (mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(
                          sortLabel(mode),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
              );

              if (isNarrow) {
                return Column(
                  children: [
                    categoryField,
                    const SizedBox(height: 10),
                    sortField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: categoryField),
                  const SizedBox(width: 10),
                  Expanded(child: sortField),
                ],
              );
            },
          ),
          if (onTagChanged != null) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  VaultTagChip(
                    label: allLabel,
                    isSelected: selectedTag == null,
                    bg: selectedTag == null
                        ? (isDark
                            ? AppColors.primaryIndigo.withValues(alpha: 0.3)
                            : AppColors.chipBlue)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF1F4FA)),
                    text: selectedTag == null
                        ? (isDark ? Colors.white : AppColors.primary)
                        : (isDark ? Colors.white60 : AppColors.textSecondary),
                    onTap: () => onTagChanged!(null),
                  ),
                  const SizedBox(width: 8),
                  ...DocumentTag.values.map((tag) {
                    final isSel = selectedTag?.toLowerCase() == tag.id.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: VaultTagChip(
                        label: tag.localizedLabel(context),
                        icon: tag.icon,
                        isSelected: isSel,
                        bg: isSel
                            ? (isDark
                                ? AppColors.primaryIndigo.withValues(alpha: 0.3)
                                : AppColors.chipBlue)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF1F4FA)),
                        text: isSel
                            ? (isDark ? Colors.white : AppColors.primary)
                            : (isDark ? Colors.white60 : AppColors.textSecondary),
                        onTap: () => onTagChanged!(isSel ? null : tag.id),
                      ),
                    );
                  }),
                  ...customTagList.map((tag) {
                    final isSel = selectedTag?.toLowerCase() == tag.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: VaultTagChip(
                        label: tag,
                        isSelected: isSel,
                        bg: isSel
                            ? (isDark
                                ? AppColors.medicalBlue.withValues(alpha: 0.3)
                                : const Color(0xFFE8F0FE))
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF1F4FA)),
                        text: isSel
                            ? (isDark ? Colors.white : AppColors.medicalBlue)
                            : (isDark ? Colors.white60 : AppColors.textSecondary),
                        onTap: () => onTagChanged!(isSel ? null : tag),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          if (_hasActiveFilter) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: Text(context.tr('clear_filters')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
