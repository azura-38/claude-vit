import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../shared/domain/entities/document.dart';
import '../../../../shared/domain/enums/document_category.dart';
import '../providers/secure_vault_preview_controller.dart';

class VaultPreviewOverlay extends ConsumerStatefulWidget {
  const VaultPreviewOverlay({
    super.key,
    this.document,
    this.onTap,
    this.enabled,
  });

  final Document? document;
  final VoidCallback? onTap;
  final bool? enabled;

  static bool globallyEnabled = true;

  @override
  ConsumerState<VaultPreviewOverlay> createState() => _VaultPreviewOverlayState();
}

class _VaultPreviewOverlayState extends ConsumerState<VaultPreviewOverlay> {
  bool _revealed = false;

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    setState(() => _revealed = !_revealed);
  }

  @override
  Widget build(BuildContext context) {
    final isPreviewEnabled = widget.enabled ?? VaultPreviewOverlay.globallyEnabled;
    if (!isPreviewEnabled) {
      return const SizedBox.shrink();
    }

    final doc = widget.document;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (doc == null) {
      return _buildGenericPlaceholder(context, isDark);
    }

    final previewAsync = ref.watch(secureVaultPreviewProvider(doc));

    return previewAsync.when(
      data: (data) => _buildPreviewCard(context, isDark, data),
      loading: () => _buildLoadingCard(context, isDark),
      error: (error, stack) => _buildGenericPlaceholder(context, isDark),
    );
  }

  Widget _buildPreviewCard(
    BuildContext context,
    bool isDark,
    SecureVaultPreviewData data,
  ) {
    final borderRadius = BorderRadius.circular(22);

    if (data.isImage && data.imageBytes != null) {
      return GestureDetector(
        onTap: _handleTap,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              Image.memory(
                data.imageBytes!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => _buildFallbackCard(context, isDark, data.fileName),
              ),
              if (!_revealed)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
                      ),
                    ),
                  ),
                ),
              if (!_revealed)
                Positioned.fill(
                  child: Center(
                    child: _buildActionBadge(context, isDark),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // PDF or Non-image encrypted document
    final isPdf = data.fileType == DocumentFileType.pdf;
    final iconData = isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded;
    final iconColor = isPdf ? const Color(0xFFEF4444) : AppColors.primary;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
          borderRadius: borderRadius,
          border: Border.all(
            color: isDark ? AppColors.cardBorderDark : AppColors.border,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 40, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              data.fileName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildActionBadge(
              context,
              isDark,
              label: isPdf ? context.l10n.openPdf : context.l10n.tap_to_preview,
              icon: isPdf ? Icons.open_in_new_rounded : Icons.visibility_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBadge(
    BuildContext context,
    bool isDark, {
    String? label,
    IconData? icon,
  }) {
    final badgeLabel = label ?? context.l10n.tap_to_preview;
    final badgeIcon = icon ?? Icons.visibility_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 18,
            color: isDark ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            badgeLabel,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, bool isDark) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.border,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildFallbackCard(BuildContext context, bool isDark, String fileName) {
    return Container(
      height: 220,
      width: double.infinity,
      color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 40,
          color: isDark ? Colors.white38 : AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildGenericPlaceholder(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.cardBorderDark : AppColors.border,
          ),
        ),
        child: Center(
          child: _buildActionBadge(context, isDark),
        ),
      ),
    );
  }
}
