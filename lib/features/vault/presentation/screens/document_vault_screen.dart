import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/vault_controller.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/constants/app_routes.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../widgets/vault_swipe_card.dart';
import '../widgets/secure_banner.dart';
import 'document_quick_view_screen.dart';

class DocumentVaultScreen extends ConsumerWidget {
  const DocumentVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(vaultControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.documentAdd),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
        backgroundColor: AppColors.medicalBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.cardBorderLight,
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/vitacase_brand_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    context.l10n.docsTitle,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => context.push(AppRoutes.documentAdd),
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Add document',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.docsInfoSecure,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white60 : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            const SecureBanner(),
            const SizedBox(height: 24),
            documentsAsync.when(
              data: (documents) => documents.isEmpty
                  ? _EmptyVaultState(
                      isDark: isDark,
                      onAdd: () => context.push(AppRoutes.documentAdd),
                    )
                  : Column(
                      children: documents
                          .map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: VaultSwipeCard(
                                document: doc,
                                onDelete: () => ref
                                    .read(vaultControllerProvider.notifier)
                                    .deleteDocument(doc.id),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DocumentQuickViewScreen(document: doc),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyVaultState extends StatelessWidget {
  const _EmptyVaultState({required this.isDark, required this.onAdd});

  final bool isDark;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.medicalBlue.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.folder_copy_rounded,
              color: AppColors.medicalBlue,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your secure vault is empty',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Add prescriptions, reports, invoices or health documents. Files are encrypted and stored locally on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white60 : AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add first document'),
            ),
          ),
        ],
      ),
    );
  }
}
