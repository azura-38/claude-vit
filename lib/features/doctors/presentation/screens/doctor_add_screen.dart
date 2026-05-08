import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../../../shared/domain/entities/doctor.dart';
import '../../../../shared/domain/enums/common_enums.dart';
import '../../../../shared/providers/doctor_providers.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../profile/presentation/widgets/phone_prefix_picker.dart';

class DoctorAddScreen extends ConsumerStatefulWidget {
  const DoctorAddScreen({super.key});

  @override
  ConsumerState<DoctorAddScreen> createState() => _DoctorAddScreenState();
}

class _DoctorAddScreenState extends ConsumerState<DoctorAddScreen> {
  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedTitle = 'doctor_title_dr';
  final List<String> _titles = ['doctor_title_dr', 'doctor_title_uzm', 'doctor_title_op', 'doctor_title_prof', 'doctor_title_doc'];
  Gender _selectedGender = Gender.male;
  String _phonePrefix = '+1';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = ref.read(localeProvider).languageCode;
      setState(() {
        _phonePrefix = PhonePrefixPicker.getDefaultPrefix(lang);
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _hospitalController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty || _specialtyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n('error_doctor_data'))),
      );
      return;
    }

    final doctor = Doctor(
      id: generateUuid(),
      title: _selectedTitle,
      name: _nameController.text.trim(),
      department: _specialtyController.text.trim(),
      hospital: _hospitalController.text.trim().isEmpty ? context.l10n('unknown') : _hospitalController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : '$_phonePrefix ${_phoneController.text.trim()}',
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      gender: _selectedGender,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isVerified: true,
      createdAt: DateTime.now(),
    );

    // If address is not in Doctor entity, we can prepend it to notes or ignore
    // For now we just use the entity fields.

    await ref.read(doctorListProvider.notifier).addDoctor(doctor);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.medicalBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n('add_doctor'),
          style: TextStyle(
            fontFamily: 'Manrope',
            color: isDark ? Colors.white : const Color(0xFF001C39),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              context.l10n('save'),
              style: TextStyle(
                fontFamily: 'Manrope',
                color: isDark ? AppColors.medicalBlue : const Color(0xFF005DA7),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Aesthetic Hero Card
            _buildHeroCard(isDark),
            const SizedBox(height: 32),

            // Identity Section
            _buildBentoSection(
              title: context.l10n('basic_info'),
              icon: Icons.person_rounded,
              iconColor: AppColors.medicalBlue,
              isDark: isDark,
              children: [
                _buildTitleAndGenderRow(isDark),
                const SizedBox(height: 20),
                _buildField(context.l10n('doctor_name_surname'), _nameController, context.l10n('hint_doctor_name'), isDark),
                const SizedBox(height: 20),
                _buildField(context.l10n('specialty_department'), _specialtyController, context.l10n('hint_specialty'), isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Contact & Hospital Section
            _buildBentoSection(
              title: context.l10n('institution_contact'),
              icon: Icons.local_hospital_rounded,
              iconColor: const Color(0xFF006766),
              isDark: isDark,
              children: [
                _buildField(context.l10n('hospital_clinic_name'), _hospitalController, context.l10n('hint_hospital'), isDark),
                const SizedBox(height: 20),
                _buildField(
                  context.l10n('phone_number'), 
                  _phoneController, 
                  context.l10n('hint_phone'), 
                  isDark, 
                  keyboardType: TextInputType.phone,
                  phonePrefix: _phonePrefix,
                  onPrefixChanged: (val) => setState(() => _phonePrefix = val),
                ),
                const SizedBox(height: 20),
                _buildField(context.l10n('email_address'), _emailController, context.l10n('hint_email'), isDark, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildAreaField(context.l10n('address'), _addressController, context.l10n('hint_address'), isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Notes Section
            _buildBentoSection(
              title: context.l10n('notes_bio'),
              icon: Icons.description_rounded,
              iconColor: const Color(0xFF566069),
              isDark: isDark,
              children: [
                _buildAreaField(context.l10n('personal_notes'), _notesController, context.l10n('hint_personal_notes'), isDark, maxLines: 4),
              ],
            ),
            const SizedBox(height: 32),

            // Footer Save Button
            _buildFooterButton(isDark),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(bool isDark) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF005DA7), Color(0xFF2976C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF005DA7).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: const Icon(Icons.emergency_rounded, size: 80, color: Colors.white24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n('new_record').toUpperCase(),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n('doctor_info'),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n('add_doctor_desc'),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Manrope')),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTitleAndGenderRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSmallLabel(context.l10n('title').toUpperCase()),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTitle,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(16),
                    items: _titles.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(context.l10n(t), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTitle = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSmallLabel(context.l10n('gender').toUpperCase()),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderOption(context.l10n('gender_male'), Gender.male, isDark),
                  const SizedBox(width: 8),
                  _buildGenderOption(context.l10n('gender_female'), Gender.female, isDark),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, Gender gender, bool isDark) {
    final selected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.medicalBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : (isDark ? Colors.white38 : Colors.blueGrey),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label, 
    TextEditingController c, 
    String hint, 
    bool isDark, 
    {TextInputType? keyboardType, String? phonePrefix, ValueChanged<String>? onPrefixChanged}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSmallLabel(label.toUpperCase()),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400, fontSize: 13),
            prefixIcon: phonePrefix != null 
              ? PhonePrefixPicker(
                  selectedCode: phonePrefix,
                  onChanged: onPrefixChanged!,
                  isDark: isDark,
                )
              : null,
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAreaField(String label, TextEditingController c, String hint, bool isDark, {int maxLines = 3}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSmallLabel(label.toUpperCase()),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400, fontSize: 13),
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildFooterButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF005DA7),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF005DA7).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save_rounded, size: 20),
            const SizedBox(width: 12),
            Text(context.l10n('save_and_list'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Manrope')),
          ],
        ),
      ),
    );
  }
}
