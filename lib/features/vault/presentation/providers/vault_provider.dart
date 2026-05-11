import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/vault_document.dart';

final vaultProvider = Provider<List<VaultDocument>>((ref) {
  return [
    VaultDocument(
      id: "1",
      title: "Blood Test Results - Q3",
      hospital: "City General Hospital",
      category: "Lab Report",
      physician: "Dr. Sarah Jenkins",
      patient: "Alex Smith",
      notes:
          "Cholesterol levels are slightly elevated. Follow-up appointment required in 3 months.",
      date: DateTime(2026, 10, 12),
    ),

    VaultDocument(
      id: "2",
      title: "MRI Scan Referral",
      hospital: "Neurology Center",
      category: "Referral",
      physician: "Dr. Alan Turing",
      patient: "Alex Smith",
      notes: "MRI scan requested for further neurological analysis.",
      pending: true,
      date: DateTime(2026, 9, 28),
    ),

    VaultDocument(
      id: "3",
      title: "Vaccination Record",
      hospital: "City Health Clinic",
      category: "Immunization",
      physician: "Dr. Sarah",
      patient: "Alex Smith",
      notes: "COVID-19 booster completed.",
      date: DateTime(2026, 8, 15),
    ),
  ];
});
