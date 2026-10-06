import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/notifications/app_notification_payload.dart';
import '../../../../core/types/runtime_types.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../features/appointments/domain/entities/appointment.dart';
import '../../../../features/appointments/presentation/providers/appointment_providers.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/medications/domain/entities/medicine.dart';
import '../../../../features/notifications/presentation/providers/notification_controller.dart';
import '../../../../shared/data/services/ad_service.dart';
import '../../../../shared/data/services/notification_engine.dart';
import '../../../../shared/data/services/usage_limit_service.dart';
import '../../../../shared/data/services/wipe_service.dart';
import '../../../../shared/domain/entities/doctor.dart';
import '../../../../shared/domain/entities/health_metric.dart';
import '../../../../shared/domain/enums/appointment_status.dart';
import '../../../../shared/domain/enums/common_enums.dart';
import '../../../../shared/providers/app_info_provider.dart';
import '../../../../shared/providers/doctor_providers.dart';
import '../../../../shared/providers/document_providers.dart';
import '../../../../shared/providers/health_providers.dart';
import '../../../../shared/providers/medicine_providers.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';
import '../../../../shared/providers/user_preferences_controller.dart';
import '../../../../shared/widgets/vitacase_banner_ad.dart';

class DebugPanelScreen extends ConsumerStatefulWidget {
  const DebugPanelScreen({super.key});

  @override
  ConsumerState<DebugPanelScreen> createState() => _DebugPanelScreenState();
}

class _DebugPanelScreenState extends ConsumerState<DebugPanelScreen> {
  List<PendingNotificationRequest> _pendingNotifications = [];
  bool _isLoadingPending = false;
  NotificationPermissionState? _permissionState;
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationQueue();
    _checkPermissions();
  }

  bool _isTr(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'tr';

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadNotificationQueue() async {
    setState(() => _isLoadingPending = true);
    try {
      final list = await NotificationEngine.getPendingNotificationRequests();
      if (mounted) {
        setState(() {
          _pendingNotifications = list;
          _isLoadingPending = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPending = false);
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isCheckingPermission = true);
    try {
      final state = await NotificationEngine.checkPermissionStatus();
      if (mounted) {
        setState(() {
          _permissionState = state;
          _isCheckingPermission = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isCheckingPermission = false);
    }
  }

  Future<void> _requestPermissions() async {
    final tr = _isTr(context);
    final result = await NotificationEngine.requestPermissions(requestExactAlarm: true);
    setState(() => _permissionState = result);
    _snack(
      result == NotificationPermissionState.granted
          ? (tr ? 'Bildirim izinleri verildi ✅' : 'Notification permissions granted ✅')
          : (tr ? 'Bildirim izni reddedildi ❌' : 'Notification permission denied ❌'),
    );
  }

  Future<void> _seedSampleData() async {
    final tr = _isTr(context);
    try {
      // 1. Sample Medicine
      final now = DateTime.now();
      final sampleMed = Medicine(
        id: 'debug_med_${now.millisecondsSinceEpoch}',
        name: tr ? 'Parol 500mg' : 'Paracetamol 500mg',
        dosage: tr ? '1 tablet' : '1 pill',
        startDate: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
        frequency: tr ? 'Günde 2 kez' : 'Twice daily',
        hungerStatus: HungerStatus.tok,
        currentStock: 20,
        totalStock: 30,
        reminderTimes: const ['09:00', '21:00'],
        createdAt: now,
      );
      try {
        await ref.read(medicineListProvider.notifier).addMedicine(sampleMed);
      } catch (_) {
        // If daily limit prevents addMedicine through usecase, refresh list
      }

      // 2. Sample Doctor
      final sampleDoc = Doctor(
        id: 'debug_doc_${now.millisecondsSinceEpoch}',
        title: 'Dr.',
        name: tr ? 'Ahmet Yılmaz' : 'Dr. John Smith',
        department: tr ? 'Kardiyoloji' : 'Cardiology',
        hospital: tr ? 'Şehir Hastanesi' : 'City Central Hospital',
        phone: '+90 555 123 4567',
        gender: Gender.male,
        createdAt: now,
      );
      await ref.read(doctorListProvider.notifier).addDoctor(sampleDoc);

      // 3. Sample Appointment
      final tomorrow = now.add(const Duration(days: 1));
      final sampleApt = Appointment(
        id: 'debug_apt_${now.millisecondsSinceEpoch}',
        title: tr ? 'Rutin Kardiyoloji Kontrolü' : 'Routine Cardiology Checkup',
        doctor: sampleDoc.name,
        department: sampleDoc.department,
        hospital: sampleDoc.hospital,
        date: "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}",
        time: '10:30',
        status: AppointmentStatus.upcoming,
        createdAt: now,
      );
      try {
        await ref.read(appointmentListProvider.notifier).addAppointment(sampleApt);
      } catch (_) {}

      // 4. Sample Health Metric
      final sampleHealth = HealthMetric(
        id: 'debug_health_${now.millisecondsSinceEpoch}',
        type: HealthMetricType.water,
        value: 1750,
        timestamp: now,
      );
      await ref.read(healthListProvider.notifier).addMetric(sampleHealth);

      _snack(tr ? 'Örnek test verileri başarıyla yüklendi! 🎉' : 'Sample test data loaded successfully! 🎉');
    } catch (e) {
      _snack(tr ? 'Örnek veri yükleme hatası: $e' : 'Failed to seed sample data: $e');
    }
  }

  Future<void> _confirmWipeData() async {
    final tr = _isTr(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr ? 'Tüm Verileri Temizle?' : 'Wipe All Data?'),
        content: Text(
          tr
              ? 'Tüm yerel veritabanı, kaydedilmiş belgeler, randevular ve ilaçlar kalıcı olarak silinecek. Bu işlem geri alınamaz.'
              : 'All local database records, documents, appointments, and medicines will be deleted permanently. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text(tr ? 'İptal' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ctx.pop(true),
            child: Text(tr ? 'Evet, Temizle' : 'Yes, Wipe Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await WipeService.fullWipe();
        ref.invalidate(medicineListProvider);
        ref.invalidate(doctorListProvider);
        ref.invalidate(appointmentListProvider);
        ref.invalidate(documentListProvider);
        ref.invalidate(healthListProvider);
        ref.invalidate(userPreferencesControllerProvider);
        await _loadNotificationQueue();
        _snack(tr ? 'Tüm veriler temizlendi ve sıfırlandı.' : 'All data wiped and reset.');
      } catch (e) {
        _snack(tr ? 'Sıfırlama hatası: $e' : 'Wipe error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = _isTr(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prefs = ref.watch(sharedPreferencesProvider);
    final appInfo = ref.watch(packageInfoProvider).asData?.value;
    final lastErrorMessage = prefs.getString('last_error_message');
    final lastErrorStack = prefs.getString('last_error_stack');
    final lastErrorTs = prefs.getInt('last_error_ts');

    final medicineCount = ref.watch(medicineListProvider).value?.length ?? 0;
    final appointmentCount = ref.watch(appointmentListProvider).value?.length ?? 0;
    final doctorCount = ref.watch(doctorListProvider).value?.length ?? 0;
    final documentCount = ref.watch(documentListProvider).value?.length ?? 0;
    final hasPin = ref.watch(hasPinProvider).value ?? false;
    final appLockState = ref.watch(appLockStateProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(tr ? 'Debug & Tanılama Paneli' : 'Debug & Diagnostics Panel'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: tr ? 'Kuyruğu Yenile' : 'Refresh Queue',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _loadNotificationQueue();
              _checkPermissions();
              _snack(tr ? 'Veriler güncellendi.' : 'Data refreshed.');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _DebugHeader(
            isDark: isDark,
            appVersion: '${appInfo?.version ?? '1.0.0'} (${appInfo?.buildNumber ?? '1'})',
          ),
          const SizedBox(height: 20),

          // 1. NOTIFICATION ENGINE
          _DebugSection(
            title: tr ? '🔔 Bildirimler & Hatırlatıcı Motoru' : '🔔 Notifications & Reminder Engine',
            isDark: isDark,
            children: [
              // Permission info row
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.medicalBlue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _permissionState == NotificationPermissionState.granted
                            ? Icons.check_circle_rounded
                            : Icons.warning_rounded,
                        color: _permissionState == NotificationPermissionState.granted
                            ? Colors.green
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isCheckingPermission
                              ? (tr ? 'İzin durumu sorgulanıyor...' : 'Checking permission status...')
                              : '${tr ? 'İzin Durumu:' : 'Permission Status:'} ${_permissionState?.name.toUpperCase() ?? 'UNKNOWN'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: _requestPermissions,
                        child: Text(tr ? 'İzin İste' : 'Request'),
                      ),
                    ],
                  ),
                ),
              ),
              _DebugActionTile(
                icon: Icons.notifications_active_rounded,
                title: tr ? 'Anlık test bildirimi gönder' : 'Send instant test notification',
                subtitle: tr
                    ? 'Bildirim izni ve anlık ses/titreşim bildirimini hemen test eder.'
                    : 'Instantly tests notification permission, sound, and vibration.',
                onTap: () async {
                  await ref.read(notificationControllerProvider).testNotification();
                  _snack(tr ? 'Anlık test bildirimi tetiklendi.' : 'Instant test notification triggered.');
                  await _loadNotificationQueue();
                },
              ),
              _DebugActionTile(
                icon: Icons.medication_rounded,
                title: tr ? '1 dk sonrası ilaç bildirimi kur' : 'Schedule medicine notification in 1 min',
                subtitle: tr
                    ? 'Exact alarm + Aldım/Almadım butonlarını test eder.'
                    : 'Tests exact alarm and Taken/Not taken action buttons.',
                onTap: () async {
                  final when = DateTime.now().add(const Duration(minutes: 1));
                  await NotificationEngine.scheduleMedicine(
                    id: 'debug_medicine_${when.millisecondsSinceEpoch}',
                    title: tr ? '💊 VitaCase İlaç Testi' : '💊 VitaCase Medicine Test',
                    body: tr ? 'Bu bir ilaç hatırlatma testidir.' : 'This is a medicine reminder test.',
                    scheduleTime: when,
                    payload: AppNotificationPayload(
                      type: NotificationType.medication,
                      entityId: 'debug_medicine',
                      occurrenceAt: when,
                    ).encode(),
                  );
                  _snack(tr ? 'İlaç bildirimi 1 dakika sonrasına kuruldu.' : 'Medicine notification scheduled for 1 minute later.');
                  await _loadNotificationQueue();
                },
              ),
              _DebugActionTile(
                icon: Icons.calendar_month_rounded,
                title: tr ? '1 dk sonrası randevu bildirimi kur' : 'Schedule appointment notification in 1 min',
                subtitle: tr
                    ? 'Randevu exact alarm sistemini test eder.'
                    : 'Tests the appointment exact alarm flow.',
                onTap: () async {
                  final when = DateTime.now().add(const Duration(minutes: 1));
                  await NotificationEngine.scheduleAppointment(
                    id: 'debug_appointment_${when.millisecondsSinceEpoch}',
                    title: tr ? '📅 VitaCase Randevu Testi' : '📅 VitaCase Appointment Test',
                    body: tr ? 'Bu bir randevu hatırlatma testidir.' : 'This is an appointment reminder test.',
                    scheduleTime: when,
                    payload: AppNotificationPayload(
                      type: NotificationType.appointment,
                      entityId: 'debug_appointment',
                      occurrenceAt: when,
                    ),
                  );
                  _snack(tr ? 'Randevu bildirimi 1 dakika sonrasına kuruldu.' : 'Appointment notification scheduled for 1 minute later.');
                  await _loadNotificationQueue();
                },
              ),
              _DebugActionTile(
                icon: Icons.schedule_send_rounded,
                title: tr ? '1 dk sonrası engagement bildirimi kur' : 'Schedule engagement notification in 1 min',
                subtitle: tr
                    ? 'Rastgele bir kategori seçerek 1 dakika sonrasına kurar.'
                    : 'Schedules a random engagement notification for 1 minute later.',
                onTap: () async {
                  await NotificationEngine.testScheduleEngagementIn1Minute();
                  _snack(tr ? 'Engagement bildirimi 1 dakika sonrasına kuruldu.' : 'Engagement notification scheduled for 1 minute later.');
                  await _loadNotificationQueue();
                },
              ),
              _DebugActionTile(
                icon: Icons.send_and_archive_rounded,
                title: tr ? 'Rastgele engagement bildirimi gönder' : 'Send random engagement notification now',
                subtitle: tr ? 'Hemen rastgele bir engagement bildirimi gönderir.' : 'Triggers a random engagement notification immediately.',
                onTap: () async {
                  await NotificationEngine.testSendEngagementNow();
                  _snack(tr ? 'Engagement bildirimi tetiklendi.' : 'Engagement notification triggered.');
                },
              ),
              // Queue management & purge
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${tr ? 'Kuyruktaki Bildirimler:' : 'Pending Queue:'} ${_isLoadingPending ? '...' : _pendingNotifications.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 18),
                            onPressed: _loadNotificationQueue,
                            tooltip: tr ? 'Yenile' : 'Refresh',
                          ),
                        ],
                      ),
                      if (_pendingNotifications.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ..._pendingNotifications.take(4).map((p) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.alarm, size: 14, color: AppColors.medicalBlue),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'ID: ${p.id} ${p.payload != null ? "(${p.payload})" : ""}',
                                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await NotificationEngine.cancelById(p.id);
                                      await _loadNotificationQueue();
                                      _snack(tr ? 'Bildirim ${p.id} iptal edildi.' : 'Notification ${p.id} cancelled.');
                                    },
                                    child: const Icon(Icons.close, size: 16, color: AppColors.error),
                                  ),
                                ],
                              ),
                            )),
                        if (_pendingNotifications.length > 4)
                          Text(
                            tr ? '+${_pendingNotifications.length - 4} bildirim daha...' : '+${_pendingNotifications.length - 4} more notifications...',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              _DebugActionTile(
                icon: Icons.cancel_presentation_rounded,
                title: tr ? 'TÜM bildirimleri iptal et' : 'Cancel ALL notifications',
                subtitle: tr ? 'Kuyruktaki ve bekleyen tüm bildirimleri tamamen temizler.' : 'Completely cancels all scheduled and pending notifications.',
                iconColor: AppColors.error,
                onTap: () async {
                  await NotificationEngine.cancelAll();
                  await _loadNotificationQueue();
                  _snack(tr ? 'Tüm bildirimler iptal edildi ve temizlendi.' : 'All notifications cancelled and purged.');
                },
              ),
              _DebugActionTile(
                icon: Icons.cancel_schedule_send_rounded,
                title: tr ? 'Engagement bildirimlerini iptal et' : 'Cancel engagement notifications',
                subtitle: tr ? 'Yalnızca planlanmış engagement bildirimlerini temizler.' : 'Cancels scheduled engagement notifications only.',
                onTap: () async {
                  await NotificationEngine.cancelEngagementNotifications();
                  await _loadNotificationQueue();
                  _snack(tr ? 'Engagement bildirimleri iptal edildi.' : 'Engagement notifications cancelled.');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. DATA, MOCK SEED & STORAGE
          _DebugSection(
            title: tr ? '💾 Veri, Mock & Depolama Yönetimi' : '💾 Data, Mock & Storage Management',
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr ? 'Mevcut Veritabanı Kayıt Sayıları:' : 'Current Database Record Counts:',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatBadge(label: tr ? 'İlaç' : 'Meds', count: medicineCount, icon: Icons.medication_outlined),
                          _StatBadge(label: tr ? 'Randevu' : 'Apts', count: appointmentCount, icon: Icons.calendar_today_outlined),
                          _StatBadge(label: tr ? 'Doktor' : 'Docs', count: doctorCount, icon: Icons.person_outline),
                          _StatBadge(label: tr ? 'Belge' : 'Vault', count: documentCount, icon: Icons.folder_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _DebugActionTile(
                icon: Icons.restart_alt_rounded,
                title: tr ? 'Günlük kullanım limitini sıfırla' : 'Reset daily usage limits',
                subtitle: tr
                    ? 'Günlük belge ekleme ve test sınırlarını hemen 0 yapar.'
                    : 'Immediately resets daily creation & testing counters to 0.',
                onTap: () async {
                  await ref.read(usageLimitServiceProvider).resetTodayForDebug();
                  _snack(tr ? 'Günlük kullanım limitleri sıfırlandı!' : 'Daily limits reset successfully!');
                },
              ),
              _DebugActionTile(
                icon: Icons.playlist_add_check_circle_rounded,
                title: tr ? 'Örnek test verilerini yükle (Seed Data)' : 'Load sample test data (Seed Data)',
                subtitle: tr
                    ? 'Hızlı test için örnek ilaç, doktor, randevu ve sağlık kaydı oluşturur.'
                    : 'Populates sample medicine, doctor, appointment and health metric for testing.',
                onTap: _seedSampleData,
              ),
              _DebugActionTile(
                icon: Icons.delete_forever_rounded,
                title: tr ? 'Tüm verileri temizle (Factory Reset)' : 'Wipe all data (Factory Reset)',
                subtitle: tr
                    ? 'Veritabanını, şifreli anahtarları ve belgeleri temizler.'
                    : 'Clears database, encrypted keys, and stored documents.',
                iconColor: AppColors.error,
                onTap: _confirmWipeData,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. SECURITY & APP LOCK
          _DebugSection(
            title: tr ? '🔒 Güvenlik & Uygulama Kilidi' : '🔒 Security & App Lock',
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                child: Row(
                  children: [
                    Icon(
                      hasPin ? Icons.lock_outline : Icons.lock_open_rounded,
                      color: hasPin ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PIN: ${hasPin ? (tr ? "Tanımlı (Aktif)" : "Configured") : (tr ? "Yok" : "None")}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: appLockState == AppLockState.locked
                            ? Colors.red.withValues(alpha: 0.15)
                            : Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appLockState.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: appLockState == AppLockState.locked ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _DebugActionTile(
                icon: Icons.screen_lock_portrait_rounded,
                title: tr ? 'Kilit ekranını test et' : 'Test lock screen now',
                subtitle: tr ? 'Doğrudan PIN kilit ekranına yönlendirir.' : 'Directly navigates to the PIN lock screen.',
                onTap: () {
                  context.push(AppRoutes.lock);
                },
              ),
              _DebugActionTile(
                icon: Icons.key_off_rounded,
                title: tr ? 'PIN kodunu sıfırla' : 'Reset stored PIN',
                subtitle: tr
                    ? 'Secure Storage üzerindeki PIN kodunu ve kilit ayarını temizler.'
                    : 'Clears the PIN from secure storage and disables lock.',
                onTap: () async {
                  await ref.read(pinServiceProvider).clearPin();
                  await ref.read(userPreferencesControllerProvider.notifier).updateSecurity(appLockEnabled: false);
                  ref.invalidate(hasPinProvider);
                  _snack(tr ? 'PIN kodu ve kilit sıfırlandı.' : 'PIN and lock reset.');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. ADMOB REKLAM LABORATUVARI
          _DebugSection(
            title: tr ? '📢 AdMob Reklam Laboratuvarı' : '📢 AdMob Ad Testing Lab',
            isDark: isDark,
            children: [
              _DebugBannerTestCard(isDark: isDark),
              _DebugActionTile(
                icon: Icons.open_in_full_rounded,
                title: tr ? 'App Open reklamı test et' : 'Test App Open ad',
                subtitle: '${AppConfig.appOpenAdId}\nStatus: ${AdService.appOpenState.name}',
                onTap: () async {
                  final shown = await AdService.showAppOpenAd(ignoreCooldown: true);
                  _snack(
                    shown
                        ? (tr ? 'App Open reklamı gösterildi ✅' : 'App Open ad shown ✅')
                        : (tr ? 'App Open reklamı gösterilemedi / hazır değil ❌' : 'App Open ad failed / not ready ❌'),
                  );
                },
              ),
              _DebugActionTile(
                icon: Icons.ads_click_rounded,
                title: tr ? 'Interstitial reklamı test et' : 'Test interstitial ad',
                subtitle: '${AppConfig.interstitialAdId}\nStatus: ${AdService.interstitialState.name}',
                onTap: () async {
                  final shown = await AdService.showInterstitial(ignoreCooldown: true);
                  _snack(
                    shown
                        ? (tr ? 'Interstitial reklam gösterildi ✅' : 'Interstitial ad shown ✅')
                        : (tr ? 'Interstitial reklam gösterilemedi / hazır değil ❌' : 'Interstitial ad failed / not ready ❌'),
                  );
                },
              ),
              _DebugActionTile(
                icon: Icons.card_giftcard_rounded,
                title: tr ? 'Rewarded reklamı test et' : 'Test rewarded ad',
                subtitle: '${AppConfig.rewardedAdId}\nStatus: ${AdService.rewardedState.name}',
                onTap: () async {
                  final ok = await AdService.showRewardedAd();
                  _snack(
                    ok
                        ? (tr ? 'Ödül başarıyla alındı ✅' : 'Reward earned successfully ✅')
                        : (tr ? 'Rewarded reklam gösterilemedi ❌' : 'Rewarded ad unavailable ❌'),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. SENTRY CRASH TEST & DIAGNOSTICS
          _DebugSection(
            title: tr ? '🚨 Sentry & Hata Tanılama' : '🚨 Sentry & Error Diagnostics',
            isDark: isDark,
            children: [
              _DebugActionTile(
                icon: Icons.bug_report_rounded,
                title: tr ? 'Sentry test hatası gönder' : 'Send Sentry test error',
                subtitle: AppConfig.sentryDsn.isEmpty ? 'DSN empty' : 'DSN configured',
                onTap: () async {
                  await Sentry.captureException(
                    StateError('VitaCase debug panel Sentry test @ ${DateTime.now().toIso8601String()}'),
                  );
                  _snack(tr ? 'Sentry test hatası gönderildi.' : 'Sentry test error sent.');
                },
              ),
              if (lastErrorTs != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr ? 'Son Kaydedilen Hata:' : 'Last Recorded Error:',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tr ? 'Tarih' : 'Date'}: ${DateTime.fromMillisecondsSinceEpoch(lastErrorTs).toLocal()}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : const Color.fromRGBO(0, 0, 0, 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lastErrorMessage ?? '',
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                _DebugActionTile(
                  icon: Icons.mail_outline_rounded,
                  title: tr ? 'Son hatayı e-posta ile gönder' : 'Email last recorded error',
                  subtitle: tr ? 'Tüm hata detaylarını mail olarak geliştiriciye iletir.' : 'Sends the full crash details to developers.',
                  onTap: () {
                    final body = '''
VitaCase System Error Report
============================
Timestamp: ${DateTime.fromMillisecondsSinceEpoch(lastErrorTs).toLocal()}
Device info: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}
App Version: ${appInfo?.version ?? '1.0.0'} (${appInfo?.buildNumber ?? '1'})

Error Message:
$lastErrorMessage

Stack Trace:
$lastErrorStack
''';
                    ExternalLauncher.launchEmail(
                      'limanexsoftware@outlook.com',
                      subject: 'VitaCase System Error Report',
                      body: body,
                    );
                  },
                ),
                _DebugActionTile(
                  icon: Icons.delete_outline_rounded,
                  title: tr ? 'Hata kaydını temizle' : 'Clear recorded error',
                  subtitle: tr ? 'SharedPreferences üzerindeki hata logunu sıfırlar.' : 'Resets the error logs cached on device.',
                  onTap: () async {
                    await prefs.remove('last_error_message');
                    await prefs.remove('last_error_stack');
                    await prefs.remove('last_error_ts');
                    _snack(tr ? 'Hata kaydı temizlendi.' : 'Error log cleared.');
                  },
                ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                  child: Text(
                    tr
                        ? 'Kayıtlı herhangi bir hata bulunamadı. Uygulama düzgün çalışıyor.'
                        : 'No errors have been recorded. The app is running smoothly.',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                _DebugActionTile(
                  icon: Icons.mail_outline_rounded,
                  title: tr ? 'Uygulama raporunu e-posta ile gönder' : 'Email App Diagnostic Report',
                  subtitle: tr ? 'Genel cihaz ve yapılandırma raporunu iletir.' : 'Sends a general diagnostic report of the app.',
                  onTap: () {
                    final body = '''
VitaCase App Diagnostic Report
==============================
Timestamp: ${DateTime.now()}
Device info: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}
App Version: ${appInfo?.version ?? '1.0.0'} (${appInfo?.buildNumber ?? '1'})
Debug Mode: $kDebugMode
Status: OK (No errors recorded)
''';
                    ExternalLauncher.launchEmail(
                      'limanexsoftware@outlook.com',
                      subject: 'VitaCase General Diagnostic Report',
                      body: body,
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // 6. CONFIG & ENVIRONMENT SUMMARY
          _DebugSection(
            title: tr ? '⚙️ Yapılandırma & Çevre Özeti' : '⚙️ Config & Environment Summary',
            isDark: isDark,
            children: [
              _ConfigRow(label: 'Build Mode', value: kDebugMode ? 'DEBUG (Test Ads Active)' : 'RELEASE'),
              _ConfigRow(label: 'App Version', value: '${appInfo?.version ?? '1.0.0'} (${appInfo?.buildNumber ?? '1'})'),
              _ConfigRow(label: 'Platform', value: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'),
              _ConfigRow(label: 'Sentry DSN', value: AppConfig.sentryDsn.isEmpty ? 'missing' : 'configured ✅'),
              _ConfigRow(label: 'AdMob App ID', value: AppConfig.admobAppId),
              _ConfigRow(label: 'App Open ID', value: AppConfig.appOpenAdId),
              _ConfigRow(label: 'Banner ID', value: AppConfig.bannerAdId),
              _ConfigRow(label: 'Interstitial ID', value: AppConfig.interstitialAdId),
              _ConfigRow(label: 'Rewarded ID', value: AppConfig.rewardedAdId),
              _ConfigRow(label: 'Rewarded Status', value: AdService.rewardedState.name),
              _ConfigRow(label: 'Premium', value: AppConfig.premiumEnabled ? 'true' : 'V1 disabled'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.count, required this.icon});

  final String label;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.medicalBlue),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _DebugHeader extends StatelessWidget {
  const _DebugHeader({required this.isDark, required this.appVersion});

  final bool isDark;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final tr = Localizations.localeOf(context).languageCode == 'tr';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.medicalBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.developer_mode_rounded, color: AppColors.medicalBlue, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tr ? 'VitaCase Test & Debug' : 'VitaCase Test & Debug',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            kDebugMode ? 'DEBUG' : 'RELEASE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: kDebugMode ? Colors.green : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'v$appVersion',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tr
                ? 'Bu panel üzerinden AdMob reklam birimlerini test edebilir, bildirim kuyruğunu inceleyebilir, mock veri yükleyebilir ve sistem hatalarını teşhis edebilirsiniz.'
                : 'Use this panel to test AdMob units, inspect notification queues, populate mock test data, and diagnose system crashes.',
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugSection extends StatelessWidget {
  const _DebugSection({required this.title, required this.children, required this.isDark});

  final String title;
  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _DebugBannerTestCard extends StatelessWidget {
  const _DebugBannerTestCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tr = Localizations.localeOf(context).languageCode == 'tr';
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : AppColors.cardBorderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.view_day_rounded, size: 18, color: AppColors.medicalBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr ? 'Banner reklam testi' : 'Banner ad test',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr
                  ? 'Aşağıdaki alanda banner yüklenirse AdMob çalışıyor demektir. Hata görünürse Logcat’te VitaCaseBannerAd satırını kontrol edin.'
                  : 'If a banner loads below, AdMob is functioning properly. If an error appears, check VitaCaseBannerAd in Logcat.',
              style: TextStyle(fontSize: 12, height: 1.35, color: isDark ? Colors.white70 : AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const VitaCaseBannerAd(
              ignoreVisibilityPolicy: true,
              showPlaceholderWhenLoading: true,
              showFailureMessage: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugActionTile extends StatelessWidget {
  const _DebugActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor ?? AppColors.medicalBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5)),
      trailing: const Icon(Icons.play_arrow_rounded, size: 20),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        ],
      ),
    );
  }
}
