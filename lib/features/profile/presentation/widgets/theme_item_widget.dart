import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/theme_unlock_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/data/services/ad_service.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class ThemeItemWidget extends ConsumerWidget {
  final AppThemeType type;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onSelected;
  final Function(AppThemeType) onPreview;

  const ThemeItemWidget({
    super.key,
    required this.type,
    required this.imageUrl,
    required this.isSelected,
    required this.onSelected,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeUnlockProvider);
    final notifier = ref.read(themeUnlockProvider.notifier);

    final unlocked = state.isUnlocked(type);
    final days = state.remainingDays(type);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = type.localizedLabel(context);

    return GestureDetector(
      onTap: () {
        if (unlocked) {
          onSelected();
        } else {
          _showDialog(context, notifier, name);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Row(
            children: [
              // Image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child:
                    !unlocked
                        ? Container(
                          color: Colors.black45,
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    if (unlocked)
                      Text(
                        context.l10n.remainingDays(days),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        context.l10n.watchToUnlock,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              // Buttons
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child:
                    unlocked
                        ? TextButton(
                          onPressed: () async {
                            final ok = await AdService.showRewardedAd();
                            if (ok) {
                              notifier.extend(type, days: 1);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.l10n.add1DaySuccess),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(context.l10n.plus1Day),
                        )
                        : TextButton(
                          onPressed: () => _showDialog(context, notifier, name),
                          child: Text(context.l10n.watch),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(
    BuildContext context,
    ThemeUnlockNotifier notifier,
    String name,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color:
                  Theme.of(ctx).brightness == Brightness.dark
                      ? const Color(0xFF0F172A)
                      : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.unlockThemeQuestion,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final ok = await AdService.showRewardedAd();
                    if (ok) {
                      notifier.unlock(type, days: 5);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(context.l10n.watchAdPlus5),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onPreview(type);
                  },
                  child: Text(
                    context.l10n.preview5S,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
