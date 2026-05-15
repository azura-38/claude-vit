import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/l10n/vita_strings.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/legacy_providers.dart';
import '../providers/profile_provider.dart';
import '../../domain/models/user_profile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileCreateScreen extends ConsumerStatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  ConsumerState<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends ConsumerState<ProfileCreateScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedGender;
  DateTime? _birthDate;
  String? _selectedLanguageCode;
  String? _selectedPhotoPath;
  Uint8List? _selectedPhotoBytes;
  bool _acceptedLegal = false;
  int _currentStep = 0;

  String _pinEntry = '';
  String _pinConfirm = '';
  bool _isConfirmingPin = false;
  bool _pinHasError = false;
  bool _pinSetupComplete = false;

  bool get _profileValid =>
      _nameController.text.trim().isNotEmpty && _acceptedLegal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final name = ref.read(profileNameProvider);
      final gender = ref.read(profileGenderProvider);
      final birthDate = ref.read(profileBirthDateProvider);
      final photo = ref.read(profilePhotoProvider);
      _selectedLanguageCode = ref.read(localeProvider).languageCode;

      if (name != null) _nameController.text = name;
      if (gender != null) _selectedGender = _genderSelectionFromName(gender);
      if (photo != null && photo.trim().isNotEmpty) _selectedPhotoPath = photo;
      if (birthDate != null) {
        _birthDate = DateTime.tryParse(birthDate);
        if (_birthDate != null) {
          _dateController.text = _formatDate(_birthDate!);
        }
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _genderSelectionFromName(String value) {
    switch (value) {
      case 'female':
      case 'Female':
        return 'Female';
      case 'male':
      case 'Male':
        return 'Male';
      default:
        return 'Other';
    }
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;

    setState(() {
      _selectedPhotoPath = file.path;
      _selectedPhotoBytes = file.bytes;
    });
  }

  void _goToSecurityStep() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('please_enter_name'))),
      );
      return;
    }

    if (!_acceptedLegal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('must_agree'))),
      );
      return;
    }

    setState(() => _currentStep = 1);
  }

  Future<void> _saveAndFinish() async {
    final profileNotifier = ref.read(profileProvider.notifier);
    profileNotifier.updateName(_nameController.text.trim());
    if (_birthDate != null) profileNotifier.updateBirthDate(_birthDate!);
    profileNotifier.updateGender(_genderFromSelection(_selectedGender));
    if (_selectedPhotoPath != null && _selectedPhotoPath!.trim().isNotEmpty) {
      profileNotifier.updatePhotoPath(_selectedPhotoPath);
    }
    await profileNotifier.saveToDatabase();

    if (_selectedLanguageCode != null) {
      await ref.read(localeProvider.notifier).setLocale(_selectedLanguageCode!);
    }

    await ref.read(legalAcceptedProvider.notifier).accept();

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  Gender _genderFromSelection(String? value) {
    switch (value) {
      case 'Female':
        return Gender.female;
      case 'Male':
        return Gender.male;
      default:
        return Gender.other;
    }
  }

  void _handlePinKey(String key) {
    HapticFeedback.lightImpact();
    setState(() => _pinHasError = false);

    if (_isConfirmingPin) {
      if (_pinConfirm.length >= 6) return;
      setState(() => _pinConfirm += key);
      if (_pinConfirm.length == 6) {
        if (_pinEntry == _pinConfirm) {
          _savePinAndFinish();
        } else {
          setState(() {
            _pinConfirm = '';
            _pinHasError = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('lock_pin_mismatch'))),
          );
        }
      }
      return;
    }

    if (_pinEntry.length >= 6) return;
    setState(() => _pinEntry += key);
    if (_pinEntry.length == 6) {
      setState(() => _isConfirmingPin = true);
    }
  }

  void _handlePinBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      _pinHasError = false;
      if (_isConfirmingPin && _pinConfirm.isNotEmpty) {
        _pinConfirm = _pinConfirm.substring(0, _pinConfirm.length - 1);
      } else if (!_isConfirmingPin && _pinEntry.isNotEmpty) {
        _pinEntry = _pinEntry.substring(0, _pinEntry.length - 1);
      }
    });
  }

  Future<void> _savePinAndFinish() async {
    await ref.read(pinServiceProvider).setPin(_pinEntry);
    await ref.read(appLockEnabledProvider.notifier).setEnabled(true);
    ref.read(appLockStateProvider.notifier).setUnlocked();
    setState(() => _pinSetupComplete = true);
    await Future.delayed(const Duration(milliseconds: 450));
    await _saveAndFinish();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.tr('app_name')),
        centerTitle: true,
        leading: _currentStep == 1
            ? IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => setState(() {
                  _currentStep = 0;
                  _pinEntry = '';
                  _pinConfirm = '';
                  _isConfirmingPin = false;
                  _pinHasError = false;
                }),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                children: [
                  _StepDot(active: true, label: context.tr('step_profile')),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep == 1 ? AppColors.brandBlue : Colors.grey.withValues(alpha: 0.25),
                    ),
                  ),
                  _StepDot(active: _currentStep == 1, label: context.tr('step_security')),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _currentStep == 0
                    ? _buildProfileStep(isDark)
                    : _buildSecurityStep(isDark),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _currentStep == 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _profileValid ? _goToSecurityStep : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(context.tr('continue_btn')),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProfileStep(bool isDark) {
    return ListView(
      key: const ValueKey('profile'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
      children: [
        _Card(
          isDark: isDark,
          child: Column(
            children: [
              Text(
                context.tr('create_profile'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('profile_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildPhotoPicker(isDark),
        const SizedBox(height: 18),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: context.tr('full_name'),
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          decoration: InputDecoration(
            labelText: context.tr('gender'),
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          items: [
            DropdownMenuItem(value: 'Female', child: Text(context.tr('gender_female'))),
            DropdownMenuItem(value: 'Male', child: Text(context.tr('gender_male'))),
            DropdownMenuItem(value: 'Other', child: Text(context.tr('gender_other'))),
          ],
          onChanged: (value) => setState(() => _selectedGender = value),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: context.tr('birth_date'),
            hintText: context.tr('date_format_hint'),
            prefixIcon: const Icon(Icons.calendar_today_rounded),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked == null) return;
            setState(() {
              _birthDate = picked;
              _dateController.text = _formatDate(picked);
            });
          },
        ),
        const SizedBox(height: 14),
        _LanguageCard(
          isDark: isDark,
          selectedLanguageCode: _selectedLanguageCode,
          onChanged: (value) => setState(() => _selectedLanguageCode = value),
        ),
        const SizedBox(height: 18),
        _LegalAgreementCard(
          value: _acceptedLegal,
          onChanged: (value) => setState(() => _acceptedLegal = value ?? false),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPhotoPicker(bool isDark) {
    return _Card(
      isDark: isDark,
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickProfilePhoto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: _selectedPhotoBytes != null
                        ? Image.memory(_selectedPhotoBytes!, fit: BoxFit.cover)
                        : const Icon(Icons.person_rounded, color: AppColors.brandBlue, size: 34),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.brandBlue,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? AppColors.surfaceDark : Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('profile_photo'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(_selectedPhotoPath == null ? 'profile_photo_add_desc' : 'profile_photo_selected'),
                  style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary, height: 1.35),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _pickProfilePhoto,
            icon: const Icon(Icons.add_a_photo_outlined),
            tooltip: context.tr('profile_photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStep(bool isDark) {
    if (_pinSetupComplete) {
      return Center(
        key: const ValueKey('success'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 72),
            const SizedBox(height: 16),
            Text(context.tr('success'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      );
    }

    final currentPin = _isConfirmingPin ? _pinConfirm : _pinEntry;

    return ListView(
      key: const ValueKey('security'),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      children: [
        const Icon(Icons.security_rounded, size: 56, color: AppColors.brandBlue),
        const SizedBox(height: 16),
        Text(
          context.tr('setup_app_lock'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('setup_app_lock_desc'),
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Text(
          _isConfirmingPin ? context.tr('lock_confirm_pin') : context.tr('lock_set_pin'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final filled = index < currentPin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              margin: const EdgeInsets.symmetric(horizontal: 7),
              width: filled ? 16 : 12,
              height: filled ? 16 : 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinHasError
                    ? AppColors.error
                    : filled
                        ? AppColors.brandBlue
                        : Colors.grey.withValues(alpha: 0.25),
              ),
            );
          }),
        ),
        const SizedBox(height: 28),
        _PinPad(onKey: _handlePinKey, onBackspace: _handlePinBackspace, isDark: isDark),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: _saveAndFinish,
          icon: const Icon(Icons.skip_next_rounded),
          label: Text(context.tr('skip_pin_setup')),
        ),
        Text(
          context.tr('lock_skip_desc'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.isDark,
    required this.selectedLanguageCode,
    required this.onChanged,
  });

  final bool isDark;
  final String? selectedLanguageCode;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.language_rounded, color: AppColors.brandBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: selectedLanguageCode,
              decoration: InputDecoration(
                labelText: context.tr('select_language'),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              items: supportedLanguages
                  .map((language) => DropdownMenuItem(value: language.code, child: Text(language.name)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: active ? AppColors.brandBlue : Colors.grey.withValues(alpha: 0.25),
          child: active ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.isDark});

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
      ),
      child: child,
    );
  }
}

class _LegalAgreementCard extends StatelessWidget {
  const _LegalAgreementCard({required this.value, required this.onChanged, required this.isDark});

  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final strings = VitaStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: value ? AppColors.brandBlue : Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: value,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(strings.termsAndLegalAgreement),
          ),
          Wrap(
            spacing: 10,
            children: [
              _LegalLink(label: strings.privacyPolicyShort, routeName: 'settingsPrivacy'),
              _LegalLink(label: strings.termsShort, routeName: 'settingsTerms'),
              _LegalLink(label: strings.disclaimerShort, routeName: 'settingsDisclaimer'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.routeName});

  final String label;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () => context.pushNamed(routeName), child: Text(label));
  }
}

class _PinPad extends StatelessWidget {
  const _PinPad({required this.onKey, required this.onBackspace, required this.isDark});

  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) => _KeyButton(label: key, onTap: () => onKey(key), isDark: isDark)).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 68, height: 56),
            _KeyButton(label: '0', onTap: () => onKey('0'), isDark: isDark),
            SizedBox(
              width: 68,
              height: 56,
              child: IconButton(onPressed: onBackspace, icon: const Icon(Icons.backspace_outlined)),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap, required this.isDark});

  final String label;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 68,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.08),
        ),
        child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
