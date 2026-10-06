import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../profile/presentation/providers/legacy_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';

import '../widgets/dashboard_top_bar.dart';
import '../widgets/dashboard_banners.dart';
import '../widgets/dashboard_review_card.dart';
import '../widgets/dashboard_metrics_grid.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_appointments_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = ref.read(sharedPreferencesProvider);
      if (prefs.getBool('db_corruption_recovery_triggered') == true) {
        await prefs.remove('db_corruption_recovery_triggered');
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  Text(context.tr('db_recovery_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                context.tr('db_recovery_desc'),
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => dialogContext.pop(),
                  child: Text(context.l10n.ok, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      }
    });

    final userName = ref.watch(profileNameProvider);
    final isGuest = userName == null || userName.isEmpty;

    final hasPinAsync = ref.watch(hasPinProvider);
    final hasPin = hasPinAsync.valueOrNull ?? true;
    final prefs = ref.watch(sharedPreferencesProvider);
    final onboardingSkipped = prefs.getBool('profile_creation_skipped') ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            DashboardTopBar(userName: userName ?? context.l10n.guestUser),
            const SizedBox(height: 24),
            if (onboardingSkipped && !hasPin) ...[
              const SecuritySetupWarningBanner(),
              const SizedBox(height: 24),
            ],
            if (isGuest && !(onboardingSkipped && !hasPin)) ...[
              const GuestBanner(),
              const SizedBox(height: 24),
            ],
            const DashboardReviewCard(),
            const MetricsGrid(),
            const SizedBox(height: 32),
            const ConditionalQuickAccess(),
            const UpcomingAppointments(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
