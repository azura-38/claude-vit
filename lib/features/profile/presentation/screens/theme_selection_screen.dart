import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/theme_unlock_provider.dart';

class ThemeSelectionScreen extends ConsumerStatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ConsumerState<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends ConsumerState<ThemeSelectionScreen> {
  AppThemeType? _previewTheme;
  bool _loadingAd = false;

  bool _isRewardTheme(AppThemeType type) {
    return type == AppThemeType.purple ||
        type == AppThemeType.nature ||
        type == AppThemeType.ocean ||
        type == AppThemeType.amber;
  }

  Future<void> _apply(AppThemeType type) async {
    final unlock = ref.read(themeUnlockProvider.notifier);
    final isLocked = _isRewardTheme(type) && !unlock.isUnlocked;

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

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (ok) {
      await ref.read(themeTypeProvider.notifier).setTheme(type);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Theme unlocked. Each extra ad adds +1 day.')),
      );
      router.pop();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ad unavailable. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeTypeProvider);
    final unlockUntil = ref.watch(themeUnlockProvider);
    final unlockNotifier = ref.read(themeUnlockProvider.notifier);
    final activePreview = _previewTheme ?? currentTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Theme'),
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
          if (unlockUntil != null)
            _UnlockStatusCard(days: unlockNotifier.remainingDays),
          if (unlockUntil != null) const SizedBox(height: 20),
          _SectionTitle(title: 'Free themes'),
          const SizedBox(height: 12),
          _ThemeTile(
            type: AppThemeType.light,
            selected: currentTheme == AppThemeType.light,
            locked: false,
            onPreview: () => setState(() => _previewTheme = AppThemeType.light),
            onApply: () => _apply(AppThemeType.light),
          ),
          _ThemeTile(
            type: AppThemeType.dark,
            selected: currentTheme == AppThemeType.dark,
            locked: false,
            onPreview: () => setState(() => _previewTheme = AppThemeType.dark),
            onApply: () => _apply(AppThemeType.dark),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Reward themes'),
          const SizedBox(height: 8),
          Text(
            'Watch one rewarded ad to unlock these themes for 3 days. Every extra ad adds +1 day.',
            style: TextStyle(color: isDark ? Colors.white60 : AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          for (final type in const [
            AppThemeType.purple,
            AppThemeType.nature,
            AppThemeType.ocean,
            AppThemeType.amber,
          ])
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
              onPressed: _loadingAd
                  ? null
                  : () async {
                      setState(() => _loadingAd = true);
                      final ok = await ref.read(themeUnlockProvider.notifier).watchAdToUnlockOrExtend();
                      if (!mounted) return;
                      setState(() => _loadingAd = false);
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        SnackBar(content: Text(ok ? '+1 day added.' : 'Ad unavailable.')),
                      );
                    },
              icon: _loadingAd
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Add +1 day'),
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
            Text(type.label, style: theme.textTheme.titleLarge),
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
                        Container(width: 210, height: 8, color: theme.colorScheme.primary.withValues(alpha: 0.18)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onPreview,
        leading: CircleAvatar(
          backgroundColor: AppTheme.getThemeByType(type).colorScheme.primary,
          child: locked ? const Icon(Icons.lock_rounded, color: Colors.white, size: 18) : null,
        ),
        title: Text(type.label, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(locked ? 'Watch ad to unlock' : selected ? 'Active' : 'Tap to preview'),
        trailing: FilledButton(
          onPressed: loading ? null : onApply,
          child: Text(locked ? 'Unlock' : selected ? 'Active' : 'Apply'),
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
          Expanded(child: Text('Reward themes active for $days day(s).')),
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
