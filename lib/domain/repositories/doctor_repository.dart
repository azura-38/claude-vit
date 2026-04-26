import '../entities/doctor.dart';

abstract class DoctorRepository {
  Future<void> save(Doctor doctor);
  Future<Doctor?> getById(String id);
  Future<List<Doctor>> getAll();
  Future<void> delete(String id);
  Future<List<Doctor>> search(String queryStr);
}
