import '../../../features/medications/domain/entities/medicine.dart';

abstract class MedicineRepository {
  Future<void> save(Medicine medicine);
  Future<Medicine?> getById(String id);
  Future<List<Medicine>> getAll();
  Future<void> update(Medicine medicine);
  Future<void> delete(String id);
}
