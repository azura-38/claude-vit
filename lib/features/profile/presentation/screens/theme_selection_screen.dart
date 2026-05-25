import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_unlock_provider.dart';
import '../../../../core/theme/theme_visuals.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class ThemeSelectionScreen extends ConsumerStatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ConsumerState<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends ConsumerState<ThemeSelectionScreen> {
  AppThemeType? _previewTheme;
  bool _loadingAd = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _safePop() {
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/settings');
    }
  }

  Future<void> _apply(AppThemeType type) async {
    final unlock = ref.read(themeUnlockProvider.notifier);
    final isLocked = type.isRewardTheme && !unlock.isUnlocked;

    if (isLocked) {
      await _unlockWithAd(type);
      return;
    }

    await ref.read(themeTypeProvider.notifier).setTheme(type);
    _safePop();
  }

  Future<void> _unlockWithAd(AppThemeType type) async {
    if (_loadingAd) return;
    setState(() => _loadingAd = true);

    final ok = await ref.read(themeUnlockProvider.notifier).watchAdToUnlockOrExtend();

    if (!mounted) return;
    setState(() => _loadingAd = false);

    if (ok) {
      await ref.read(themeTypeProvider.notifier).setTheme(type);
      if (!mounted) return;
      _showMessage(context.l10n.themeUnlocked);
      setState(() {});
    } else {
      _showMessage(context.l10n.adUnavailableTryLater);
    }
  }

  Future<void> _extendOneDay() async {
    if (_loadingAd) return;
    final okStr = context.l10n.oneDayAdded;
    final failStr = context.l10n.adUnavailable;
    setState(() => _loadingAd = true);
    final ok = await ref.read(themeUnlockProvider.notifier).watchAdToUnlockOrExtend();
    if (!mounted) return;
    setState(() => _loadingAd = false);
    _showMessage(ok ? okStr : failStr);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatRemaining(Duration duration) {
    if (duration <= Duration.zero) return '00:00:00';
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (days > 0) return '${days}g $hours:$minutes:$seconds';
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeTypeProvider);
    final unlockUntil = ref.watch(themeUnlockProvider);
    final unlockNotifier = ref.read(themeUnlockProvider.notifier);
    final activePreview = _previewTheme ?? currentTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = unlockNotifier.remainingDuration;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.tr('theme_selection_title')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _safePop,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          _ThemePreview(type: activePreview),
          const SizedBox(height: 20),
          _UnlockStatusCard(
            isUnlocked: unlockUntil != null,
            remainingText: _formatRemaining(remaining),
            loading: _loadingAd,
            onExtend: _extendOneDay,
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: context.l10n.freeThemes),
          const SizedBox(height: 12),
          for (final type in AppThemeType.freeThemes)
            _ThemeTile(
              type: type,
              selected: currentTheme == type,
              locked: false,
              loading: _loadingAd,
              onPreview: () => setState(() => _previewTheme = type),
              onApply: () => _apply(type),
            ),
          const SizedBox(height: 24),
          _SectionTitle(title: context.l10n.rewardThemes),
          const SizedBox(height: 8),
          Text(
            context.l10n.rewardThemesInfo,
            style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          for (final type in AppThemeType.rewardThemes)
            _ThemeTile(
              type: type,
              selected: currentTheme == type,
              locked: !unlockNotifier.isUnlocked,
              loading: _loadingAd,
              onPreview: () => setState(() => _previewTheme = type),
              onApply: () => _apply(type),
            ),
        ],
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.type});

  final AppThemeType type;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getThemeByType(type);
    final visuals = ThemeVisuals.of(type);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Theme(
      data: theme,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: visuals.softGradient,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isDarkTheme ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04)),
          boxShadow: [
            BoxShadow(
              color: visuals.primary.withValues(alpha: isDarkTheme ? 0.18 : 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ThemePlaceholder(type: type, size: 58, iconSize: 28, radius: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_localizedThemeName(context, type), style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        type.isRewardTheme ? context.l10n.watchAdToUnlock : context.l10n.active,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              height: 112,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color?.withValues(alpha: isDarkTheme ? 0.84 : 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDarkTheme ? Colors.white.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.55)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: visuals.gradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(visuals.icon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 11,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 180,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ],
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
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.type,
    required this.selected,
    required this.locked,
    required this.onPreview,
    required this.onApply,
    this.loading = false,
  });

  final AppThemeType type;
  final bool selected;
  final bool locked;
  final bool loading;
  final VoidCallback onPreview;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final visuals = ThemeVisuals.of(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onPreview,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            ThemePlaceholder(type: type, size: 48, iconSize: 22, radius: 16),
            if (locked)
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.72),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.lock_rounded, color: Colors.white, size: 13),
                ),
              ),
          ],
        ),
        title: Text(_localizedThemeName(context, type), style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(locked ? context.l10n.watchAdToUnlock : selected ? context.l10n.active : context.l10n.tapToPreview),
        trailing: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: visuals.primary),
          onPressed: loading ? null : onApply,
          child: Text(locked ? context.l10n.unlock : selected ? context.l10n.active : context.l10n.apply),
        ),
        tileColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _UnlockStatusCard extends StatelessWidget {
  const _UnlockStatusCard({required this.isUnlocked, required this.remainingText, required this.loading, required this.onExtend});

  final bool isUnlocked;
  final String remainingText;
  final bool loading;
  final VoidCallback onExtend;

  @override
  Widget build(BuildContext context) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isUnlocked ? Icons.verified_rounded : Icons.lock_clock_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isUnlocked ? (isTr ? 'Ödüllü temalar aktif' : 'Reward themes active') : (isTr ? 'Ödüllü temalar kilitli' : 'Reward themes locked'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isUnlocked
                ? (isTr ? 'Kalan süre: $remainingText' : 'Time left: $remainingText')
                : (isTr ? 'Reklam izleyerek 3 gün açabilirsin.' : 'Watch an ad to unlock for 3 days.'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : onExtend,
              icon: loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_alarm_rounded),
              label: Text(isTr ? '+1 Gün Ekle' : 'Add +1 Day'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900));
  }
}

String _localizedThemeName(BuildContext context, AppThemeType type) {
  if (type != AppThemeType.light && type != AppThemeType.dark) return type.label;

  final language = Localizations.localeOf(context).languageCode;
  final names = _freeThemeNames[language] ?? _freeThemeNames['en']!;
  return names[type] ?? type.label;
}

const Map<String, Map<AppThemeType, String>> _freeThemeNames = {
  'en': {AppThemeType.light: 'Light', AppThemeType.dark: 'Dark'},
  'tr': {AppThemeType.light: 'Açık', AppThemeType.dark: 'Koyu'},
  'es': {AppThemeType.light: 'Claro', AppThemeType.dark: 'Oscuro'},
  'pt': {AppThemeType.light: 'Claro', AppThemeType.dark: 'Escuro'},
  'de': {AppThemeType.light: 'Hell', AppThemeType.dark: 'Dunkel'},
  'fr': {AppThemeType.light: 'Clair', AppThemeType.dark: 'Sombre'},
  'it': {AppThemeType.light: 'Chiaro', AppThemeType.dark: 'Scuro'},
  'hi': {AppThemeType.light: 'हल्का', AppThemeType.dark: 'गहरा'},
  'ja': {AppThemeType.light: 'ライト', AppThemeType.dark: 'ダーク'},
  'zh': {AppThemeType.light: '浅色', AppThemeType.dark: '深色'},
};
