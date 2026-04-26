import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileCreateScreen extends ConsumerStatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  ConsumerState<ProfileCreateScreen> createState() =>
      _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends ConsumerState<ProfileCreateScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  String? _selectedGender;
  String? _pickedImagePath;
  DateTime? _birthDate;
  bool _agreedPrivacy = false;
  bool _agreedTerms = false;
  bool _agreedDisclaimer = false;
  bool _isInit = false;
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInit) {
        final name = ref.read(profileNameProvider);
        final gender = ref.read(profileGenderProvider);
        final birthDate = ref.read(profileBirthDateProvider);
        final photo = ref.read(profilePhotoProvider);
        _selectedLanguageCode = ref.read(localeProvider).languageCode;

        if (name != null) _nameController.text = name;
        if (gender != null) _selectedGender = gender;
        if (photo != null) _pickedImagePath = photo;
        if (birthDate != null) {
          _birthDate = DateTime.tryParse(birthDate);
          if (_birthDate != null) {
            _dateController.text =
                "${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}";
          }
        }
        setState(() {
          _isInit = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _saveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n('please_enter_name'))),
      );
      return;
    }

    if (!_agreedPrivacy || !_agreedTerms || !_agreedDisclaimer) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n('must_agree'))));
      return;
    }

    await ref
        .read(profileServiceProvider)
        .saveProfile(
          name: name,
          gender: _selectedGender ?? context.l10n('not_set'),
          birthDate: _birthDate?.toIso8601String().substring(0, 10),
          photoPath: _pickedImagePath,
        );
    if (_selectedLanguageCode != null) {
      await ref.read(localeProvider.notifier).setLocale(_selectedLanguageCode!);
    }

    // Mark legal documents as accepted (Score 100 Compliance)
    await ref.read(legalAcceptedProvider.notifier).accept();

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.primaryIndigo,
            size: 32,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "VitaCase",
          style: TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.medicalBlue,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.medicalBlue.withValues(alpha: 0.1),
              ),
            ),
          ).animate().fadeIn().blurXY(end: 80),

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 32),
                _buildPhotoPicker(isDark),
                const SizedBox(height: 32),
                _buildFormInput(
                  label: context.l10n('full_name'),
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      hint: context.l10n('hint_name'),
                      icon: Icons.badge_outlined,
                      isDark: isDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormInput(
                        label: context.l10n('gender'),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: _inputDecoration(
                            hint: context.l10n('hint_select'),
                            icon: Icons.person_outline,
                            isDark: isDark,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: "Female",
                              child: Text(context.l10n('gender_female')),
                            ),
                            DropdownMenuItem(
                              value: "Male",
                              child: Text(context.l10n('gender_male')),
                            ),
                            DropdownMenuItem(
                              value: "Other",
                              child: Text(context.l10n('gender_other')),
                            ),
                          ],
                          onChanged:
                              (val) => setState(() => _selectedGender = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormInput(
                        label: context.l10n('birth_date'),
                        child: TextField(
                          controller: _dateController,
                          readOnly: true,
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  _birthDate ??
                                  DateTime.now().subtract(
                                    const Duration(days: 365 * 25),
                                  ),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _birthDate = date;
                                _dateController.text =
                                    "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
                              });
                            }
                          },
                          decoration: _inputDecoration(
                            hint: context.l10n('date_format_hint'),
                            icon: Icons.calendar_today_rounded,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFormInput(
                  label: context.l10n('select_language'),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedLanguageCode,
                    decoration: _inputDecoration(
                      hint: context.l10n('select_language'),
                      icon: Icons.language_rounded,
                      isDark: isDark,
                    ),
                    items:
                        supportedLanguages
                            .map(
                              (language) => DropdownMenuItem(
                                value: language.code,
                                child: Text(language.name),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) =>
                            setState(() => _selectedLanguageCode = value),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegalAcceptance(isDark),
                const SizedBox(height: 120),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: 0.9,
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed:
                        (_agreedPrivacy && _agreedTerms && _agreedDisclaimer)
                            ? _saveAndContinue
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.medicalBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      disabledBackgroundColor: Colors.grey.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n('save_continue'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n('security_badge_label'),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Text(
          context.l10n('create_profile'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n('profile_desc'),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPicker(bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final result = await FilePicker.pickFiles(type: FileType.image);
          if (result != null) {
            setState(() => _pickedImagePath = result.files.single.path);
          }
        },
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white10 : Colors.grey[200],
              ),
              child: ClipOval(
                child:
                    _pickedImagePath != null
                        ? Image.file(File(_pickedImagePath!), fit: BoxFit.cover)
                        : const Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: AppColors.medicalBlue,
                        ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: AppColors.medicalBlue,
                radius: 18,
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormInput({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor:
          isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      suffixIcon: Icon(icon, color: Colors.grey),
    );
  }

  Widget _buildLegalAcceptance(bool isDark) {
    return Column(
      children: [
        _legalItem(
          context.l10n('privacy_policy'),
          _agreedPrivacy,
          (v) => setState(() => _agreedPrivacy = v ?? false),
          () => context.pushNamed('settingsPrivacy'),
        ),
        _legalItem(
          context.l10n('terms_conditions'),
          _agreedTerms,
          (v) => setState(() => _agreedTerms = v ?? false),
          () => context.pushNamed('settingsTerms'),
        ),
        _legalItem(
          context.l10n('legal_disclaimer'),
          _agreedDisclaimer,
          (v) => setState(() => _agreedDisclaimer = v ?? false),
          () => context.pushNamed('settingsDisclaimer'),
        ),
      ],
    );
  }

  Widget _legalItem(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
    VoidCallback onLink,
  ) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Text(
            "${context.l10n('i_agree_to')} ",
            style: const TextStyle(fontSize: 13),
          ),
          GestureDetector(
            onTap: onLink,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.medicalBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
