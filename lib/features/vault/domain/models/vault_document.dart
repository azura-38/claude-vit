class VaultDocument {
  final String id;
  final String title;
  final String hospital;
  final String category;
  final String physician;
  final String patient;
  final String notes;
  final DateTime date;
  final bool pending;

  // Added from Add Document Code Pack
  final String? fileName;
  final String? type;

  const VaultDocument({
    required this.id,
    required this.title,
    required this.hospital,
    required this.category,
    required this.physician,
    required this.patient,
    required this.notes,
    required this.date,
    this.pending = false,
    this.fileName,
    this.type,
  });
}
