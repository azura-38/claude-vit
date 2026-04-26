import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../../domain/entities/medical_record.dart';
import '../../providers/medical_info_providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/banner_ad_container.dart';

class MedicalInfoScreen extends ConsumerWidget {
  const MedicalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recordsAsync = ref.watch(medicalRecordListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const BannerAdContainer(),
            _buildHeader(context, isDark),
            Expanded(
              child: recordsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${context.l10n('error')}: $e')),
                data: (records) {
                  if (records.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.medical_services_outlined,
                      title: context.l10n('no_records'),
                      subtitle: context.l10n('medical_info_desc_empty'),
                      actionLabel: context.l10n('add_new_record'),
                      onAction: () => _showAddSheet(context),
                    );
                  }

                  final critical = records.where((r) => r.category == MedicalCategory.critical).toList();
                  final important = records.where((r) => r.category == MedicalCategory.important).toList();
                  final general = records.where((r) => r.category == MedicalCategory.general).toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
                      if (critical.isNotEmpty) ...[
                        _buildSectionHeader(context.l10n('category_critical'), AppColors.error),
                        const SizedBox(height: 16),
                        ...critical.map((r) => _MedicalRecordCard(record: r)),
                        const SizedBox(height: 32),
                      ],
                      if (important.isNotEmpty) ...[
                        _buildSectionHeader(context.l10n('category_important'), AppColors.warning),
                        const SizedBox(height: 16),
                        ...important.map((r) => _MedicalRecordCard(record: r)),
                        const SizedBox(height: 32),
                      ],
                      if (general.isNotEmpty) ...[
                        _buildSectionHeader(context.l10n('category_general'), AppColors.info),
                        const SizedBox(height: 16),
                        ...general.map((r) => _MedicalRecordCard(record: r)),
                        const SizedBox(height: 100),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.medicalBlue,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: const Icon(Icons.chevron_left_rounded, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n('important_info'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n('medical_info_desc'),
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const _AddMedicalRecordSheet(),
      ),
    );
  }
}

class _MedicalRecordCard extends ConsumerWidget {
  final MedicalRecord record;
  const _MedicalRecordCard({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getCategoryColor(record.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getIconData(record.iconName), color: _getCategoryColor(record.category), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(record.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Manrope')),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textTertiary),
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'delete', child: Text(context.l10n('delete'), style: const TextStyle(color: AppColors.error))),
                      ],
                      onSelected: (val) {
                        if (val == 'delete') {
                          ref.read(medicalRecordListProvider.notifier).deleteRecord(record.id);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  record.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Color _getCategoryColor(MedicalCategory category) {
    switch (category) {
      case MedicalCategory.critical: return AppColors.error;
      case MedicalCategory.important: return AppColors.warning;
      case MedicalCategory.general: return AppColors.info;
    }
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'allergy': return Icons.science_rounded;
      case 'asthma': return Icons.air_rounded;
      case 'blood': return Icons.bloodtype_rounded;
      case 'lens': return Icons.visibility_rounded;
      case 'diet': return Icons.restaurant_rounded;
      case 'sleep': return Icons.nightlight_round;
      default: return Icons.info_outline_rounded;
    }
  }
}

class _AddMedicalRecordSheet extends ConsumerStatefulWidget {
  const _AddMedicalRecordSheet();

  @override
  ConsumerState<_AddMedicalRecordSheet> createState() => _AddMedicalRecordSheetState();
}

class _AddMedicalRecordSheetState extends ConsumerState<_AddMedicalRecordSheet> {
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  MedicalCategory _category = MedicalCategory.critical;
  String _iconName = 'allergy';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.blueGrey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(context.l10n('add_new_record'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Manrope')),
              const SizedBox(height: 24),
              
              _field('${context.l10n('title')} *', _titleC, 'Örn: Penisilin Alerjisi', isDark),
              _field('${context.l10n('description')} *', _descC, 'Örn: İlaç kullanımı öncesi belirtilmeli.', isDark, maxLines: 3),
              
              Text(context.l10n('category'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Row(
                children: MedicalCategory.values.map((cat) {
                  final active = _category == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: active ? _getCategoryColor(cat) : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getCategoryLabel(cat), 
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.blueGrey)
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              Text(context.l10n('icon'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: ['allergy', 'asthma', 'blood', 'lens', 'diet', 'sleep'].map((icon) {
                  final active = _iconName == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _iconName = icon),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: active ? AppColors.medicalBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getIconData(icon), color: active ? Colors.white : Colors.blueGrey, size: 24),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 32),
              AppButton(label: context.l10n('save_record'), onPressed: _save, color: AppColors.medicalBlue),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, String hint, bool isDark, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        TextField(
          controller: c, 
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ]),
    );
  }

  String _getCategoryLabel(MedicalCategory category) {
    switch (category) {
      case MedicalCategory.critical: return context.l10n('critical');
      case MedicalCategory.important: return context.l10n('important');
      case MedicalCategory.general: return context.l10n('general');
    }
  }

  Color _getCategoryColor(MedicalCategory category) {
    switch (category) {
      case MedicalCategory.critical: return AppColors.error;
      case MedicalCategory.important: return AppColors.warning;
      case MedicalCategory.general: return AppColors.info;
    }
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'allergy': return Icons.science_rounded;
      case 'asthma': return Icons.air_rounded;
      case 'blood': return Icons.bloodtype_rounded;
      case 'lens': return Icons.visibility_rounded;
      case 'diet': return Icons.restaurant_rounded;
      case 'sleep': return Icons.nightlight_round;
      default: return Icons.info_outline_rounded;
    }
  }

  Future<void> _save() async {
    if (_titleC.text.trim().isEmpty || _descC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n('fill_required_fields'))));
      return;
    }
    final record = MedicalRecord(
      id: generateUuid(),
      title: _titleC.text.trim(),
      description: _descC.text.trim(),
      category: _category,
      iconName: _iconName,
      createdAt: DateTime.now(),
    );
    await ref.read(medicalRecordListProvider.notifier).addRecord(record);
    if (mounted) context.pop();
  }
}
