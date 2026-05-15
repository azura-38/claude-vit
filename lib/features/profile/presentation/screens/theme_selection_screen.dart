import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/vita_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_unlock_provider.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class ThemeSelectionScreen extends ConsumerStatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ConsumerState<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends ConsumerState<ThemeSelectionScreen> {
  AppThemeType? _previewTheme;
  bool _loadingAd = false;

  Future<void> _apply(AppThemeType type) async {
    final unlock = ref.read(themeUnlockProvider.notifier);
    final isLocked = type.isRewardTheme && !unlock.isUnlocked;

    if (isLocked) {
      await _unlockWithAd(type);
      return;
    }

    await ref.read(themeTypeProvider.notifier).setTheme(type);
    if (!mounted) return;
    context.pop();
  }

  Future<void> _unlockWithAd(AppThemeType type) async {
    if (_loadingAd) return;
    setState(() => _loadingAd = true);

    final ok = await ref.read(themeUnlockProvider.notifier).watchAdToUnlockOrExtend();

    if (!mounted) return;
    setState(() => _loadingAd = false);

    final strings = VitaStrings.of(context);
    if (ok) {
      await ref.read(themeTypeProvider.notifier).setTheme(type);
      if (!mounted) return;
      _showMessage(strings.themeUnlocked);
      context.pop();
    } else {
      _showMessage(strings.adUnavailableTryLater);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = VitaStrings.of(context);
    final currentTheme = ref.watch(themeTypeProvider);
    final unlockUntil = ref.watch(themeUnlockProvider);
    final unlockNotifier = ref.read(themeUnlockProvider.notifier);
    final activePreview = _previewTheme ?? currentTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(context.tr('theme_selection_title')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          _ThemePreview(type: activePreview),
          const SizedBox(height: 20),
          if (unlockUntil != null) _UnlockStatusCard(days: unlockNotifier.remainingDays),
          if (unlockUntil != null) const SizedBox(height: 20),
          _SectionTitle(title: strings.freeThemes),
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
          _SectionTitle(title: strings.rewardThemes),
          const SizedBox(height: 8),
          Text(
            strings.rewardThemesInfo,
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
      floatingActionButton: unlockNotifier.isUnlocked
          ? FloatingActionButton.extended(
              heroTag: 'themeExtendFab',
              onPressed: _loadingAd
                  ? null
                  : () async {
                      setState(() => _loadingAd = true);
                      final ok = await ref.read(themeUnlockProvider.notifier).watchAdToUnlockOrExtend();
                      if (!mounted) return;
                      setState(() => _loadingAd = false);
                      _showMessage(ok ? strings.oneDayAdded : strings.adUnavailable);
                    },
              icon: _loadingAd
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_circle_outline_rounded),
              label: Text(strings.addOneDay),
            )
          : null,
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.type});

  final AppThemeType type;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getThemeByType(type);
    return Theme(
      data: theme,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_localizedThemeName(context, type), style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              height: 86,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: theme.colorScheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 140, height: 10, color: theme.colorScheme.primary),
                        const SizedBox(height: 10),
                        Container(
                          width: 210,
                          height: 8,
                          color: theme.colorScheme.primary.withValues(alpha: 0.18),
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
    final strings = VitaStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.getThemeByType(type).colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onPreview,
        leading: CircleAvatar(
          backgroundColor: primary,
          child: locked ? const Icon(Icons.lock_rounded, color: Colors.white, size: 18) : null,
        ),
        title: Text(_localizedThemeName(context, type), style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(locked ? strings.watchAdToUnlock : selected ? strings.active : strings.tapToPreview),
        trailing: FilledButton(
          onPressed: loading ? null : onApply,
          child: Text(locked ? strings.unlock : selected ? strings.active : strings.apply),
        ),
        tileColor: isDark ? AppColors.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class _UnlockStatusCard extends StatelessWidget {
  const _UnlockStatusCard({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final strings = VitaStrings.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.medicalBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.medicalBlue),
          const SizedBox(width: 12),
          Expanded(child: Text(strings.rewardThemesActive(days))),
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
  final language = Localizations.localeOf(context).languageCode;
  final names = _themeNames[language] ?? _themeNames['en']!;
  return names[type] ?? type.label;
}

const Map<String, Map<AppThemeType, String>> _themeNames = {
  'en': {
    AppThemeType.light: 'Light',
    AppThemeType.dark: 'Dark',
    AppThemeType.lavender: 'Lavender',
    AppThemeType.ocean: 'Ocean',
    AppThemeType.mint: 'Mint',
    AppThemeType.peach: 'Peach',
    AppThemeType.rose: 'Rose',
    AppThemeType.slate: 'Slate',
    AppThemeType.sand: 'Sand',
    AppThemeType.forest: 'Forest',
  },
  'tr': {
    AppThemeType.light: 'Açık',
    AppThemeType.dark: 'Koyu',
    AppThemeType.lavender: 'Lavanta',
    AppThemeType.ocean: 'Okyanus',
    AppThemeType.mint: 'Nane',
    AppThemeType.peach: 'Şeftali',
    AppThemeType.rose: 'Gül',
    AppThemeType.slate: 'Arduvaz',
    AppThemeType.sand: 'Kum',
    AppThemeType.forest: 'Orman',
  },
  'es': {
    AppThemeType.light: 'Claro',
    AppThemeType.dark: 'Oscuro',
    AppThemeType.lavender: 'Lavanda',
    AppThemeType.ocean: 'Océano',
    AppThemeType.mint: 'Menta',
    AppThemeType.peach: 'Melocotón',
    AppThemeType.rose: 'Rosa',
    AppThemeType.slate: 'Pizarra',
    AppThemeType.sand: 'Arena',
    AppThemeType.forest: 'Bosque',
  },
  'pt': {
    AppThemeType.light: 'Claro',
    AppThemeType.dark: 'Escuro',
    AppThemeType.lavender: 'Lavanda',
    AppThemeType.ocean: 'Oceano',
    AppThemeType.mint: 'Menta',
    AppThemeType.peach: 'Pêssego',
    AppThemeType.rose: 'Rosa',
    AppThemeType.slate: 'Ardósia',
    AppThemeType.sand: 'Areia',
    AppThemeType.forest: 'Floresta',
  },
  'de': {
    AppThemeType.light: 'Hell',
    AppThemeType.dark: 'Dunkel',
    AppThemeType.lavender: 'Lavendel',
    AppThemeType.ocean: 'Ozean',
    AppThemeType.mint: 'Minze',
    AppThemeType.peach: 'Pfirsich',
    AppThemeType.rose: 'Rose',
    AppThemeType.slate: 'Schiefer',
    AppThemeType.sand: 'Sand',
    AppThemeType.forest: 'Wald',
  },
  'fr': {
    AppThemeType.light: 'Clair',
    AppThemeType.dark: 'Sombre',
    AppThemeType.lavender: 'Lavande',
    AppThemeType.ocean: 'Océan',
    AppThemeType.mint: 'Menthe',
    AppThemeType.peach: 'Pêche',
    AppThemeType.rose: 'Rose',
    AppThemeType.slate: 'Ardoise',
    AppThemeType.sand: 'Sable',
    AppThemeType.forest: 'Forêt',
  },
  'it': {
    AppThemeType.light: 'Chiaro',
    AppThemeType.dark: 'Scuro',
    AppThemeType.lavender: 'Lavanda',
    AppThemeType.ocean: 'Oceano',
    AppThemeType.mint: 'Menta',
    AppThemeType.peach: 'Pesca',
    AppThemeType.rose: 'Rosa',
    AppThemeType.slate: 'Ardesia',
    AppThemeType.sand: 'Sabbia',
    AppThemeType.forest: 'Foresta',
  },
  'hi': {
    AppThemeType.light: 'हल्का',
    AppThemeType.dark: 'गहरा',
    AppThemeType.lavender: 'लैवेंडर',
    AppThemeType.ocean: 'ओशन',
    AppThemeType.mint: 'मिंट',
    AppThemeType.peach: 'पीच',
    AppThemeType.rose: 'रोज़',
    AppThemeType.slate: 'स्लेट',
    AppThemeType.sand: 'सैंड',
    AppThemeType.forest: 'फॉरेस्ट',
  },
  'ja': {
    AppThemeType.light: 'ライト',
    AppThemeType.dark: 'ダーク',
    AppThemeType.lavender: 'ラベンダー',
    AppThemeType.ocean: 'オーシャン',
    AppThemeType.mint: 'ミント',
    AppThemeType.peach: 'ピーチ',
    AppThemeType.rose: 'ローズ',
    AppThemeType.slate: 'スレート',
    AppThemeType.sand: 'サンド',
    AppThemeType.forest: 'フォレスト',
  },
  'zh': {
    AppThemeType.light: '浅色',
    AppThemeType.dark: '深色',
    AppThemeType.lavender: '薰衣草',
    AppThemeType.ocean: '海洋',
    AppThemeType.mint: '薄荷',
    AppThemeType.peach: '蜜桃',
    AppThemeType.rose: '玫瑰',
    AppThemeType.slate: '岩板',
    AppThemeType.sand: '沙色',
    AppThemeType.forest: '森林',
  },
};
