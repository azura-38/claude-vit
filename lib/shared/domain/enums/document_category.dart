enum DocumentCategory {
  documents,
  healthPrescriptions,
  healthReports,
  healthTestResults,
  healthImages,
  identity,
  finance,
  legal,
  notes,
  other,
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
  String get label {
    switch (this) {
      case DocumentCategory.documents:
        return 'Documents';
      case DocumentCategory.healthPrescriptions:
        return 'Prescriptions';
      case DocumentCategory.healthReports:
        return 'Health Reports';
      case DocumentCategory.healthTestResults:
        return 'Test Results';
      case DocumentCategory.healthImages:
        return 'Health Images';
      case DocumentCategory.identity:
        return 'Identity';
      case DocumentCategory.finance:
        return 'Finance';
      case DocumentCategory.legal:
        return 'Legal';
      case DocumentCategory.notes:
        return 'Notes';
      case DocumentCategory.other:
        return 'Other';
    }
  }
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
    case DocumentCategory.documents:
      return const [
        DocumentSubcategory.general,
        DocumentSubcategory.invoice,
        DocumentSubcategory.receipt,
        DocumentSubcategory.contract,
        DocumentSubcategory.certificate,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.healthPrescriptions:
      return const [
        DocumentSubcategory.prescription,
        DocumentSubcategory.insurance,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.healthReports:
      return const [
        DocumentSubcategory.report,
        DocumentSubcategory.insurance,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.healthTestResults:
      return const [
        DocumentSubcategory.labResult,
        DocumentSubcategory.report,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.healthImages:
      return const [
        DocumentSubcategory.image,
        DocumentSubcategory.report,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.identity:
      return const [
        DocumentSubcategory.general,
        DocumentSubcategory.certificate,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.finance:
      return const [
        DocumentSubcategory.invoice,
        DocumentSubcategory.receipt,
        DocumentSubcategory.bankStatement,
        DocumentSubcategory.tax,
        DocumentSubcategory.insurance,
        DocumentSubcategory.other,
      ];
    case DocumentCategory.legal:
      return const [
        DocumentSubcategory.contract,
        DocumentSubcategory.certificate,
        DocumentSubcategory.general,
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
