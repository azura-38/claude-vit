import 'package:flutter/material.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

enum DocumentCategory {
  prescription,
  bloodTest,
  medicalReport,
  appointment,
  insurance,
  vaccination,
  invoice,
  other,
  // Legacy enum constants kept for backward compatibility across existing widgets
  documents,
  healthPrescriptions,
  healthReports,
  healthTestResults,
  healthImages,
  identity,
  finance,
  legal,
  notes;

  static DocumentCategory parse(String? raw) {
    if (raw == null || raw.isEmpty) return DocumentCategory.other;
    final lower = raw.trim().toLowerCase();
    if (lower == 'prescription' || lower == 'healthprescriptions' || lower.contains('reçete')) return DocumentCategory.prescription;
    if (lower == 'bloodtest' || lower == 'healthtestresults' || lower.contains('tahlil') || lower.contains('blood')) return DocumentCategory.bloodTest;
    if (lower == 'medicalreport' || lower == 'healthreports' || lower.contains('rapor') || lower.contains('report')) return DocumentCategory.medicalReport;
    if (lower == 'appointment' || lower.contains('randevu')) return DocumentCategory.appointment;
    if (lower == 'insurance' || lower.contains('sigorta')) return DocumentCategory.insurance;
    if (lower == 'vaccination' || lower.contains('aşı') || lower.contains('vaccin')) return DocumentCategory.vaccination;
    if (lower == 'invoice' || lower == 'finance' || lower.contains('fatura')) return DocumentCategory.invoice;
    if (lower == 'documents') return DocumentCategory.documents;
    if (lower == 'identity') return DocumentCategory.identity;
    if (lower == 'legal') return DocumentCategory.legal;
    if (lower == 'notes') return DocumentCategory.notes;
    return DocumentCategory.other;
  }
}

enum DocumentSubcategory {
  general,
  invoice,
  receipt,
  report,
  prescription,
  labResult,
  image,
  insurance,
  bankStatement,
  tax,
  contract,
  certificate,
  personalNote,
  other,
}

enum DocumentFileType { pdf, image }

extension DocumentCategoryLabel on DocumentCategory {
  String localizedLabel(BuildContext context) {
    switch (this) {
      case DocumentCategory.prescription:
      case DocumentCategory.healthPrescriptions:
        return context.tr('category_prescription');
      case DocumentCategory.bloodTest:
      case DocumentCategory.healthTestResults:
        return context.tr('category_blood_test');
      case DocumentCategory.medicalReport:
      case DocumentCategory.healthReports:
        return context.tr('category_medical_report');
      case DocumentCategory.appointment:
        return context.tr('category_appointment');
      case DocumentCategory.insurance:
        return context.tr('category_insurance');
      case DocumentCategory.vaccination:
        return context.tr('category_vaccination');
      case DocumentCategory.invoice:
      case DocumentCategory.finance:
        return context.tr('category_invoice');
      case DocumentCategory.documents:
        return context.tr('docs_title');
      case DocumentCategory.identity:
        return context.tr('docs_category_identity');
      case DocumentCategory.legal:
        return context.tr('docs_category_legal');
      case DocumentCategory.notes:
        return context.tr('docs_category_notes');
      case DocumentCategory.healthImages:
        return context.tr('docs_category_images');
      case DocumentCategory.other:
        return context.tr('category_other');
    }
  }

  String get defaultLabel {
    switch (this) {
      case DocumentCategory.prescription:
      case DocumentCategory.healthPrescriptions:
        return 'Prescription';
      case DocumentCategory.bloodTest:
      case DocumentCategory.healthTestResults:
        return 'Blood Test';
      case DocumentCategory.medicalReport:
      case DocumentCategory.healthReports:
        return 'Medical Report';
      case DocumentCategory.appointment:
        return 'Appointment';
      case DocumentCategory.insurance:
        return 'Insurance';
      case DocumentCategory.vaccination:
        return 'Vaccination';
      case DocumentCategory.invoice:
      case DocumentCategory.finance:
        return 'Invoice';
      case DocumentCategory.documents:
        return 'Documents';
      case DocumentCategory.identity:
        return 'Identity';
      case DocumentCategory.legal:
        return 'Legal';
      case DocumentCategory.notes:
        return 'Notes';
      case DocumentCategory.healthImages:
        return 'Images';
      case DocumentCategory.other:
        return 'Other';
    }
  }

  String get label => defaultLabel;
}

extension DocumentSubcategoryLabel on DocumentSubcategory {
  String get label {
    switch (this) {
      case DocumentSubcategory.general:
        return 'General';
      case DocumentSubcategory.invoice:
        return 'Invoice';
      case DocumentSubcategory.receipt:
        return 'Receipt';
      case DocumentSubcategory.report:
        return 'Report';
      case DocumentSubcategory.prescription:
        return 'Prescription';
      case DocumentSubcategory.labResult:
        return 'Lab Result';
      case DocumentSubcategory.image:
        return 'Image';
      case DocumentSubcategory.insurance:
        return 'Insurance';
      case DocumentSubcategory.bankStatement:
        return 'Bank Statement';
      case DocumentSubcategory.tax:
        return 'Tax';
      case DocumentSubcategory.contract:
        return 'Contract';
      case DocumentSubcategory.certificate:
        return 'Certificate';
      case DocumentSubcategory.personalNote:
        return 'Personal Note';
      case DocumentSubcategory.other:
        return 'Other';
    }
  }
}

List<DocumentSubcategory> subcategoriesForDocumentCategory(
  DocumentCategory category,
) {
  switch (category) {
    case DocumentCategory.prescription:
    case DocumentCategory.healthPrescriptions:
      return const [
        DocumentSubcategory.prescription,
        DocumentSubcategory.insurance,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.bloodTest:
    case DocumentCategory.healthTestResults:
      return const [
        DocumentSubcategory.labResult,
        DocumentSubcategory.report,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.medicalReport:
    case DocumentCategory.healthReports:
      return const [
        DocumentSubcategory.report,
        DocumentSubcategory.insurance,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.appointment:
      return const [
        DocumentSubcategory.general,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.insurance:
      return const [
        DocumentSubcategory.insurance,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.vaccination:
      return const [
        DocumentSubcategory.certificate,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.invoice:
    case DocumentCategory.finance:
      return const [
        DocumentSubcategory.invoice,
        DocumentSubcategory.receipt,
        DocumentSubcategory.bankStatement,
        DocumentSubcategory.tax,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.healthImages:
      return const [
        DocumentSubcategory.image,
        DocumentSubcategory.report,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.documents:
    case DocumentCategory.identity:
    case DocumentCategory.legal:
      return const [
        DocumentSubcategory.general,
        DocumentSubcategory.contract,
        DocumentSubcategory.certificate,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.notes:
      return const [
        DocumentSubcategory.personalNote,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.other:
      return const [DocumentSubcategory.other];
  }
}
