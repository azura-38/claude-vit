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
      _selectedLanguageCode = ref.read(localeProvider).languageCode;

      if (name != null) _nameController.text = name;
      if (gender != null) _selectedGender = gender;
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

  void _goToSecurityStep() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseEnterName)),
      );
      return;
    }

    if (!_acceptedLegal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.mustAgree)),
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
            SnackBar(content: Text(context.l10n.lockPinMismatch)),
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
        title: const Text('VitaCase'),
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
                  _StepDot(active: true, label: context.l10n.stepProfile),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep == 1 ? AppColors.brandBlue : Colors.grey.withValues(alpha: 0.25),
                    ),
                  ),
                  _StepDot(active: _currentStep == 1, label: context.l10n.stepSecurity),
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
                    label: Text(context.l10n.continue_btn),
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
                context.l10n.createProfile,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.profileDesc,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: context.l10n.fullName,
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          decoration: InputDecoration(
            labelText: context.l10n.gender,
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          items: [
            DropdownMenuItem(value: 'Female', child: Text(context.l10n.genderFemale)),
            DropdownMenuItem(value: 'Male', child: Text(context.l10n.genderMale)),
            DropdownMenuItem(value: 'Other', child: Text(context.l10n.genderOther)),
          ],
          onChanged: (value) => setState(() => _selectedGender = value),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: context.l10n.birthDate,
            hintText: context.l10n.dateFormatHint,
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
        DropdownButtonFormField<String>(
          initialValue: _selectedLanguageCode,
          decoration: InputDecoration(
            labelText: context.l10n.selectLanguage,
            prefixIcon: const Icon(Icons.language_rounded),
          ),
          items: supportedLanguages
              .map((language) => DropdownMenuItem(
                    value: language.code,
                    child: Text(language.name),
                  ))
              .toList(),
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

  Widget _buildSecurityStep(bool isDark) {
    if (_pinSetupComplete) {
      return Center(
        key: const ValueKey('success'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 72),
            const SizedBox(height: 16),
            Text(context.l10n.success, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
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
          context.l10n.setupAppLock,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.setupAppLockDesc,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary),
        ),
        const SizedBox(height: 18),
        Text(
          _isConfirmingPin ? context.l10n.lockConfirmPin : context.l10n.lockSetPin,
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
        _PinPad(
          onKey: _handlePinKey,
          onBackspace: _handlePinBackspace,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: _saveAndFinish,
          icon: const Icon(Icons.skip_next_rounded),
          label: Text(context.l10n.skipPinSetup),
        ),
        Text(
          context.l10n.lockSkipDesc,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : AppColors.textSecondary),
        ),
      ],
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
  const _LegalAgreementCard({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

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
    return TextButton(
      onPressed: () => context.pushNamed(routeName),
      child: Text(label),
    );
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
              child: IconButton(
                onPressed: onBackspace,
                icon: const Icon(Icons.backspace_outlined),
              ),
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
