import '../entities/medical_record.dart';

abstract class MedicalRecordRepository {
  Future<void> save(MedicalRecord record);
  Future<MedicalRecord?> getById(String id);
  Future<List<MedicalRecord>> getAll();
  Future<void> delete(String id);
}
