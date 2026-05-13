import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/profile_controller.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class ProfileHero extends ConsumerWidget {
  final bool isDark;
  
  const ProfileHero({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(profileControllerProvider.notifier);
    
    final name = controller.displayName.isEmpty ? context.l10n.createProfile : controller.displayName;
    final gender = controller.genderLabel;
    final age = controller.age;
    final photo = controller.photoPath;

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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: photo != null && !photo.startsWith('http')
                      ? Image.file(
                          File(photo),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildAvatarPlaceholder(),
                        )
                      : _buildAvatarPlaceholder(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.medicalBlue,
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
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Manrope')),
        const SizedBox(height: 4),
        if (gender != null || (age > 0)) ...[
          const SizedBox(height: 4),
          Text(
            [
              if (gender != null) context.l10n(gender),
              if (age > 0) '$age ${context.l10n.yearsOld}',
            ].join(' - '),
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Future<void> _pickAndSavePhoto(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final controller = ref.read(profileControllerProvider.notifier);
      controller.updatePhotoPath(result.files.single.path!);
      await controller.save();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.success)));
      }
    }
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.primaryIndigo.withValues(alpha: 0.1),
      child: const Icon(Icons.person_rounded, color: AppColors.primaryIndigo, size: 40),
    );
  }
}
