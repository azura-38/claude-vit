import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/core/constants/legal_version.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

/// Identifies navigable sections inside the unified Terms & Privacy document.
enum LegalSectionType {
  terms,
  privacy,
  kvkk,
  disclaimer,
  dataDeletion,
}

/// Unified in-app legal experience consolidating Terms of Use,
/// Privacy Policy (GDPR), Türkiye KVKK Notice, Health Disclaimer,
/// and Data Retention & Deletion into a single navigable screen.
class TermsAndPrivacyScreen extends StatefulWidget {
  const TermsAndPrivacyScreen({
    super.key,
    this.initialSection,
  });

  final LegalSectionType? initialSection;

  @override
  State<TermsAndPrivacyScreen> createState() => _TermsAndPrivacyScreenState();
}

class _TermsAndPrivacyScreenState extends State<TermsAndPrivacyScreen> {
  final ScrollController _scrollController = ScrollController();
  late LegalSectionType _currentSection;
  String _markdownData = '';
  bool _isLoading = true;

  // Approximate relative scroll positions for quick section jumping
  static const Map<LegalSectionType, double> _sectionScrollFractions = {
    LegalSectionType.terms: 0.0,
    LegalSectionType.privacy: 0.23,
    LegalSectionType.kvkk: 0.50,
    LegalSectionType.disclaimer: 0.72,
    LegalSectionType.dataDeletion: 0.88,
  };

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection ?? LegalSectionType.terms;
    _loadDocument();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    try {
      final doc = await rootBundle.loadString('assets/legal/terms_and_privacy.md');
      if (mounted) {
        setState(() {
          _markdownData = doc;
          _isLoading = false;
        });

        // Jump to requested initial section after layout
        if (widget.initialSection != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToSection(widget.initialSection!);
          });
        }
      }
    } catch (e) {
      debugPrint('[TermsAndPrivacyScreen] Failed to load canonical document: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToSection(LegalSectionType section) {
    if (!_scrollController.hasClients) return;
    setState(() => _currentSection = section);

    final fraction = _sectionScrollFractions[section] ?? 0.0;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = (maxScroll * fraction).clamp(0.0, maxScroll);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  String _getSectionLabel(BuildContext context, LegalSectionType section) {
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    switch (section) {
      case LegalSectionType.terms:
        return isTr ? '1. Kullanım Koşulları' : '1. Terms of Use';
      case LegalSectionType.privacy:
        return isTr ? '2. Gizlilik & GDPR' : '2. Privacy & GDPR';
      case LegalSectionType.kvkk:
        return isTr ? '3. KVKK Aydınlatma' : '3. Türkiye KVKK';
      case LegalSectionType.disclaimer:
        return isTr ? '4. Yasal Uyarı' : '4. Disclaimer';
      case LegalSectionType.dataDeletion:
        return isTr ? '5. Veri Silme' : '5. Data Deletion';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTr = Localizations.localeOf(context).languageCode == 'tr';
    final pageTitle = context.tr('terms_and_privacy');

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick Navigation Chips / Anchors
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: LegalSectionType.values.map((section) {
                    final isSelected = _currentSection == section;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          _getSectionLabel(context, section),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : AppColors.textPrimary),
                          ),
                        ),
                        selectedColor: AppColors.brandBlue,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.grey.withValues(alpha: 0.1),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.brandBlue
                                : (isDark ? Colors.white12 : Colors.transparent),
                          ),
                        ),
                        onSelected: (_) => _scrollToSection(section),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Document Version Sub-Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${context.tr('legal_version_label')}: ${LegalVersion.current}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : Colors.grey[600],
                    ),
                  ),
                  Text(
                    isTr ? 'Birleşik Yasal Metin' : 'Consolidated Legal Master',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Markdown Viewer with scroll controller
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _markdownData.isEmpty
                      ? Center(
                          child: Text(
                            isTr ? 'Belge yüklenemedi' : 'Failed to load legal document',
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : Markdown(
                          controller: _scrollController,
                          data: _markdownData,
                          selectable: true,
                          onTapLink: (text, href, title) async {
                            if (href == null) return;
                            if (href.startsWith('#')) {
                              // In-document anchor link
                              if (href.contains('section-1')) {
                                _scrollToSection(LegalSectionType.terms);
                              } else if (href.contains('section-2')) {
                                _scrollToSection(LegalSectionType.privacy);
                              } else if (href.contains('section-3')) {
                                _scrollToSection(LegalSectionType.kvkk);
                              } else if (href.contains('section-4')) {
                                _scrollToSection(LegalSectionType.disclaimer);
                              } else if (href.contains('section-5')) {
                                _scrollToSection(LegalSectionType.dataDeletion);
                              }
                              return;
                            }
                            final uri = Uri.tryParse(href);
                            if (uri != null && await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            h1: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.brandBlue,
                            ),
                            h2: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppColors.brandBlue,
                            ),
                            h3: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                            ),
                            listBullet: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            horizontalRuleDecoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            a: const TextStyle(
                              color: AppColors.brandBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
