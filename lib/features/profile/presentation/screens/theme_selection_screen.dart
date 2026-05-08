import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/data/services/ad_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/theme_item_widget.dart';

class ThemeSelectionScreen extends ConsumerStatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  ConsumerState<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends ConsumerState<ThemeSelectionScreen> {
  AppThemeType? _pendingSelection;

  @override
  void initState() {
    super.initState();
    AdService().loadRewarded();
  }

  void _previewTheme(AppThemeType type) {
    setState(() => _pendingSelection = type);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeTypeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTheme = _pendingSelection ?? currentTheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7F9FC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.blue),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                activeTheme.localizedLabel(context),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              background: _buildThemePreview(activeTheme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n('standard_modes'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStandardCard(context, AppThemeType.light, activeTheme, isDark)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStandardCard(context, AppThemeType.dark, activeTheme, isDark)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n('premium_palettes'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          context.l10n('premium_soon'),
                          style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ThemeItemWidget(
                    type: AppThemeType.purple,
                    imageUrl: 'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=600&auto=format&fit=crop',
                    isSelected: activeTheme == AppThemeType.purple,
                    onSelected: () => setState(() => _pendingSelection = AppThemeType.purple),
                    onPreview: _previewTheme,
                  ),
                  ThemeItemWidget(
                    type: AppThemeType.nature,
                    imageUrl: 'https://images.unsplash.com/photo-1542273917363-3b1817f69a2d?q=80&w=600&auto=format&fit=crop',
                    isSelected: activeTheme == AppThemeType.nature,
                    onSelected: () => setState(() => _pendingSelection = AppThemeType.nature),
                    onPreview: _previewTheme,
                  ),
                  ThemeItemWidget(
                    type: AppThemeType.ocean,
                    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600&auto=format&fit=crop',
                    isSelected: activeTheme == AppThemeType.ocean,
                    onSelected: () => setState(() => _pendingSelection = AppThemeType.ocean),
                    onPreview: _previewTheme,
                  ),
                  ThemeItemWidget(
                    type: AppThemeType.amber,
                    imageUrl: 'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?q=80&w=600&auto=format&fit=crop',
                    isSelected: activeTheme == AppThemeType.amber,
                    onSelected: () => setState(() => _pendingSelection = AppThemeType.amber),
                    onPreview: _previewTheme,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _pendingSelection != null && _pendingSelection != currentTheme
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              child: FloatingActionButton.extended(
                onPressed: _applyTheme,
                backgroundColor: AppColors.primaryIndigo,
                label: Text(context.l10n('apply_theme'), style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ).animate().slideY(begin: 1, end: 0)
          : null,
    );
  }

  Widget _buildThemePreview(AppThemeType type) {
    final theme = AppTheme.getThemeByType(type);
    return Theme(
      data: theme,
      child: Container(
        padding: const EdgeInsets.fromLTRB(40, 60, 40, 20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerTheme.color ?? Colors.transparent),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(6)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 180,
                    height: 8,
                    decoration: BoxDecoration(color: theme.disabledColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(backgroundColor: theme.colorScheme.primary, radius: 24),
                const SizedBox(width: 16),
                CircleAvatar(backgroundColor: theme.colorScheme.secondary, radius: 24),
                const SizedBox(width: 16),
                CircleAvatar(backgroundColor: theme.colorScheme.tertiary, radius: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardCard(BuildContext context, AppThemeType type, AppThemeType active, bool isDark) {
    final isSelected = active == type;
    final isTypeDark = type == AppThemeType.dark;

    return GestureDetector(
      onTap: () => setState(() => _pendingSelection = type),
      child: AnimatedContainer(
        duration: 300.ms,
        height: 110,
        decoration: BoxDecoration(
          color: isTypeDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTypeDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isTypeDark ? Colors.indigoAccent : Colors.amber,
                ),
                const SizedBox(height: 8),
                Text(
                  type.localizedLabel(context).split(' ')[0], // 'Luxe' or 'Midnight'
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 14,
                    color: isTypeDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Positioned(top: 8, right: 8, child: Icon(Icons.check_circle_rounded, color: Colors.blue, size: 18)),
          ],
        ),
      ),
    );
  }

  bool isLocked(bool unlocked) => !unlocked;

  void _applyTheme() {
    if (_pendingSelection != null) {
      ref.read(themeTypeProvider.notifier).setTheme(_pendingSelection!);
      context.pop();
    }
  }
}
