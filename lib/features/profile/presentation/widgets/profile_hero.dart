import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_visuals.dart';
import '../providers/profile_controller.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class ProfileHero extends ConsumerWidget {
  final bool isDark;

  const ProfileHero({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(profileControllerProvider.notifier);
    final selectedTheme = ref.watch(themeTypeProvider);

    final name = controller.displayName.isEmpty ? context.tr('create_profile') : controller.displayName;
    final gender = controller.genderLabel;
    final age = controller.age;
    final photoPath = controller.photoPath;

    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickAndSavePhoto(context, ref),
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeVisuals.of(selectedTheme).primary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: _buildAvatar(photoPath, selectedTheme),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: ThemeVisuals.of(selectedTheme).gradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        if (gender != null || (age > 0)) ...[
          const SizedBox(height: 4),
          Text(
            [
              if (gender != null) context.tr(gender),
              if (age > 0) '$age ${context.tr('years_old')}',
            ].join(' - '),
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Future<void> _pickAndSavePhoto(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;
    final value = bytes != null ? _dataUri(bytes, file.extension) : null;

    if (value == null || value.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('error'))));
      }
      return;
    }

    final controller = ref.read(profileControllerProvider.notifier);
    controller.updatePhotoPath(value);
    await controller.save();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('success'))));
    }
  }

  Widget _buildAvatar(String? value, AppThemeType selectedTheme) {
    final bytes = _decodeDataUri(value);
    if (bytes != null) {
      return Image.memory(bytes, fit: BoxFit.cover);
    }

    return _buildAvatarPlaceholder(selectedTheme);
  }

  Widget _buildAvatarPlaceholder(AppThemeType selectedTheme) {
    return ThemePlaceholder(
      type: selectedTheme,
      size: 120,
      iconSize: 48,
      radius: 40,
    );
  }

  static String _dataUri(Uint8List bytes, String? extension) {
    final normalized = (extension ?? 'png').toLowerCase();
    final mime = switch (normalized) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/png',
    };
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  static Uint8List? _decodeDataUri(String? value) {
    if (value == null || !value.startsWith('data:image/')) return null;
    final marker = 'base64,';
    final index = value.indexOf(marker);
    if (index == -1) return null;
    try {
      return base64Decode(value.substring(index + marker.length));
    } catch (_) {
      return null;
    }
  }
}
