import '../entities/reminder.dart';

abstract class ReminderRepository {
  Future<void> add(Reminder reminder);
  Future<List<Reminder>> getAll();
  Future<List<Reminder>> getPending();
  Future<void> markSent(String id);
  Future<void> delete(String id);
}
