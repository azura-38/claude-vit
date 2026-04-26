import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/ui_utils.dart';
import '../../widgets/banner_ad_container.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/profile/phone_prefix_picker.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  final ProfileData? initialData;
  const ProfileEditScreen({super.key, this.initialData});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  String? _selectedBloodType;
  bool _isInitialized = false;
  String _phonePrefix = '+1';
  String _emergencyPhonePrefix = '+1';

  @override
  void initState() {
    super.initState();
    // Ref is not available here, initialize in build or use a different approach
  }

  List<String> get _bloodTypes => ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-', context.l10n('blood_unknown')];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _initializeControllers(ProfileData profile) {
    if (_isInitialized) return;
    _nameController.text = profile.name ?? '';
    _phoneController.text = profile.phone ?? '';
    _emailController.text = profile.email ?? '';
    _emergencyNameController.text = profile.emergencyContact ?? '';
    _emergencyPhoneController.text = profile.emergencyContactPhone ?? '';
    _selectedBloodType = profile.bloodType ?? _bloodTypes.last;

    // Split prefix if exists
    final lang = ref.read(localeProvider).languageCode;
    final defaultPrefix = PhonePrefixPicker.getDefaultPrefix(lang);

    if (_phoneController.text.startsWith('+')) {
      final parts = _phoneController.text.split(' ');
      if (parts.length > 1) {
        _phonePrefix = parts[0];
        _phoneController.text = parts.sublist(1).join(' ');
      }
    } else {
      _phonePrefix = defaultPrefix;
    }

    if (_emergencyPhoneController.text.startsWith('+')) {
      final parts = _emergencyPhoneController.text.split(' ');
      if (parts.length > 1) {
        _emergencyPhonePrefix = parts[0];
        _emergencyPhoneController.text = parts.sublist(1).join(' ');
      }
    } else {
      _emergencyPhonePrefix = defaultPrefix;
    }
    
    // Convert old "Bilinmiyor" to localized version if necessary
    if (_selectedBloodType == 'Bilinmiyor') {
      _selectedBloodType = context.l10n('blood_unknown');
    }
    
    _isInitialized = true;
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      UiUtils.showCustomSnackBar(context, context.l10n('please_enter_name'), isError: true);
      return;
    }

    final current = ref.read(profileDataProvider).value ?? const ProfileData();
    final updated = current.copyWith(
      name: _nameController.text.trim(),
      phone: '$_phonePrefix ${_phoneController.text.trim()}',
      email: _emailController.text.trim(),
      emergencyContact: _emergencyNameController.text.trim(),
      emergencyContactPhone: '$_emergencyPhonePrefix ${_emergencyPhoneController.text.trim()}',
      bloodType: _selectedBloodType,
    );

    await ref.read(profileDataProvider.notifier).saveProfile(updated);
    if (mounted) {
      UiUtils.showCustomSnackBar(context, context.l10n('profile_updated'));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(context.l10n('profile_edit_title')),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        data: (profile) {
          _initializeControllers(profile);
          return Column(
            children: [
              const BannerAdContainer(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: context.l10n('full_name'),
                        icon: Icons.person_outline,
                        hint: context.l10n('full_name'),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _phoneController,
                        label: context.l10n('phone'),
                        icon: Icons.phone_rounded,
                        hint: "5xx ...",
                        keyboardType: TextInputType.phone,
                        isDark: isDark,
                        phonePrefix: _phonePrefix,
                        onPrefixChanged: (val) => setState(() => _phonePrefix = val),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emailController,
                        label: context.l10n('email_address'),
                        icon: Icons.email_outlined,
                        hint: "email@example.com",
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(isDark),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                           const Icon(Icons.contact_emergency_outlined, color: Colors.red, size: 20),
                           const SizedBox(width: 8),
                           Text(context.l10n('emergency_info'), 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.blueGrey, letterSpacing: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _emergencyNameController,
                        label: context.l10n('emergency_contact_name'),
                        icon: Icons.person_add_alt_1_outlined,
                        hint: "...",
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emergencyPhoneController,
                        label: context.l10n('emergency_contact_phone'),
                        icon: Icons.phone_callback_rounded,
                        hint: "5xx ...",
                        keyboardType: TextInputType.phone,
                        isDark: isDark,
                        phonePrefix: _emergencyPhonePrefix,
                        onPrefixChanged: (val) => setState(() => _emergencyPhonePrefix = val),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.medicalBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(context.l10n('save_changes'), 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("${context.l10n('error')}: $e")),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    required bool isDark,
    String? phonePrefix,
    ValueChanged<String>? onPrefixChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.grey[400]),
            prefixIcon: phonePrefix != null 
              ? PhonePrefixPicker(
                  selectedCode: phonePrefix,
                  onChanged: onPrefixChanged!,
                  isDark: isDark,
                )
              : Icon(icon, color: AppColors.medicalBlue, size: 20),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n('blood_type'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBloodType,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.medicalBlue),
              isExpanded: true,
              dropdownColor: isDark ? AppColors.bgDark : Colors.white,
              hint: Text(context.l10n('unknown'), style: TextStyle(color: isDark ? Colors.white24 : Colors.grey[400])),
              items: _bloodTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBloodType = val),
            ),
          ),
        ),
      ],
    );
  }
}
