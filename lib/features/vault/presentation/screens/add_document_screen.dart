import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/document_upload_provider.dart';
import '../../../../core/theme/vitacase_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/document_type_card.dart';
import '../widgets/secure_banner.dart';
import 'package:go_router/go_router.dart';

class AddDocumentScreen extends ConsumerWidget {
  const AddDocumentScreen({super.key});

  void _startUploadAnimation(WidgetRef ref) async {
    final notifier = ref.read(uploadStateProvider.notifier);
    
    notifier.state = UploadState.reading;
    await Future.delayed(const Duration(milliseconds: 1200));
    
    notifier.state = UploadState.compressing;
    await Future.delayed(const Duration(milliseconds: 1500));
    
    notifier.state = UploadState.encrypting;
    await Future.delayed(const Duration(milliseconds: 1800));
    
    notifier.state = UploadState.success;
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // reset or pop
    notifier.state = UploadState.idle;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(selectedCategoryProvider);
    final type = ref.watch(selectedTypeProvider);
    final uploadState = ref.watch(uploadStateProvider);

    final categories = [
      "Medical",
      "Insurance",
      "Finance",
      "Identity",
      "Legal",
      "Personal",
      "Other",
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Document",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SecureBanner(),
                  const SizedBox(height: 28),

                  const Text(
                    "Selected File",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  _buildSelectedFile(uploadState),

                  const SizedBox(height: 32),

                  const Text(
                    "Category",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CategoryChip(
                            active: category == cat,
                            label: cat,
                            onTap: () {
                              ref.read(selectedCategoryProvider.notifier).state = cat;
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    "Document Type",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: .95,
                    children: [
                      DocumentTypeCard(
                        active: type == "Tax Return",
                        label: "Tax Return",
                        icon: Icons.request_quote_outlined,
                        onTap: () => ref.read(selectedTypeProvider.notifier).state = "Tax Return",
                      ),
                      DocumentTypeCard(
                        active: type == "Insurance",
                        label: "Insurance",
                        icon: Icons.health_and_safety_outlined,
                        onTap: () => ref.read(selectedTypeProvider.notifier).state = "Insurance",
                      ),
                      DocumentTypeCard(
                        active: type == "Banking",
                        label: "Banking",
                        icon: Icons.account_balance_outlined,
                        onTap: () => ref.read(selectedTypeProvider.notifier).state = "Banking",
                      ),
                      DocumentTypeCard(
                        active: type == "Lab Report",
                        label: "Lab Report",
                        icon: Icons.science_outlined,
                        onTap: () => ref.read(selectedTypeProvider.notifier).state = "Lab Report",
                      ),
                      DocumentTypeCard(
                        active: type == "ID Card",
                        label: "ID Card",
                        icon: Icons.badge_outlined,
                        onTap: () => ref.read(selectedTypeProvider.notifier).state = "ID Card",
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    "Recent Uploads",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  
                  _buildRecentUploadItem("Blood Test Results.pdf", "Medical • Lab Report"),
                  const SizedBox(height: 10),
                  _buildRecentUploadItem("Car_Insurance_2024.pdf", "Insurance • Auto"),

                  const SizedBox(height: 32),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 18, color: VitaColors.secondary),
                      SizedBox(width: 8),
                      Text(
                        "Encrypted with AES-256",
                        style: TextStyle(color: VitaColors.secondary),
                      )
                    ],
                  ),

                  const SizedBox(height: 32),

                  _buildUploadButton(context, ref, uploadState),

                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile(UploadState state) {
    Widget content = Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: VitaColors.danger,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "tax_return_2023.pdf",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text("2.4 MB", style: TextStyle(color: VitaColors.secondary)),
            ],
          ),
        ),
        if (state == UploadState.idle)
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: VitaColors.primary),
          ),
      ],
    );

    if (state == UploadState.reading) {
      content = content.animate(onPlay: (controller) => controller.repeat()).shimmer(
        duration: 1200.ms,
        color: Colors.white54,
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: state == UploadState.success ? Colors.green : VitaColors.border,
        ),
      ),
      child: content,
    );
  }

  Widget _buildRecentUploadItem(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VitaColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: VitaColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: VitaColors.secondary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: VitaColors.secondary),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, WidgetRef ref, UploadState state) {
    bool isProcessing = state != UploadState.idle && state != UploadState.success;
    
    Color bgColor = VitaColors.primary;
    String label = "Save to Vault";
    Widget icon = const SizedBox.shrink();

    if (state == UploadState.reading) {
      label = "Reading File...";
      icon = const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2));
    } else if (state == UploadState.compressing) {
      label = "Compressing PDF...";
      icon = const Icon(Icons.compress, color: Colors.white).animate(onPlay: (controller) => controller.repeat()).scaleXY(begin: 1, end: 0.8, duration: 400.ms, curve: Curves.easeInOut);
    } else if (state == UploadState.encrypting) {
      label = "Encrypting Data...";
      icon = const Icon(Icons.lock_clock, color: Colors.white).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 500.ms);
    } else if (state == UploadState.success) {
      bgColor = Colors.green;
      label = "Secured & Saved";
      icon = const Icon(Icons.check_circle, color: Colors.white).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
    }

    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: isProcessing ? 0 : 2,
        ),
        onPressed: state == UploadState.idle ? () => _startUploadAnimation(ref) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state != UploadState.idle) ...[
              icon,
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
