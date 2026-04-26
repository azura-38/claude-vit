import '../entities/appointment.dart';
import '../enums/appointment_status.dart';

abstract class AppointmentRepository {
  Future<void> save(Appointment appointment);
  Future<void> update(Appointment appointment);
  Future<Appointment?> getById(String id);
  Future<List<Appointment>> getAll();
  Future<void> delete(String id);
  Future<void> updateStatus(String id, AppointmentStatus status);
  Future<Appointment?> getNextUpcoming();
}
