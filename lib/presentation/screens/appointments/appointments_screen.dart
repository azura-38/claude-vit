import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/appointment.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../providers/appointment_providers.dart';
import '../../providers/profile_provider.dart';
import '../../../domain/enums/appointment_category.dart';
import '../../providers/limit_providers.dart';
import '../../widgets/limits/limit_dialog.dart';
import '../../../data/services/limit_service.dart';
import '../../providers/premium_provider.dart';
import '../../widgets/app_empty_state.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  // 'all' is a sentinel; otherwise stores AppointmentCategory.key (locale-stable)
  String _activeCategory = 'all';
  String _viewType = 'monthly';
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aptsAsync = ref.watch(appointmentListProvider);
    final userPhoto = ref.watch(profilePhotoProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(userPhoto, isDark),
            Expanded(
              child: aptsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${context.l10n('error')}: $e')),
                data: (apts) {
                  final nextApt = _findNextApt(apts);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (nextApt != null) ...[
                          const SizedBox(height: 20),
                          _buildHeroCard(nextApt, isDark),
                        ],
                        const SizedBox(height: 24),
                        _buildCalendarSection(isDark),
                        const SizedBox(height: 24),
                        _buildAppointmentsHeader(),
                        const SizedBox(height: 16),
                        _buildCategoryFilters(isDark),
                        const SizedBox(height: 24),
                        _buildAppointmentsList(apts, isDark),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddNewAppointment(),
        backgroundColor: AppColors.medicalBlue,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildHeader(String? photo, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
              backgroundImage: (photo != null && photo.startsWith('http')) ? NetworkImage(photo) : null,
              child: (photo == null || !photo.startsWith('http')) ? const Icon(Icons.person, size: 20, color: Colors.blueGrey) : null,
            ),
          Text(
            context.l10n('app_slogan'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.medicalBlue,
              fontFamily: 'Manrope',
            ),
          ),
          Stack(
            children: [
              Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white70 : Colors.blueGrey, size: 28),
              Positioned(
                right: 4,
                top: 4,
                child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Appointment apt, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue600, AppColors.blue700],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue600.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n('upcoming_appointment'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            apt.department,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                "${_formatRelativeDate(apt.date)}, ${apt.time} • ${apt.doctor}",
                style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n('location'), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(
                        apt.location ?? apt.hospital,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 24),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildCalendarSection(bool isDark) {
    if (_viewType == 'weekly') {
      return _buildWeeklyCalendar(isDark);
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode).format(_focusedMonth),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 20),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 20),
                    onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(bool isDark) {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show 2 weeks
        itemBuilder: (context, index) {
          final day = startOfWeek.add(Duration(days: index - 3)); // Start a few days back
          final isSelected = DateFormatter.formatIso(day) == DateFormatter.formatIso(_selectedDate);
          final isToday = DateFormatter.formatIso(day) == DateFormatter.formatIso(DateTime.now());
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.medicalBlue : (isDark ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? [BoxShadow(color: AppColors.medicalBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayShort(day),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white70 : Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  if (isToday && !isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: AppColors.medicalBlue, shape: BoxShape.circle),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekdayShort(DateTime date) {
    final weekdays = [
      '',
      context.l10n('day_monday_very_short'),
      context.l10n('day_tuesday_very_short'),
      context.l10n('day_wednesday_very_short'),
      context.l10n('day_thursday_very_short'),
      context.l10n('day_friday_very_short'),
      context.l10n('day_saturday_very_short'),
      context.l10n('day_sunday_very_short'),
    ];
    return weekdays[date.weekday];
  }

  Widget _buildCalendarGrid(bool isDark) {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOffset = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday - 1;
    // Note: This weekdays list should ideally be localized properly via intl, but for now we'll stick to a simple PZT-SAL list for TR/EN logic if needed
    final weekdays = [
      context.l10n('day_monday_short'),
      context.l10n('day_tuesday_short'),
      context.l10n('day_wednesday_short'),
      context.l10n('day_thursday_short'),
      context.l10n('day_friday_short'),
      context.l10n('day_saturday_short'),
      context.l10n('day_sunday_short'),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdays.map((d) => SizedBox(
            width: 32,
            child: Center(child: Text(d, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.blueGrey.withValues(alpha: 0.6)))),
          )).toList(),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: daysInMonth + firstDayOffset,
          itemBuilder: (context, index) {
            if (index < firstDayOffset) return const SizedBox();
            final day = index - firstDayOffset + 1;
            final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
            final isSelected = DateFormatter.formatIso(date) == DateFormatter.formatIso(_selectedDate);
            final isToday = DateFormatter.formatIso(date) == DateFormatter.formatIso(DateTime.now());

            return GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.medicalBlue : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.medicalBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.textPrimary.withValues(alpha: day < DateTime.now().day && _focusedMonth.month == DateTime.now().month ? 0.3 : 1.0)),
                        ),
                      ),
                      if (isToday && !isSelected)
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.medicalBlue, shape: BoxShape.circle)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(context.l10n('my_appointments'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Manrope')),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _handleAddNewAppointment(),
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.medicalBlue),
              tooltip: context.l10n('add_new_appointment'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.blueGrey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              _buildViewTypeToggle('weekly', context.l10n('weekly')),
              _buildViewTypeToggle('monthly', context.l10n('monthly')),
            ],
          ),
        ),
      ],
    );
  }

  void _handleAddNewAppointment() {
    final apts = ref.read(appointmentListProvider).asData?.value ?? [];

    final canAdd = LimitService.canAdd(
      current: apts.length,
      baseLimit: LimitService.appointmentLimit,
      extra: ref.read(limitProvider).extraAppointment,
      isPremium: ref.read(premiumProvider),
    );

    if (!canAdd) {
      showLimitDialog(
        context,
        title: context.l10n('limit_appt_title'),
        description: context.l10n('limit_appt_desc'),
        onRewardEarned: () {
          ref.read(limitProvider.notifier).increaseExtraAppointment(5);
          ref.read(limitProvider.notifier).onRewardedAdCompleted();
        },
      );
      return;
    }

    context.push(AppRoutes.appointmentAdd)
        .then((_) => ref.read(appointmentListProvider.notifier).refresh());
  }

  Widget _buildViewTypeToggle(String key, String label) {
    final active = _viewType == key;
    return GestureDetector(
      onTap: () => setState(() => _viewType = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.medicalBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (active) 
              BoxShadow(
                color: AppColors.medicalBlue.withValues(alpha: 0.2), 
                blurRadius: 8, 
                offset: const Offset(0, 2)
              )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.w900, 
            color: active ? Colors.white : Colors.blueGrey,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(bool isDark) {
    // Map each category to its localized display label while keeping the stored key stable.
    final categoryItems = <Map<String, String>>[
      {'key': 'all', 'label': context.l10n('all')},
      {'key': AppointmentCategory.doctor.key, 'label': context.l10n('doctor')},
      {'key': AppointmentCategory.meeting.key, 'label': context.l10n('category_meeting')},
      {'key': AppointmentCategory.reminder.key, 'label': context.l10n('category_reminder')},
      {'key': AppointmentCategory.other.key, 'label': context.l10n('category_other')},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categoryItems.map((item) {
          final active = _activeCategory == item['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeCategory = item['key']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.medicalBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [if (active) BoxShadow(color: AppColors.medicalBlue.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Text(
                  item['label']!,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: active ? Colors.white : Colors.blueGrey),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> apts, bool isDark) {
    final filtered = apts.where((a) {
      if (_activeCategory != 'all' &&
          a.department != _activeCategory &&
          a.type != _activeCategory) {
        return false;
      }
      return true;
    }).toList()..sort((a, b) => a.date.compareTo(b.date));

    if (filtered.isEmpty) return _buildEmptyState(isDark);

    final grouped = <String, List<Appointment>>{};
    for (final a in filtered) {
      grouped.putIfAbsent(a.date, () => []).add(a);
    }

    final dates = grouped.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final date in dates) ...[
          _buildSectionTitle(_formatRelativeDate(date).toUpperCase(), isDark),
          const SizedBox(height: 16),
          ...grouped[date]!.map((a) => _AppointmentListCard(appointment: a)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: isDark ? Colors.white38 : Colors.blueGrey.withValues(alpha: 0.6)),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return AppEmptyState(
      icon: Icons.calendar_today_rounded,
      title: context.l10n('no_appointments_found'),
      subtitle: _activeCategory == 'all' 
          ? context.l10n('empty_appointments_desc')
          : context.l10n('empty_appointments_filter_desc'),
      actionLabel: _activeCategory != 'all' 
          ? context.l10n('btn_clear_filters') 
          : context.l10n('btn_add_appointment'),
      onAction: () {
        if (_activeCategory != 'all') {
          setState(() => _activeCategory = 'all');
        } else {
          _handleAddNewAppointment();
        }
      },
    );
  }

  Appointment? _findNextApt(List<Appointment> apts) {
    if (apts.isEmpty) return null;
    final now = DateTime.now();
    final todayStr = DateFormatter.formatIso(now);
    
    final upcoming = apts.where((a) => a.date.compareTo(todayStr) >= 0).toList()
      ..sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        return cmp != 0 ? cmp : a.time.compareTo(b.time);
      });
    
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  String _formatRelativeDate(String dateStr) {
    final now = DateTime.now();
    final today = DateFormatter.formatIso(now);
    final tomorrow = DateFormatter.formatIso(now.add(const Duration(days: 1)));
    
    if (dateStr == today) return context.l10n('today');
    if (dateStr == tomorrow) return context.l10n('tomorrow');
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    return DateFormat('d MMMM', Localizations.localeOf(context).languageCode).format(d);
  }
}

class _AppointmentListCard extends ConsumerWidget {
  final Appointment appointment;
  const _AppointmentListCard({required this.appointment});

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
        children: [
          Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.blue50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _monthShort(appointment.date),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.medicalBlue),
                ),
                Text(
                  appointment.date.split('-').last,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.medicalBlue),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appointment.department,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Manrope'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.blueGrey),
                      onSelected: (val) {
                        if (val == 'edit') {
                          context.push(AppRoutes.appointmentAdd, extra: appointment);
                        } else if (val == 'delete') {
                          _showDeleteConfirm(context, ref, appointment);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [const Icon(Icons.edit_rounded, size: 18), const SizedBox(width: 8), Text(context.l10n('edit'))]),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [const Icon(Icons.delete_rounded, size: 18, color: AppColors.error), const SizedBox(width: 8), Text(context.l10n('delete'), style: const TextStyle(color: AppColors.error))]),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Text(
                  "${appointment.location ?? appointment.hospital} • ${appointment.time}",
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.blueGrey.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, size: 14, color: Colors.blueGrey),
                    ),
                    if (appointment.meetingLink != null) ...[
                      const Spacer(),
                      const Icon(Icons.link_rounded, size: 14, color: AppColors.medicalBlue),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n('join_meeting'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.medicalBlue),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Appointment app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n('delete')),
        content: Text(context.l10n('delete_confirm_appointment')),
        actions: [
          TextButton(onPressed: () => context.pop(), child: Text(context.l10n('cancel'))),
          TextButton(
            onPressed: () {
              ref.read(appointmentListProvider.notifier).deleteAppointment(app.id);
              context.pop();
            },
            child: Text(context.l10n('delete'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _monthShort(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '';
    // Use DateFormatter (assuming it's imported or available via core utils)
    return DateFormatter.monthShort(d).toUpperCase();
  }
}
