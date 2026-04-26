import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/enums/appointment_status.dart';
import '../../../domain/enums/common_enums.dart';
import '../../providers/appointment_providers.dart';
import '../../providers/achievement_providers.dart';
import '../../providers/daily_mission_providers.dart';
import '../../../core/di/service_providers.dart';
import '../../../core/l10n/app_localizations.dart';

class AppointmentAddScreen extends ConsumerStatefulWidget {
  final Appointment? appointment;
  const AppointmentAddScreen({super.key, this.appointment});

  @override
  ConsumerState<AppointmentAddScreen> createState() =>
      _AppointmentAddScreenState();
}

class _AppointmentAddScreenState extends ConsumerState<AppointmentAddScreen> {
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _personController;
  late TextEditingController _notesController;

  DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  ImportanceLevel importance = ImportanceLevel.medium;
  bool reminder = true;
  String reminderTime = "reminder_10m";
  String repeat = "repeat_none";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.appointment?.title ?? "");
    _locationController = TextEditingController(text: widget.appointment?.hospital ?? "");
    _personController = TextEditingController(text: widget.appointment?.doctor ?? "");
    _notesController = TextEditingController(text: widget.appointment?.notes ?? "");

    if (widget.appointment != null) {
      final app = widget.appointment!;
      final date = DateTime.tryParse(app.date) ?? DateTime.now();
      final timeParts = app.time.split(':');
      if (timeParts.length == 2) {
        selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.tryParse(timeParts[0]) ?? 9,
          int.tryParse(timeParts[1]) ?? 0,
        );
      }
      importance = app.importance;
      reminder = app.reminderTime != null;
      
      // Backward compatibility / normalization
      final rTime = app.reminderTime ?? "reminder_10m";
      if (rTime == "10 dk önce") {
        reminderTime = "reminder_10m";
      } else if (rTime == "1 saat önce") {
        reminderTime = "reminder_1h";
      } else if (rTime == "1 gün önce") {
        reminderTime = "reminder_1d";
      } else {
        reminderTime = rTime;
      }

      final rep = app.repeat ?? "repeat_none";
      if (rep == "Yok") {
        repeat = "repeat_none";
      } else if (rep == "Günlük") {
        repeat = "repeat_daily";
      } else if (rep == "Haftalık") {
        repeat = "repeat_weekly";
      } else {
        repeat = rep;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _personController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => _pickerTheme(context, child),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      builder: (context, child) => _pickerTheme(context, child),
    );

    if (time == null) return;

    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Widget _pickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.medicalBlue,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          widget.appointment != null ? context.l10n('edit_appointment') : context.l10n('new_appointment'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "✨ ${context.l10n('create_today_plan')}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.medicalBlue,
              ),
            ).animate().fadeIn().slideX(begin: -0.2),
            Text(
              context.l10n('plan_time_desc'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

            const SizedBox(height: 32),

            /// TITLE
            _buildLabel(context.l10n('label_title')),
            _buildField(
              hint: context.l10n('hint_title'),
              controller: _titleController,
              isDark: isDark,
            ),

            /// SUGGESTIONS
            Wrap(
              spacing: 8,
              children: [
                _suggestionChip(context.l10n('suggest_doctor'), isDark),
                _suggestionChip(context.l10n('suggest_meeting'), isDark),
                _suggestionChip(context.l10n('suggest_personal'), isDark),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            /// LOCATION
            _buildLabel(context.l10n('label_location')),
            _buildField(
              hint: context.l10n('hint_location'),
              controller: _locationController,
              isDark: isDark,
              icon: Icons.location_on_outlined,
            ),

            /// PERSON
            _buildLabel(context.l10n('label_person')),
            _buildField(
              hint: context.l10n('hint_person'),
              controller: _personController,
              isDark: isDark,
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 24),

            /// DATE TIME
            _buildLabel(context.l10n('label_date_time')),
            GestureDetector(
              onTap: pickDateTime,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.medicalBlue, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "${selectedDateTime.day} ${DateFormatter.getMonthName(selectedDateTime.month, locale: locale)} • "
                      "${selectedDateTime.hour.toString().padLeft(2, '0')}:"
                      "${selectedDateTime.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit_calendar_rounded, color: Colors.grey, size: 18),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            /// IMPORTANCE
            _buildLabel(context.l10n('label_importance')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _importanceCard(context.l10n('importance_low'), ImportanceLevel.low, Colors.green, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _importanceCard(context.l10n('importance_medium'), ImportanceLevel.medium, Colors.orange, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _importanceCard(context.l10n('importance_high'), ImportanceLevel.high, Colors.red, isDark)),
              ],
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            /// REMINDER
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: reminder,
                    activeThumbColor: AppColors.medicalBlue,
                    title: Text(context.l10n('label_reminder'), style: const TextStyle(fontWeight: FontWeight.w800)),
                    onChanged: (v) => setState(() => reminder = v),
                  ),
                  if (reminder) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DropdownButtonFormField<String>(
                        initialValue: reminderTime,
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: [
                          DropdownMenuItem(value: "reminder_10m", child: Text(context.l10n('reminder_10m'))),
                          DropdownMenuItem(value: "reminder_1h", child: Text(context.l10n('reminder_1h'))),
                          DropdownMenuItem(value: "reminder_1d", child: Text(context.l10n('reminder_1d'))),
                        ],
                        onChanged: (v) => setState(() => reminderTime = v!),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 16),

            /// REPEAT
            _buildLabel(context.l10n('label_repeat')),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  initialValue: repeat,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: [
                    DropdownMenuItem(value: "repeat_none", child: Text(context.l10n('repeat_none'))),
                    DropdownMenuItem(value: "repeat_daily", child: Text(context.l10n('repeat_daily'))),
                    DropdownMenuItem(value: "repeat_weekly", child: Text(context.l10n('repeat_weekly'))),
                  ],
                  onChanged: (v) => setState(() => repeat = v!),
                ),
              ),
            ),

            const SizedBox(height: 32),

            /// NOTES
            _buildLabel(context.l10n('label_notes')),
            _buildField(
              hint: context.l10n('hint_notes'),
              controller: _notesController,
              isDark: isDark,
              maxLines: 3,
            ),

            const SizedBox(height: 48),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medicalBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: AppColors.medicalBlue.withValues(alpha: 0.4),
                ),
                child: Text(
                  widget.appointment != null ? context.l10n('save') : context.l10n('add_new_appointment'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).scale(),
          ],
        ),
      ),
    );
  }

  void save() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n('error_title_required'))));
      return;
    }

    final notifTitle = context.l10n('notif_app_created_title');
    final notifBody = context.l10n('notif_app_created_body', extra: {'title': _titleController.text});

    if (widget.appointment != null) {
      final appointment = Appointment(
        id: widget.appointment!.id,
        title: _titleController.text.trim(),
        doctor: _personController.text.trim(),
        department: "General",
        hospital: _locationController.text.trim(),
        person: _personController.text.trim(),
        date: DateFormatter.formatIso(selectedDateTime),
        time: "${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}",
        status: widget.appointment!.status,
        importance: importance,
        notes: _notesController.text.trim(),
        repeat: repeat,
        reminderTime: reminder ? reminderTime : null,
        createdAt: widget.appointment!.createdAt,
      );
      await ref.read(appointmentListProvider.notifier).updateAppointment(appointment);
    } else {
      final appointment = Appointment(
        id: generateUuid(),
        title: _titleController.text.trim(),
        doctor: _personController.text.trim(),
        department: "General",
        hospital: _locationController.text.trim(),
        person: _personController.text.trim(),
        date: DateFormatter.formatIso(selectedDateTime),
        time: "${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}",
        status: AppointmentStatus.upcoming,
        importance: importance,
        notes: _notesController.text.trim(),
        repeat: repeat,
        reminderTime: reminder ? reminderTime : null,
        createdAt: DateTime.now(),
      );
      await ref.read(appointmentListProvider.notifier).addAppointment(appointment);
      ref.read(achievementProvider.notifier).track("app_added", value: 1);
      ref.read(dailyMissionProvider.notifier).track("app_daily");

      if (reminder) {
        _scheduleNotification(selectedDateTime, _titleController.text);
      }

      ref.read(notificationServiceProvider).showNotification(
            id: 111,
            title: notifTitle,
            body: notifBody,
            channelId: "appointments",
            channelName: "Appointments",
          );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n('success'))));
      context.pop();
    }
  }

  Future<void> _scheduleNotification(DateTime dateTime, String title) async {
    final now = DateTime.now();
    if (dateTime.isBefore(now)) return;

    Duration delay;
    switch (reminderTime) {
      case "reminder_10m":
        delay = const Duration(minutes: 10);
        break;
      case "reminder_1h":
        delay = const Duration(hours: 1);
        break;
      case "reminder_1d":
        delay = const Duration(days: 1);
        break;
      default:
        delay = const Duration(minutes: 10);
    }

    final scheduledAt = dateTime.subtract(delay);
    if (scheduledAt.isBefore(now)) return;

    await ref.read(notificationServiceProvider).scheduleNotification(
          id: dateTime.millisecondsSinceEpoch ~/ 1000,
          title: context.l10n('notif_app_reminder_title'),
          body: context.l10n('notif_app_reminder_body', extra: {'title': title}),
          scheduledDate: scheduledAt,
          channelId: "appointment_reminders",
          channelName: "Appointment Reminders",
        );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.medicalBlue, size: 20) : null,
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          ),
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  Widget _suggestionChip(String text, bool isDark) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
      backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onPressed: () => setState(() => _titleController.text = text),
    );
  }

  Widget _importanceCard(String label, ImportanceLevel lvl, Color color, bool isDark) {
    final isSelected = importance == lvl;
    return GestureDetector(
      onTap: () => setState(() => importance = lvl),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined, color: isSelected ? color : Colors.grey, size: 16),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? color : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
