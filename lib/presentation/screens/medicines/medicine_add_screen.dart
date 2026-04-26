import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../../domain/entities/medicine.dart';
import '../../../domain/enums/common_enums.dart';
import '../../providers/medicine_providers.dart';

import '../../providers/achievement_providers.dart';
import '../../providers/daily_mission_providers.dart';

class MedicineAddScreen extends ConsumerStatefulWidget {
  final Medicine? medicine;
  const MedicineAddScreen({super.key, this.medicine});

  @override
  ConsumerState<MedicineAddScreen> createState() => _MedicineAddScreenState();
}

class _MedicineAddScreenState extends ConsumerState<MedicineAddScreen> {
  final _nameController = TextEditingController();
  String _selectedFrequency = 'daily'; // daily, weekly, custom
  final List<String> _frequencyKeys = ['daily', 'weekly', 'custom'];
  final List<String> _reminderTimes = ['08:00', '20:00'];
  int _currentStock = 24;
  String? _selectedUnit;
  List<String> get _units => [context.l10n('tablet'), context.l10n('syrup'), context.l10n('dose'), context.l10n('capsule'), context.l10n('drops')];
  HungerStatus _hungerStatus = HungerStatus.farketmez;

  // New fields for complex scheduling
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // 1=Mon...7=Sun
  int _customInterval = 2; // e.g., Every 2 days

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedUnit ??= context.l10n('tablet');
  }

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      final med = widget.medicine!;
      _nameController.text = med.name;
      _selectedFrequency = med.frequency;
      _reminderTimes.clear();
      _reminderTimes.addAll(med.reminderTimes);
      _currentStock = med.currentStock ?? 0; // guard null – Medicine.currentStock is nullable
      _selectedUnit = med.dosage;
      _hungerStatus = med.hungerStatus;
      _selectedDays = med.daysOfWeek ?? [1, 2, 3, 4, 5, 6, 7];
      _customInterval = med.interval ?? 2;
    }
  }


  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.medicalBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final timeStr = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      if (!_reminderTimes.contains(timeStr)) {
        setState(() {
          _reminderTimes.add(timeStr);
          _reminderTimes.sort();
        });
      }
    }
  }

  void _removeTime(String time) {
    setState(() {
      _reminderTimes.remove(time);
    });
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n('med_name_error'))),
      );
      return;
    }

    final medicine = Medicine(
      id: widget.medicine?.id ?? generateUuid(),
      name: _nameController.text.trim(),
      dosage: _selectedUnit ?? context.l10n('tablet'), 
      startDate: widget.medicine?.startDate ?? DateTime.now().toIso8601String().substring(0, 10),
      frequency: _selectedFrequency,
      hungerStatus: _hungerStatus,
      totalStock: widget.medicine?.totalStock ?? _currentStock,
      currentStock: _currentStock,
      reminderTimes: _reminderTimes,
      daysOfWeek: _selectedFrequency == 'weekly' ? _selectedDays : null,
      interval: _selectedFrequency == 'custom' ? _customInterval : null,
      createdAt: widget.medicine?.createdAt ?? DateTime.now(),
    );

    if (widget.medicine != null) {
      await ref.read(medicineListProvider.notifier).updateMedicine(medicine);
    } else {
      await ref.read(medicineListProvider.notifier).addMedicine(medicine);
      // AI Ad Engine: Track action
      
      // Achievement: Track medicine added
      ref.read(achievementProvider.notifier).track("med_added", value: 1);
      // Mission: Track medicine (if applicable)
      ref.read(dailyMissionProvider.notifier).track("med_daily");
    }
    
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
          widget.medicine != null ? context.l10n('edit') : context.l10n('add_medicine'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İlaç Adı
            _buildSectionLabel(context.l10n('medicine_name')),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                decoration: InputDecoration(
                  icon: Icon(Icons.medication_rounded, color: isDark ? Colors.white38 : Colors.blueGrey),
                  hintText: context.l10n('med_name_hint'),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Kullanım Sıklığı
            _buildSectionLabel(context.l10n('frequency')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: _frequencyKeys.map((key) {
                  final label = context.l10n(key);
                  final selected = _selectedFrequency == key;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFrequency = key);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? (isDark ? AppColors.medicalBlue : Colors.white) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (selected && !isDark)
                              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              color: selected
                                  ? (isDark ? Colors.white : AppColors.medicalBlue)
                                  : (isDark ? Colors.white38 : Colors.blueGrey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _buildScheduleExtension(isDark),
            const SizedBox(height: 24),

            // Hatırlatma Saatleri
            _buildSectionLabel(context.l10n('reminder_times')),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  ..._reminderTimes.map((t) => _buildTimeChip(t, isDark)),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, size: 16, color: AppColors.medicalBlue),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n('add'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.medicalBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Mevcut Stok
            _buildSectionLabel(context.l10n('current_stock')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildStockButton(Icons.remove_rounded, () {
                            if (_currentStock > 0) setState(() => _currentStock--);
                          }, isDark),
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Text(
                              _currentStock.toString(),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                            ),
                          ),
                          _buildStockButton(Icons.add_rounded, () {
                            setState(() => _currentStock++);
                          }, isDark),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedUnit ?? context.l10n('tablet'),
                              isExpanded: true,
                              items: _units.map((u) {
                                return DropdownMenuItem(
                                  value: u,
                                  child: Text(u, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedUnit = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF005DA7).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFF005DA7), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.l10n('stock_warning'),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF005DA7), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Hero Card Visual
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF005DA7), Color(0xFF2976C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.1,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Icon(Icons.medication_liquid_rounded, size: 100, color: Colors.white),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n('hero_health_tip'),
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          context.l10n('hero_consistency'),
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF005DA7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }


  Widget _buildTimeChip(String time, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD4E3FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF001C39)),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeTime(time),
            child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF004883)),
          ),
        ],
      ),
    );
  }

  Widget _buildStockButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.medicalBlue, size: 20),
      ),
    );
  }

  Widget _buildScheduleExtension(bool isDark) {
    if (_selectedFrequency == 'daily') return const SizedBox.shrink();

    if (_selectedFrequency == 'weekly') {
      final days = [
        {'id': 1, 'label': context.l10n('day_monday_very_short')},
        {'id': 2, 'label': context.l10n('day_tuesday_very_short')},
        {'id': 3, 'label': context.l10n('day_wednesday_very_short')},
        {'id': 4, 'label': context.l10n('day_thursday_very_short')},
        {'id': 5, 'label': context.l10n('day_friday_very_short')},
        {'id': 6, 'label': context.l10n('day_saturday_very_short')},
        {'id': 7, 'label': context.l10n('day_sunday_very_short')},
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final id = day['id'] as int;
              final label = day['label'] as String;
              final isSelected = _selectedDays.contains(id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_selectedDays.length > 1) _selectedDays.remove(id);
                    } else {
                      _selectedDays.add(id);
                      _selectedDays.sort();
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.medicalBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.medicalBlue : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.blueGrey),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              context.l10n('med_frequency_days_desc') != 'med_frequency_days_desc' 
                ? context.l10n('med_frequency_days_desc')
                : 'Select the days you take this medicine.',
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.1);
    }

    if (_selectedFrequency == 'custom') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n('custom_freq_title'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.medicalBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$_customInterval ${context.l10n('days') != 'days' ? context.l10n('days') : 'Days'}",
                    style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.medicalBlue, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _customInterval.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              activeColor: AppColors.medicalBlue,
              onChanged: (val) => setState(() => _customInterval = val.toInt()),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.1);
    }

    return const SizedBox.shrink();
  }
}
