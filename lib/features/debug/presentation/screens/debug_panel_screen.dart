import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/notifications/app_notification_payload.dart';
import '../../../../features/notifications/presentation/providers/notification_controller.dart';
import '../../../../shared/data/services/ad_service.dart';
import '../../../../shared/data/services/notification_engine.dart';

class DebugPanelScreen extends ConsumerWidget {
  const DebugPanelScreen({super.key});

  bool _isTr(BuildContext context) => Localizations.localeOf(context).languageCode == 'tr';

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = _isTr(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: Text(tr ? 'Debug Paneli' : 'Debug Panel'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          _DebugHeader(isDark: isDark),
          const SizedBox(height: 20),
          _DebugSection(
            title: tr ? 'Bildirimler' : 'Notifications',
            isDark: isDark,
            children: [
              _DebugActionTile(
                icon: Icons.notifications_active_rounded,
                title: tr ? 'Anlık test bildirimi gönder' : 'Send instant test notification',
                subtitle: tr ? 'Bildirim izni ve notification motorunu hızlı test eder.' : 'Quickly tests notification permission and the notification engine.',
                onTap: () async {
                  await ref.read(notificationControllerProvider).testNotification();
                  if (context.mounted) _snack(context, tr ? 'Anlık test bildirimi tetiklendi.' : 'Instant test notification triggered.');
                },
              ),
              _DebugActionTile(
                icon: Icons.medication_rounded,
                title: tr ? '1 dk sonrası ilaç bildirimi kur' : 'Schedule medicine notification in 1 min',
                subtitle: tr ? 'Exact alarm + Aldım/Almadım butonlarını test eder.' : 'Tests exact alarm and Taken/Not taken actions.',
                onTap: () async {
                  final when = DateTime.now().add(const Duration(minutes: 1));
                  await NotificationEngine.scheduleMedicine(
                    id: 'debug_medicine',
                    title: tr ? '💊 VitaCase İlaç Testi' : '💊 VitaCase Medicine Test',
                    body: tr ? 'Bu bir ilaç hatırlatma testidir.' : 'This is a medicine reminder test.',
                    scheduleTime: when,
                    payload: AppNotificationPayload(
                      type: NotificationType.medication,
                      entityId: 'debug_medicine',
                      occurrenceAt: when,
                    ).encode(),
                  );
                  if (context.mounted) _snack(context, tr ? 'İlaç bildirimi 1 dakika sonrasına kuruldu.' : 'Medicine notification scheduled for 1 minute later.');
                },
              ),
              _DebugActionTile(
                icon: Icons.calendar_month_rounded,
                title: tr ? '1 dk sonrası randevu bildirimi kur' : 'Schedule appointment notification in 1 min',
                subtitle: tr ? 'Randevu exact alarm sistemini test eder.' : 'Tests the appointment exact alarm flow.',
                onTap: () async {
                  final when = DateTime.now().add(const Duration(minutes: 1));
                  await NotificationEngine.scheduleAppointment(
                    id: 'debug_appointment',
                    title: tr ? '📅 VitaCase Randevu Testi' : '📅 VitaCase Appointment Test',
                    body: tr ? 'Bu bir randevu hatırlatma testidir.' : 'This is an appointment reminder test.',
                    scheduleTime: when,
                    payload: AppNotificationPayload(
                      type: NotificationType.appointment,
                      entityId: 'debug_appointment',
                      occurrenceAt: when,
                    ).encode(),
                  );
                  if (context.mounted) _snack(context, tr ? 'Randevu bildirimi 1 dakika sonrasına kuruldu.' : 'Appointment notification scheduled for 1 minute later.');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DebugSection(
            title: 'AdMob',
            isDark: isDark,
            children: [
              _DebugActionTile(
                icon: Icons.open_in_full_rounded,
                title: tr ? 'App Open reklamı test et' : 'Test App Open ad',
                subtitle: AppConfig.appOpenAdId,
                onTap: () async {
                  await AdService.showAppOpenAd();
                  if (context.mounted) _snack(context, tr ? 'App Open reklamı çağrıldı.' : 'App Open ad requested.');
                },
              ),
              _DebugActionTile(
                icon: Icons.ads_click_rounded,
                title: tr ? 'Interstitial reklamı test et' : 'Test interstitial ad',
                subtitle: AppConfig.interstitialAdId,
                onTap: () async {
                  await AdService.showInterstitial();
                  if (context.mounted) _snack(context, tr ? 'Interstitial reklam çağrıldı.' : 'Interstitial ad requested.');
                },
              ),
              _DebugActionTile(
                icon: Icons.card_giftcard_rounded,
                title: tr ? 'Rewarded reklamı test et' : 'Test rewarded ad',
                subtitle: AppConfig.rewardedAdId,
                onTap: () async {
                  final ok = await AdService.showRewardedAd();
                  if (context.mounted) _snack(context, ok ? (tr ? 'Ödül alındı.' : 'Reward earned.') : (tr ? 'Rewarded reklam gösterilemedi.' : 'Rewarded ad unavailable.'));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DebugSection(
            title: 'Sentry',
            isDark: isDark,
            children: [
              _DebugActionTile(
                icon: Icons.bug_report_rounded,
                title: tr ? 'Sentry test hatası gönder' : 'Send Sentry test error',
                subtitle: AppConfig.sentryDsn.isEmpty ? 'DSN empty' : 'DSN configured',
                onTap: () async {
                  await Sentry.captureException(StateError('VitaCase debug panel Sentry test'));
                  if (context.mounted) _snack(context, tr ? 'Sentry test hatası gönderildi.' : 'Sentry test error sent.');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DebugSection(
            title: tr ? 'Config' : 'Config',
            isDark: isDark,
            children: [
              _ConfigRow(label: 'Sentry', value: AppConfig.sentryDsn.isEmpty ? 'missing' : 'configured'),
              _ConfigRow(label: 'AdMob App ID', value: AppConfig.admobAppId),
              _ConfigRow(label: 'Banner ID', value: AppConfig.bannerAdId),
              _ConfigRow(label: 'Native ID', value: AppConfig.nativeAdId),
              _ConfigRow(label: 'Premium V1', value: AppConfig.premiumEnabled ? 'config true / provider disabled' : 'disabled'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DebugHeader extends StatelessWidget {
  const _DebugHeader({required this.isDark});

  final bool isDark;

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
      child: Row(
        children: [
          const Icon(Icons.developer_mode_rounded, color: AppColors.medicalBlue, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              tr
                  ? 'Önce anlık test bildirimi gönder. Gelirse izin tamamdır. Sonra 1 dakika sonrası ilaç/randevu testleri exact alarm sistemini kontrol eder.'
                  : 'First send an instant test notification. If it arrives, permission is OK. Then use the 1-minute medicine/appointment tests to verify exact alarms.',
              style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary, height: 1.35, fontWeight: FontWeight.w600),
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
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _DebugActionTile extends StatelessWidget {
  const _DebugActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.medicalBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.play_arrow_rounded),
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
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
