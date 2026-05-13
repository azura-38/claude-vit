import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/vault_controller.dart';
import 'package:vitacase/core/constants/app_colors.dart';
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.cardBorderLight,
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
                IconButton(
                  onPressed: () => context.push('/explore-placeholder'),
                  icon: const Icon(Icons.add_rounded),
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
              data:
                  (documents) =>
                      documents.isEmpty
                          ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(context.l10n.docsEmptySubtitle),
                            ),
                          )
                          : Column(
                            children:
                                documents
                                    .map(
                                      (doc) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 18,
                                        ),
                                        child: VaultSwipeCard(
                                          document: doc,
                                          onDelete:
                                              () => ref
                                                  .read(
                                                    vaultControllerProvider
                                                        .notifier,
                                                  )
                                                  .deleteDocument(doc.id),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) =>
                                                        DocumentQuickViewScreen(
                                                          document: doc,
                                                        ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (err, stack) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text("Error: $err")),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
