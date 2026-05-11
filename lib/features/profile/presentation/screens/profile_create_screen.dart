import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../providers/legacy_providers.dart';
import '../providers/profile_provider.dart';
import '../../domain/models/user_profile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

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

  // Step wizard state
  int _currentStep = 0; // 0 = profile, 1 = security

  // PIN setup state
  String _pinEntry = '';
  String _pinConfirm = '';
  bool _isConfirmingPin = false;
  bool _pinHasError = false;
  bool _pinSetupComplete = false;

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

  bool get _profileValid {
    return _nameController.text.trim().isNotEmpty &&
        _agreedPrivacy &&
        _agreedTerms &&
        _agreedDisclaimer;
  }

  void _goToSecurityStep() {
    if (!_profileValid) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.pleaseEnterName)));
        return;
      }
      if (!_agreedPrivacy || !_agreedTerms || !_agreedDisclaimer) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.mustAgree)));
        return;
      }
    }
    setState(() => _currentStep = 1);
  }

  Future<void> _saveAndFinish() async {
    final name = _nameController.text.trim();

    final profileNotifier = ref.read(profileProvider.notifier);
    profileNotifier.updateName(name);
    if (_birthDate != null) {
      profileNotifier.updateBirthDate(_birthDate!);
    }
    profileNotifier.updateGender(_genderFromSelection(_selectedGender));
    await profileNotifier.saveToDatabase();
    if (_selectedLanguageCode != null) {
      await ref.read(localeProvider.notifier).setLocale(_selectedLanguageCode!);
    }

    // Mark legal documents as accepted
    await ref.read(legalAcceptedProvider.notifier).accept();

    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
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
    if (_isConfirmingPin) {
      if (_pinConfirm.length >= 6) return;
      HapticFeedback.lightImpact();
      setState(() {
        _pinConfirm += key;
        _pinHasError = false;
      });
      if (_pinConfirm.length == 6) {
        if (_pinEntry == _pinConfirm) {
          // PIN matches — save it
          _savePinAndFinish();
        } else {
          setState(() {
            _pinConfirm = '';
            _pinHasError = true;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.lockPinMismatch)));
        }
      }
    } else {
      if (_pinEntry.length >= 6) return;
      HapticFeedback.lightImpact();
      setState(() {
        _pinEntry += key;
        _pinHasError = false;
      });
      if (_pinEntry.length == 6) {
        setState(() => _isConfirmingPin = true);
      }
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

    // Small delay to show success state
    await Future.delayed(const Duration(milliseconds: 600));
    await _saveAndFinish();
  }

  void _skipPinSetup() async {
    await _saveAndFinish();
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
        leading:
            _currentStep == 1
                ? IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 32),
                  onPressed:
                      () => setState(() {
                        _currentStep = 0;
                        _pinEntry = '';
                        _pinConfirm = '';
                        _isConfirmingPin = false;
                        _pinHasError = false;
                      }),
                )
                : null,
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
          // Background decoration
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.medicalBlue.withValues(alpha: 0.08),
              ),
            ),
          ).animate().fadeIn().blurXY(end: 80),

          SafeArea(
            child: Column(
              children: [
                // Step indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildStepDot(0, context.l10n.stepProfile),
                      Expanded(
                        child: Container(
                          height: 2,
                          color:
                              _currentStep >= 1
                                  ? AppColors.medicalBlue
                                  : (isDark
                                      ? Colors.white12
                                      : Colors.grey[300]),
                        ),
                      ),
                      _buildStepDot(1, context.l10n.stepSecurity),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child:
                        _currentStep == 0
                            ? _buildProfileStep(isDark)
                            : _buildSecurityStep(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Bottom bar (only for step 0)
          if (_currentStep == 0)
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
                      onPressed: _profileValid ? _goToSecurityStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.medicalBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: Colors.grey.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            context.l10n.continue_btn,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.securityBadgeLabel,
                      style: const TextStyle(
                        fontSize: 9,
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

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.medicalBlue : Colors.grey[300],
            border:
                isCurrent
                    ? Border.all(
                      color: AppColors.medicalBlue.withValues(alpha: 0.3),
                      width: 3,
                    )
                    : null,
          ),
          child: Center(
            child:
                isActive && !isCurrent
                    ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                    : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
            color:
                isActive
                    ? AppColors.medicalBlue
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white38
                        : Colors.grey),
          ),
        ),
      ],
    );
  }

  // ─── Step 1: Profile ───
  Widget _buildProfileStep(bool isDark) {
    return ListView(
      key: const ValueKey('profile_step'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        _buildHeader(isDark),
        const SizedBox(height: 24),
        _buildPhotoPicker(isDark),
        const SizedBox(height: 24),
        _buildFormInput(
          label: context.l10n.fullName,
          child: TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            decoration: _inputDecoration(
              hint: context.l10n.hintName,
              icon: Icons.badge_outlined,
              isDark: isDark,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildFormInput(
                label: context.l10n.gender,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: _inputDecoration(
                    hint: context.l10n.hintSelect,
                    icon: Icons.person_outline,
                    isDark: isDark,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "Female",
                      child: Text(context.l10n.genderFemale),
                    ),
                    DropdownMenuItem(
                      value: "Male",
                      child: Text(context.l10n.genderMale),
                    ),
                    DropdownMenuItem(
                      value: "Other",
                      child: Text(context.l10n.genderOther),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildFormInput(
                label: context.l10n.birthDate,
                child: TextField(
                  controller: _dateController,
                  readOnly: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
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
                    hint: context.l10n.dateFormatHint,
                    icon: Icons.calendar_today_rounded,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildFormInput(
          label: context.l10n.selectLanguage,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedLanguageCode,
            decoration: _inputDecoration(
              hint: context.l10n.selectLanguage,
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
            onChanged: (value) => setState(() => _selectedLanguageCode = value),
          ),
        ),
        const SizedBox(height: 14),
        _buildLegalAcceptance(isDark),
        const SizedBox(height: 140),
      ],
    );
  }

  // ─── Step 2: Security (PIN Setup) ───
  Widget _buildSecurityStep(bool isDark) {
    if (_pinSetupComplete) {
      return Center(
        key: const ValueKey('pin_done'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 64,
              ),
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.success,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      );
    }

    final currentPin = _isConfirmingPin ? _pinConfirm : _pinEntry;

    return SingleChildScrollView(
      key: const ValueKey('security_step'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.medicalBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.security_rounded,
              size: 48,
              color: isDark ? Colors.white70 : AppColors.medicalBlue,
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 400.ms,
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.setupAppLock,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.setupAppLockDesc,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isConfirmingPin
                ? context.l10n.lockConfirmPin
                : context.l10n.lockSetPin,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : AppColors.medicalBlue,
            ),
          ),
          const SizedBox(height: 24),
          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final isFilled = i < currentPin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 7),
                width: isFilled ? 16 : 12,
                height: isFilled ? 16 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _pinHasError
                          ? AppColors.error
                          : (isFilled
                              ? (isDark ? Colors.white : AppColors.medicalBlue)
                              : (isDark
                                  ? Colors.white12
                                  : Colors.grey.withValues(alpha: 0.2))),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
          // Inline PIN pad
          _buildCompactPinPad(isDark),
          const SizedBox(height: 20),
          // Skip option
          TextButton.icon(
            onPressed: _skipPinSetup,
            icon: const Icon(Icons.skip_next_rounded, size: 20),
            label: Text(context.l10n.skipPinSetup),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white38 : Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.lockSkipDesc,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompactPinPad(bool isDark) {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  row
                      .map(
                        (k) => _compactKey(k, () => _handlePinKey(k), isDark),
                      )
                      .toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 68, height: 56),
              _compactKey('0', () => _handlePinKey('0'), isDark),
              SizedBox(
                width: 68,
                height: 56,
                child: IconButton(
                  onPressed: _handlePinBackspace,
                  icon: Icon(
                    Icons.backspace_outlined,
                    color: isDark ? Colors.white54 : Colors.grey,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _compactKey(String val, VoidCallback onTap, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(34),
        splashColor: AppColors.medicalBlue.withValues(alpha: 0.15),
        child: Container(
          width: 68,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.withValues(alpha: 0.08),
          ),
          child: Text(
            val,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Shared Widgets ───

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Text(
          context.l10n.createProfile,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.profileDesc,
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
              width: 110,
              height: 110,
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
                          size: 56,
                          color: AppColors.medicalBlue,
                        ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                backgroundColor: AppColors.medicalBlue,
                radius: 16,
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  color: Colors.white,
                  size: 16,
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
          context.l10n.privacyPolicy,
          _agreedPrivacy,
          (v) => setState(() => _agreedPrivacy = v ?? false),
          () => context.pushNamed('settingsPrivacy'),
        ),
        _legalItem(
          context.l10n.termsConditions,
          _agreedTerms,
          (v) => setState(() => _agreedTerms = v ?? false),
          () => context.pushNamed('settingsTerms'),
        ),
        _legalItem(
          context.l10n.legalDisclaimer,
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
            "${context.l10n.iAgreeTo} ",
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
