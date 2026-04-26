import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_providers.dart';
import '../../providers/theme_provider.dart';
import '../../providers/backup_providers.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/locale_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/services/wipe_service.dart';
import '../../../data/services/smart_notification_system.dart';
import '../../../core/di/service_providers.dart'
    show notificationServiceProvider;
import '../../providers/app_info_provider.dart';
import '../../widgets/banner_ad_container.dart';
import '../../../data/services/analytics_service.dart';
import '../../providers/notification_settings_provider.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  int _versionTapCount = 0;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLockEnabled = ref.watch(appLockEnabledProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentTimeout = ref.watch(lockTimeoutProvider);
    final quickActions = ref.watch(quickActionsProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          context.l10n('app_settings'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const BannerAdContainer(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTrustCard(context, isDark),
                  const SizedBox(height: 32),
                  // --- APPEARANCE SECTION ---
                  _buildSectionTitle(context.l10n('appearance'), isDark),
                  const SizedBox(height: 12),
                  _buildSectionCard([
                    _buildSettingTile(
                      icon: Icons.palette_rounded,
                      iconColor: Colors.purple,
                      title: context.l10n('theme_settings'),
                      subtitle: context.l10n('theme_${currentThemeMode.name}'),
                      onTap: () => context.pushNamed('settingsTheme'),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.language_rounded,
                      iconColor: Colors.teal,
                      title: context.l10n('select_language'),
                      subtitle: _getLanguageName(
                        ref.watch(localeProvider).languageCode,
                      ),
                      onTap: () => _showLanguageSelector(context, ref),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.restore_rounded,
                      iconColor: Colors.indigo,
                      title: context.l10n('backup_restore'),
                      subtitle: context.l10n('backup_desc_settings'),
                      onTap: () => _showBackupSelector(context, ref),
                      isDark: isDark,
                      isLast: true,
                    ),
                  ], isDark),

                  const SizedBox(height: 32),
                  // --- APP LOGIC SECTION ---
                  _buildSectionTitle(context.l10n('app_section'), isDark),
                  const SizedBox(height: 12),
                  _buildSectionCard([
                    _buildSettingTile(
                      icon: Icons.bolt_rounded,
                      iconColor: Colors.amber,
                      title: context.l10n('quick_actions'),
                      subtitle: quickActions ? context.l10n('active') : context.l10n('inactive'),
                      onTap:
                          () => ref
                              .read(quickActionsProvider.notifier)
                              .setEnabled(!quickActions),
                      trailing: Switch(
                        value: quickActions,
                        onChanged:
                            (val) => ref
                                .read(quickActionsProvider.notifier)
                                .setEnabled(val),
                      ),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.text_fields_rounded,
                      iconColor: Colors.indigo,
                      title: context.l10n('text_size'),
                      subtitle: context.l10n('text_size_medium'),
                      onTap: () => _showTextSizeSelector(context),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.notifications_active_outlined,
                      iconColor: Colors.blue,
                      title: context.l10n('smart_notifications'),
                      subtitle:
                          notificationSettings.smartNotificationsEnabled
                              ? '${context.l10n('active')} 🔔'
                              : context.l10n('inactive'),
                      trailing: Switch(
                        value: notificationSettings.smartNotificationsEnabled,
                        onChanged: (value) async {
                          await ref
                              .read(notificationSettingsProvider.notifier)
                              .updateSettings(
                                notificationSettings.copyWith(
                                  smartNotificationsEnabled: value,
                                ),
                              );
                          await SmartNotificationService.setEnabled(value);
                          if (value && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n('notifications_active_msg')),
                              ),
                            );
                          }
                        },
                      ),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.visibility_off_outlined,
                      iconColor: Colors.deepOrange,
                      title: context.l10n('show_sensitive_details'),
                      subtitle:
                          notificationSettings.showSensitiveDetails
                              ? context.l10n('sensitive_details_visible')
                              : context.l10n('sensitive_details_hidden'),
                      trailing: Switch(
                        value: notificationSettings.showSensitiveDetails,
                        onChanged: (value) async {
                          await ref
                              .read(notificationSettingsProvider.notifier)
                              .updateSettings(
                                notificationSettings.copyWith(
                                  showSensitiveDetails: value,
                                ),
                              );
                          await ref
                              .read(notificationServiceProvider)
                              .setHideSensitiveContent(!value);
                        },
                      ),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.do_not_disturb_on_rounded,
                      iconColor: Colors.deepPurple,
                      title: context.l10n('quiet_hours'),
                      subtitle:
                          notificationSettings.quietHoursEnabled
                              ? '${_timeLabel(notificationSettings.quietHoursStart, notificationSettings.quietHoursStartMinute).format(context)} - ${_timeLabel(notificationSettings.quietHoursEnd, notificationSettings.quietHoursEndMinute).format(context)}'
                              : '${context.l10n('inactive')} 🌙',
                      onTap: () => _showQuietHoursSelector(context, ref),
                      trailing: Switch(
                        value: notificationSettings.quietHoursEnabled,
                        onChanged: (value) async {
                          await ref
                              .read(notificationSettingsProvider.notifier)
                              .updateSettings(
                                notificationSettings.copyWith(
                                  quietHoursEnabled: value,
                                ),
                              );
                          if (value && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.l10n('quiet_hours_msg')),
                              ),
                            );
                          }
                        },
                      ),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.bug_report_outlined,
                      iconColor: Colors.orange,
                      title: context.l10n('test_notification'),
                      subtitle: context.l10n('test_notification_desc'),
                      onTap: () {
                        SmartNotificationService.showNow(
                          context.l10n('test_notification_body'),
                        );
                      },
                      isDark: isDark,
                      isLast: true,
                    ),
                  ], isDark),

                  const SizedBox(height: 32),
                  // --- SECURITY SECTION ---
                  _buildSectionTitle(context.l10n('data_security'), isDark),
                  const SizedBox(height: 12),
                  _buildSectionCard([
                    _buildSettingTile(
                      icon: Icons.lock_rounded,
                      iconColor: Colors.green,
                      title: context.l10n('app_lock'),
                      subtitle:
                          isLockEnabled
                              ? context.l10n('active')
                              : context.l10n('inactive'),

                      trailing: Switch(
                        value: isLockEnabled,
                        onChanged: (val) async {
                          if (val) {
                            final service = ref.read(appLockServiceProvider);
                            final available = await service.isAvailable();
                            if (!available) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n('app_lock_unavailable'),
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            final success = await service.authenticate();
                            if (success) {
                              await ref
                                  .read(appLockEnabledProvider.notifier)
                                  .setEnabled(true);
                              ref
                                  .read(appLockStateProvider.notifier)
                                  .setUnlocked();
                              AnalyticsService.log(
                                AnalyticsService.appLockAuthSuccess,
                              );
                              AnalyticsService.log(
                                AnalyticsService.appLockEnabled,
                              );
                            } else {
                              AnalyticsService.log(
                                AnalyticsService.appLockAuthFail,
                              );
                            }
                          } else {
                            await ref
                                .read(appLockEnabledProvider.notifier)
                                .setEnabled(false);
                            AnalyticsService.log(
                              AnalyticsService.appLockDisabled,
                            );
                          }
                        },
                      ),
                      isDark: isDark,
                    ),
                    if (isLockEnabled)
                      _buildSettingTile(
                        icon: Icons.timer_outlined,
                        iconColor: Colors.orange,
                        title: context.l10n('lock_timeout'),
                        subtitle: currentTimeout.localizedLabel(context),
                        onTap: () => _showTimeoutSelector(context, ref),
                        isDark: isDark,
                      ),
                    _buildSettingTile(
                      icon: Icons.cloud_download_rounded,
                      iconColor: Colors.blue,
                      title: context.l10n('export_data_zip'),
                      onTap:
                          () =>
                              ref
                                  .read(backupActionProvider.notifier)
                                  .exportBackup(),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: Colors.red,
                      title: context.l10n('clear_all_data'),
                      onTap: () => _showWipeDialog(context, ref),
                      isDark: isDark,
                      isLast: true,
                    ),
                  ], isDark),

                  const SizedBox(height: 32),
                  // --- LEGAL SECTION ---
                  _buildSectionTitle(context.l10n('legal'), isDark),
                  const SizedBox(height: 12),
                  _buildSectionCard([
                    _buildSettingTile(
                      icon: Icons.article_outlined,
                      iconColor: Colors.grey,
                      title: context.l10n('privacy_policy'),
                      onTap: () => context.pushNamed('settingsPrivacy'),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.gavel_rounded,
                      iconColor: Colors.grey,
                      title: context.l10n('terms_conditions'),
                      onTap: () => context.pushNamed('settingsTerms'),
                      isDark: isDark,
                    ),
                    _buildSettingTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.grey,
                      title: context.l10n('legal_disclaimer'),
                      onTap: () => context.pushNamed('settingsDisclaimer'),
                      isDark: isDark,
                      isLast: true,
                    ),
                  ], isDark),

                  const SizedBox(height: 40),
                  _buildVersionFooter(context, ref, isDark),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBackupSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color:
                  Theme.of(ctx).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n('backup_restore'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n('backup_restore_desc'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildActionTile(
                    context: context,
                    icon: Icons.cloud_upload_rounded,
                    color: Colors.blue,
                    title: context.l10n('backup_export'),
                    subtitle: context.l10n('backup_export_desc'),
                    isComingSoon: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n('coming_soon'))),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context: context,
                    icon: Icons.cloud_download_rounded,
                    color: Colors.green,
                    title: context.l10n('backup_import'),
                    subtitle: context.l10n('backup_import_desc'),
                    isComingSoon: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n('coming_soon'))),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      if (isComingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            context.l10n('coming_soon').toUpperCase(),
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }


  void _showQuietHoursSelector(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final startTime = _timeLabel(
      settings.quietHoursStart,
      settings.quietHoursStartMinute,
    );
    final endTime = _timeLabel(
      settings.quietHoursEnd,
      settings.quietHoursEndMinute,
    );
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color:
                  Theme.of(ctx).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n('quiet_hours'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 24),
                ListTile(
                  title: Text(context.l10n('start_time')),
                  subtitle: Text(startTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (time != null) {
                      await ref
                          .read(notificationSettingsProvider.notifier)
                          .updateSettings(
                            settings.copyWith(
                              quietHoursStart: time.hour,
                              quietHoursStartMinute: time.minute,
                            ),
                          );
                    }
                  },
                ),
                ListTile(
                  title: Text(context.l10n('end_time')),
                  subtitle: Text(endTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (time != null) {
                      await ref
                          .read(notificationSettingsProvider.notifier)
                          .updateSettings(
                            settings.copyWith(
                              quietHoursEnd: time.hour,
                              quietHoursEndMinute: time.minute,
                            ),
                          );
                    }
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.l10n('ok')),
                ),
              ],
            ),
          ),
    );
  }

  TimeOfDay _timeLabel(int hour, int minute) =>
      TimeOfDay(hour: hour, minute: minute);

  void _showTimeoutSelector(BuildContext context, WidgetRef ref) {
    final current = ref.watch(lockTimeoutProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(ctx).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    ctx.l10n('lock_timeout'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...LockTimeout.values.map((timeout) {
                    final isSelected = current == timeout;
                    return ListTile(
                      title: Text(
                        timeout.localizedLabel(context),
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w500,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryIndigo,
                              )
                              : null,
                      onTap: () {
                        ref
                            .read(lockTimeoutProvider.notifier)
                            .setTimeout(timeout);
                        if (ctx.canPop()) ctx.pop();
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: isDark ? Colors.white38 : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          subtitle:
              subtitle != null
                  ? Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : AppColors.textSecondary,
                    ),
                  )
                  : null,
          trailing:
              trailing ??
              (onTap != null
                  ? const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  )
                  : null),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Divider(
              height: 1,
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
            ),
          ),
      ],
    );
  }

  String _getLanguageName(String code) {
    return supportedLanguages
        .firstWhere(
          (language) => language.code == code,
          orElse: () => const SupportedLanguage('en', 'English'),
        )
        .name;
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(ctx).brightness == Brightness.dark
                      ? AppColors.surfaceDark
                      : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    ctx.l10n('select_language'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...supportedLanguages.map(
                    (language) =>
                        _langItem(ctx, ref, language.code, language.name),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  Widget _langItem(
    BuildContext context,
    WidgetRef ref,
    String code,
    String name,
  ) {
    final current = ref.watch(localeProvider).languageCode;
    final isSelected = current == code;
    return ListTile(
      leading: const Icon(Icons.language_rounded),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
        ),
      ),
      trailing:
          isSelected
              ? const Icon(
                Icons.check_circle_rounded,
                color: AppColors.medicalBlue,
              )
              : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(code);
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      },
    );
  }

  Widget _buildVersionFooter(BuildContext context, WidgetRef ref, bool isDark) {
    final packageInfo = ref.watch(packageInfoProvider);
    return packageInfo.maybeWhen(
      data:
          (info) => Center(
            child: Text(
              'V ${info.version} (BUILD ${info.buildNumber})',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white24 : AppColors.textTertiary,
              ),
            ),
          ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  void _showWipeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              ctx.l10n('clear_all_data'),
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(ctx.l10n('wipe_confirm_1')),
            actions: [
              TextButton(
                onPressed: () {
                  if (ctx.canPop()) ctx.pop();
                },
                child: Text(ctx.l10n('cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (ctx.canPop()) ctx.pop();
                  await WipeService.fullWipe();
                  ref.invalidate(onboardingCompletedProvider);
                  if (context.mounted) context.go(AppRoutes.onboarding);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: Text(
                  ctx.l10n('delete'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showTextSizeSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n('text_size'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(context.l10n('text_size_small')),
              leading: const Icon(Icons.text_fields),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text(context.l10n('text_size_medium')),
              leading: const Icon(Icons.text_fields, size: 28),
              trailing: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryIndigo,
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text(context.l10n('text_size_large')),
              leading: const Icon(Icons.text_fields, size: 36),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryIndigo.withValues(alpha: 0.12),
            AppColors.primaryIndigo.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.primaryIndigo.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColors.primaryIndigo,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() => _versionTapCount++);
                        if (_versionTapCount >= 10) {
                          _versionTapCount = 0;
                          SmartNotificationService.showNow(
                            context.l10n('test_notification_body'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Easter Egg: Test notification sent! 🚀")),
                          );
                        }
                      },
                      child: Text(
                        context.l10n('free_secure_release').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n('premium_soon'),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
