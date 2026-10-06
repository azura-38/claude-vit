import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/legal_version.dart';
import '../../../../shared/data/services/analytics_service.dart';
import '../../../profile/presentation/providers/legacy_providers.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

/// One-time consent screen shown to existing users when legal documents
/// have been updated (i.e., their stored legal version is outdated).
///
/// New users never see this screen — they go through [ProfileCreateScreen].
class LegalUpdateScreen extends ConsumerStatefulWidget {
  const LegalUpdateScreen({super.key});

  @override
  ConsumerState<LegalUpdateScreen> createState() => _LegalUpdateScreenState();
}

class _LegalUpdateScreenState extends ConsumerState<LegalUpdateScreen> {
  bool _accepted = false;
  bool _isLoading = false;

  Future<void> _onAccept() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(legalAcceptedProvider.notifier).accept();
      await AnalyticsService.log(AnalyticsService.legalUpdateAccepted, {
        'version': LegalVersion.current,
      });

      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (e) {
      debugPrint('[LegalUpdateScreen] Error accepting legal update: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(context.tr('app_name')),
          centerTitle: true,
        ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.brandBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.policy_rounded,
                size: 40,
                color: AppColors.brandBlue,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              context.tr('legal_update_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              context.tr('legal_update_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Review prompt
            Text(
              context.tr('legal_update_review_prompt'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Unified Document link
            _DocumentLink(
              icon: Icons.policy_rounded,
              label: context.tr('terms_and_privacy'),
              routeName: 'settingsTermsAndPrivacy',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Acceptance checkbox
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ??
                    Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _accepted
                      ? AppColors.brandBlue
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: CheckboxListTile(
                value: _accepted,
                onChanged: (value) {
                  setState(() => _accepted = value ?? false);
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  context.tr('legal_update_accept_checkbox'),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Version label
            Text(
              '${context.tr('legal_version_label')}: ${LegalVersion.current}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _accepted && !_isLoading ? _onAccept : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      context.tr('legal_update_continue'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _DocumentLink extends StatelessWidget {
  const _DocumentLink({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.pushNamed(routeName),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.brandBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
