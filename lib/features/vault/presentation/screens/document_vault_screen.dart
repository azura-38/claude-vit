import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/vault_provider.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import '../widgets/vault_swipe_card.dart';
import 'document_quick_view_screen.dart';
import 'package:go_router/go_router.dart';

class DocumentVaultScreen extends ConsumerWidget {
  const DocumentVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(vaultProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const Expanded(
                  child: Text(
                    "Recent Documents",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Swipe items to manage your health records.",
              style: TextStyle(fontSize: 17, color: AppColors.secondary),
            ),

            const SizedBox(height: 28),

            ...documents.map(
              (doc) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: VaultSwipeCard(
                  document: doc,
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
            ),
          ],
        ),
      ),
    );
  }
}
