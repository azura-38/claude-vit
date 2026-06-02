import 'package:flutter/material.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

/// Document tag matching the React DOCUMENT_TAGS constant.
enum DocumentTag {
  lab('lab', 'docs_tag_lab', '🧪'),
  radiology('radiology', 'docs_tag_radiology', '🩻'),
  prescription('prescription', 'docs_tag_prescription', '💊'),
  report('report', 'docs_tag_report', '📄'),
  operation('operation', 'docs_tag_operation', '🏥'),
  vaccination('vaccination', 'docs_tag_vaccination', '💉'),
  other('other', 'docs_tag_other', '📁');

  final String id;
  final String key;
  final String icon;

  const DocumentTag(this.id, this.key, this.icon);

  String get label => id; // Fallback for UI that calls .label

  String localizedLabel(BuildContext context) => context.tr(key);

  static DocumentTag? fromId(String? id) {
    if (id == null) return null;
    return DocumentTag.values.cast<DocumentTag?>().firstWhere(
      (e) => e!.id == id,
      orElse: () => null,
    );
  }
}
