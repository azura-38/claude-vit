import 'package:flutter/material.dart';

import '../../domain/models/vault_document.dart';
import '../../../../core/theme/vitacase_theme.dart';
import '../widgets/vault_action_button.dart';
import '../widgets/vault_preview_overlay.dart';
import '../widgets/vault_tag_chip.dart';
import 'package:go_router/go_router.dart';

class DocumentQuickViewScreen
    extends StatelessWidget {
  final VaultDocument document;

  const DocumentQuickViewScreen({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const Expanded(
                  child: Text(
                    "Document Vault",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Text(
              "Reviewing expanded document details.",
              style: TextStyle(
                fontSize: 17,
                color:
                    VitaColors.secondary,
              ),
            ),

            const SizedBox(height: 28),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  28,
                ),
                border: Border.all(
                  color:
                      VitaColors.border,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Container(
                          width: 70,
                          height: 90,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFF1F4FA,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              const Text(
                                "OCT",
                              ),
                              Text(
                                document
                                    .date.day
                                    .toString(),
                                style:
                                    const TextStyle(
                                  fontSize:
                                      36,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      VitaColors.primary,
                                ),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 18,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                document
                                    .title,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      26,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      8),

                              Text(
                                "${document.hospital} • ${document.category}",
                                style:
                                    const TextStyle(
                                  color:
                                      VitaColors.secondary,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      12),

                              Row(
                                children: [
                                  VaultTagChip(
                                    label:
                                        "Lab",
                                    bg: VitaColors
                                        .chipBlue,
                                    text: VitaColors
                                        .primary,
                                  ),

                                  const SizedBox(
                                      width:
                                          8),

                                  VaultTagChip(
                                    label:
                                        "PDF",
                                    bg: const Color(
                                      0xFFF1F4FA,
                                    ),
                                    text:
                                        VitaColors.secondary,
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  Container(
                    width:
                        double.infinity,
                    color: const Color(
                      0xFFF9FBFF,
                    ),
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child:
                                  _InfoColumn(
                                label:
                                    "PATIENT",
                                value:
                                    document
                                        .patient,
                              ),
                            ),
                            Expanded(
                              child:
                                  _InfoColumn(
                                label:
                                    "PHYSICIAN",
                                value:
                                    document
                                        .physician,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                            height:
                                24),

                        _InfoColumn(
                          label: "NOTES",
                          value:
                              document
                                  .notes,
                          expanded:
                              true,
                        ),

                        const SizedBox(
                            height:
                                28),

                        const VaultPreviewOverlay(),

                        const SizedBox(
                            height:
                                24),

                        Row(
                          children: [
                            VaultActionButton(
                              label:
                                  "Share",
                              icon: Icons
                                  .share_outlined,
                              bg: const Color(
                                0xFFF1F4FA,
                              ),
                              text:
                                  VitaColors.secondary,
                              onTap:
                                  () {},
                            ),

                            const SizedBox(
                                width:
                                    16),

                            VaultActionButton(
                              label:
                                  "Download",
                              icon: Icons
                                  .download,
                              bg:
                                  VitaColors.primary,
                              text:
                                  Colors.white,
                              onTap:
                                  () {},
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _InfoColumn
    extends StatelessWidget {
  final String label;
  final String value;
  final bool expanded;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            color: VitaColors.secondary,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          width:
              expanded ? double.infinity : null,
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: expanded
                ? const Color(
                    0xFFF3F6FB,
                  )
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        )
      ],
    );
  }
}
