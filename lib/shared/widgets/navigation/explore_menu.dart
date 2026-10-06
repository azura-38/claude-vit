import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/external_launcher.dart';
import '../../providers/navigation_provider.dart';

class ExploreMenu extends ConsumerStatefulWidget {
  const ExploreMenu({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<ExploreMenu> createState() => _ExploreMenuState();
}

class _ExploreMenuState extends ConsumerState<ExploreMenu> with TickerProviderStateMixin {
  final Set<int> _expandedSections = {};



  void _toggleSection(int index) {
    setState(() {
      if (_expandedSections.contains(index)) {
        _expandedSections.remove(index);
      } else {
        _expandedSections.add(index);
      }
    });
  }

  void _navigateAndClose(VoidCallback action) {
    action();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final sections = _buildSections(context, ref, isDark, primary);

    return GestureDetector(
      onTap: widget.onClose,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.75 : 0.45)),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.exploreFabStart, AppColors.exploreFabEnd]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.explore_rounded, color: Colors.white, size: 22),
                            ).animate(onPlay: (c) => c.repeat(reverse: true)).rotate(begin: -0.02, end: 0.02, duration: 2000.ms, curve: Curves.easeInOut),
                            const SizedBox(width: 12),
                            Text(
                              context.l10n.explore.toUpperCase(),
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: isDark ? Colors.white : AppColors.textPrimary),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), shape: BoxShape.circle),
                            child: Icon(Icons.close_rounded, size: 22, color: isDark ? Colors.white70 : AppColors.textSecondary),
                          ).animate().fadeIn(duration: 200.ms).rotate(begin: 0.25, end: 0, duration: 300.ms),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: sections.length,
                        itemBuilder: (context, index) => _buildSection(context, sections[index], index, isDark, primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_SectionData> _buildSections(BuildContext context, WidgetRef ref, bool isDark, Color primary) {
    return [
      _SectionData(
        icon: Icons.favorite_rounded,
        title: context.l10n.healthData,
        color: const Color(0xFF14B8A6),
        items: [
          _MenuItem(
            icon: Icons.monitor_heart_rounded,
            label: context.l10n.healthStats,
            subtitle: context.l10n.healthStatsDesc,
            color: const Color(0xFF14B8A6),
            onTap: () => _navigateAndClose(() => context.pushNamed('healthStats')),
          ),
          _MenuItem(
            icon: Icons.add_chart_rounded,
            label: context.l10n.addHealthData,
            subtitle: context.l10n.addData,
            color: const Color(0xFF0D9488),
            onTap: () => _navigateAndClose(() => context.pushNamed('healthDataAdd')),
          ),
        ],
      ),
      _SectionData(
        icon: Icons.medication_rounded,
        title: context.l10n.medicines,
        color: AppColors.orange400,
        items: [
          _MenuItem(
            icon: Icons.medication_liquid_rounded,
            label: context.l10n.myMedicines,
            subtitle: context.l10n.medicineCabinet,
            color: AppColors.orange500,
            onTap: () => _navigateAndClose(() => context.pushNamed('medicines')),
          ),
          _MenuItem(
            icon: Icons.add_circle_rounded,
            label: context.l10n.addMedicine,
            subtitle: context.l10n.medCabinetAdd,
            color: AppColors.orange400,
            onTap: () => _navigateAndClose(() => context.pushNamed('medicineAdd')),
          ),
        ],
      ),
      _SectionData(
        icon: Icons.description_rounded,
        title: context.l10n.vault,
        color: AppColors.medicalBlue,
        items: [
          _MenuItem(
            icon: Icons.folder_special_rounded,
            label: context.l10n.allRecords,
            subtitle: context.l10n.docsTitle,
            color: AppColors.medicalBlue,
            onTap: () => _navigateAndClose(() => ref.read(navigationProvider.notifier).setIndex(1)),
          ),
          _MenuItem(
            icon: Icons.add_to_drive_rounded,
            label: context.l10n.addDocument,
            subtitle: context.l10n.docsInfoSecure,
            color: AppColors.blue600,
            onTap: () => _navigateAndClose(() => context.pushNamed('documentAdd')),
          ),
        ],
      ),
      _SectionData(
        icon: Icons.calendar_month_rounded,
        title: context.l10n.appointments,
        color: const Color(0xFFF43F5E),
        items: [
          _MenuItem(
            icon: Icons.event_note_rounded,
            label: context.l10n.myAppointments,
            subtitle: context.l10n.createTodayPlan,
            color: const Color(0xFFF43F5E),
            onTap: () => _navigateAndClose(() => ref.read(navigationProvider.notifier).setIndex(3)),
          ),
          _MenuItem(
            icon: Icons.add_alarm_rounded,
            label: context.l10n.addNewAppointment,
            subtitle: context.l10n.planTimeDesc,
            color: const Color(0xFFE11D48),
            onTap: () => _navigateAndClose(() => context.pushNamed('appointmentAdd')),
          ),
        ],
      ),
      _SectionData(
        icon: Icons.people_alt_rounded,
        title: context.tr('people_contacts'),
        color: AppColors.teal500,
        items: [
          _MenuItem(
            icon: Icons.contact_phone_rounded,
            label: context.tr('people_contacts'),
            subtitle: context.tr('contacts_subtitle'),
            color: AppColors.teal500,
            onTap: () => _navigateAndClose(() => context.pushNamed('doctors')),
          ),
          _MenuItem(
            icon: Icons.person_add_alt_1_rounded,
            label: context.tr('add_contact'),
            subtitle: context.tr('add_contact_subtitle'),
            color: AppColors.teal600,
            onTap: () => _navigateAndClose(() => context.pushNamed('doctorAdd')),
          ),
          _MenuItem(
            icon: Icons.location_on_rounded,
            label: context.l10n.pharmacies,
            subtitle: '📍 Google Maps',
            color: AppColors.success,
            onTap: () => _navigateAndClose(() => ExternalLauncher.launchMapSearch(context.l10n.pharmacies)),
          ),
        ],
      ),
      _SectionData(
        icon: Icons.info_rounded,
        title: context.l10n.importantInfo,
        color: const Color(0xFFEF4444),
        items: [
          _MenuItem(
            icon: Icons.emergency_rounded,
            label: context.l10n.emergencyInfo,
            subtitle: context.l10n.emergencyCard,
            color: const Color(0xFFEF4444),
            onTap: () => _navigateAndClose(() => context.pushNamed('medicalInfo')),
          ),
          _MenuItem(
            icon: Icons.badge_rounded,
            label: context.l10n.personalInfo,
            subtitle: context.l10n.identityContact,
            color: const Color(0xFFDC2626),
            onTap: () => _navigateAndClose(() => context.pushNamed('profilePersonalInfo')),
          ),
        ],
      ),
      _SectionData(
        icon: Icons.person_rounded,
        title: context.l10n.profile,
        color: AppColors.primaryIndigo,
        items: [
          _MenuItem(
            icon: Icons.account_circle_rounded,
            label: context.l10n.profile,
            subtitle: context.l10n.personalHealthData,
            color: AppColors.primaryIndigo,
            onTap: () => _navigateAndClose(() => ref.read(navigationProvider.notifier).setIndex(4)),
          ),
          _MenuItem(
            icon: Icons.settings_rounded,
            label: context.l10n.accountSettings,
            subtitle: context.l10n.appSettings,
            color: AppColors.primaryViolet,
            onTap: () => _navigateAndClose(() => context.pushNamed('settings')),
          ),
          _MenuItem(
            icon: Icons.palette_rounded,
            label: context.l10n.themeBoutique,
            subtitle: context.l10n.themeSettings,
            color: const Color(0xFF8B5CF6),
            onTap: () => _navigateAndClose(() => context.pushNamed('settingsTheme')),
          ),
        ],
      ),
    ];
  }

  Widget _buildSection(BuildContext context, _SectionData section, int sectionIndex, bool isDark, Color primary) {
    final isExpanded = _expandedSections.contains(sectionIndex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)),
        boxShadow: [BoxShadow(color: section.color.withValues(alpha: isExpanded ? 0.08 : 0.03), blurRadius: isExpanded ? 20 : 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _toggleSection(sectionIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    _AnimatedSectionIcon(icon: section.icon, color: section.color, isExpanded: isExpanded),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        section.title.toUpperCase(),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.textPrimary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: section.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text('${section.items.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: section.color)),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: Icon(Icons.expand_more_rounded, size: 22, color: isDark ? Colors.white54 : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                Divider(height: 1, indent: 20, endIndent: 20, color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                ...section.items.asMap().entries.map(
                      (entry) => _buildMenuItem(context, entry.value, entry.key, isDark, isLast: entry.key == section.items.length - 1),
                    ),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    ).animate().fadeIn(delay: (sectionIndex * 60).ms, duration: 350.ms).slideX(begin: sectionIndex.isEven ? -0.08 : 0.08, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item, int itemIndex, bool isDark, {bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(24)) : BorderRadius.zero,
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              _AnimatedMenuIcon(icon: item.icon, color: item.color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.textPrimary)),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isDark ? Colors.white.withValues(alpha: 0.45) : AppColors.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white24 : AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSectionIcon extends StatelessWidget {
  const _AnimatedSectionIcon({required this.icon, required this.color, required this.isExpanded});

  final IconData icon;
  final Color color;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      width: isExpanded ? 44 : 40,
      height: isExpanded ? 44 : 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withValues(alpha: 0.7)]),
        borderRadius: BorderRadius.circular(isExpanded ? 14 : 12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: isExpanded ? 0.4 : 0.2), blurRadius: isExpanded ? 16 : 8, offset: const Offset(0, 3))],
      ),
      child: Icon(icon, color: Colors.white, size: isExpanded ? 22 : 20),
    ).animate(target: isExpanded ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 300.ms, curve: Curves.easeOutBack);
  }
}

class _AnimatedMenuIcon extends StatelessWidget {
  const _AnimatedMenuIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: color.withValues(alpha: isDark ? 0.2 : 0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 18),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.06, 1.06), duration: 2500.ms, curve: Curves.easeInOut);
  }
}

class _SectionData {
  const _SectionData({required this.icon, required this.title, required this.color, required this.items});

  final IconData icon;
  final String title;
  final Color color;
  final List<_MenuItem> items;
}

class _MenuItem {
  const _MenuItem({required this.icon, required this.label, this.subtitle, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
}
