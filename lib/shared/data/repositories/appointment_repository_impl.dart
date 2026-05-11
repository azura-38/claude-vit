import 'package:sembast/sembast.dart';
import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';
import 'package:vitacase/shared/domain/repositories/appointment_repository.dart';
import '../datasources/sembast_database.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final _store = stringMapStoreFactory.store('appointments');

  Future<Database> get _db async => SembastDatabase().db;

  @override
  Future<void> save(Appointment appointment) async {
    final db = await _db;
    final model = AppointmentModel.fromEntity(appointment);
    await _store.record(appointment.id).put(db, model.toMap());
  }

  @override
  Future<void> update(Appointment appointment) async {
    final db = await _db;
    final model = AppointmentModel.fromEntity(appointment);
    await _store.record(appointment.id).put(db, model.toMap());
  }

  @override
  Future<Appointment?> getById(String id) async {
    final db = await _db;
    final record = await _store.record(id).get(db);
    if (record == null) return null;
    return AppointmentModel.fromMap(record).toEntity();
  }

  @override
  Future<List<Appointment>> getAll() async {
    final db = await _db;
    final records = await _store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('date', true)]),
    );
    return records
        .map((r) => AppointmentModel.fromMap(r.value).toEntity())
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await _store.record(id).delete(db);
  }

  @override
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    final db = await _db;
    final record = await _store.record(id).get(db);
    if (record != null) {
      final map = Map<String, dynamic>.from(record);
      map['status'] = status.name;
      await _store.record(id).put(db, map);
    }
  }

  @override
  Future<Appointment?> getNextUpcoming() async {
    final db = await _db;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final records = await _store.find(
      db,
      finder: Finder(
        filter: Filter.and([
          Filter.greaterThanOrEquals('date', todayStr),
          Filter.equals('status', AppointmentStatus.upcoming.name),
        ]),
      ),
    );

    if (records.isEmpty) return null;

    var apts = records.map((r) => AppointmentModel.fromMap(r.value)).toList();
    apts.sort((a, b) {
      int c = a.date.compareTo(b.date);
      if (c == 0) return a.time.compareTo(b.time);
      return c;
    });

    return apts.first.toEntity();
  }
}
