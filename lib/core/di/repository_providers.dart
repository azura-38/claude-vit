import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repositories (Domain Interfaces)
import '../../domain/repositories/document_repository.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../../domain/repositories/health_repository.dart';
import '../../domain/repositories/medical_record_repository.dart';
import '../../domain/repositories/reminder_repository.dart';

// Implementations (Data Layer)
import '../../data/repositories/document_repository_impl.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../data/repositories/health_repository_impl.dart';
import '../../data/repositories/medical_record_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';

// 🧬 Dependency Inversion: This is the ONLY file that bridges Domain and Data.
// The rest of the app must only consume the domain interfaces.

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl();
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl();
});

final medicineRepositoryProvider = Provider<MedicineRepository>((ref) {
  return MedicineRepositoryImpl();
});

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepositoryImpl();
});

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepositoryImpl();
});

final medicalRecordRepositoryProvider = Provider<MedicalRecordRepository>((ref) {
  return MedicalRecordRepositoryImpl();
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl();
});
