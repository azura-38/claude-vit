import 'package:sembast/sembast.dart';
import 'package:vitacase/shared/domain/entities/reminder.dart';
import 'package:vitacase/shared/domain/repositories/reminder_repository.dart';
import '../datasources/sembast_database.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final _store = stringMapStoreFactory.store('reminders');

  Future<Database> get _db async => SembastDatabase().db;

  @override
  Future<void> add(Reminder reminder) async {
    final db = await _db;
    final model = ReminderModel.fromEntity(reminder);
    await _store.record(reminder.id).put(db, model.toMap());
  }

  @override
  Future<List<Reminder>> getAll() async {
    final db = await _db;
    final records = await _store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('time', true)]),
    );
    return records
        .map((r) => ReminderModel.fromMap(r.value).toEntity())
        .toList();
  }

  @override
  Future<List<Reminder>> getPending() async {
    final db = await _db;
    final records = await _store.find(
      db,
      finder: Finder(
        filter: Filter.equals('isActive', true),
        sortOrders: [SortOrder('time', true)],
      ),
    );
    return records
        .map((r) => ReminderModel.fromMap(r.value).toEntity())
        .toList();
  }

  @override
  Future<void> markSent(String id) async {
    final db = await _db;
    final record = await _store.record(id).get(db);
    if (record != null) {
      final map = Map<String, dynamic>.from(record);
      map['isActive'] = false;
      await _store.record(id).put(db, map);
    }
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await _store.record(id).delete(db);
  }
}
