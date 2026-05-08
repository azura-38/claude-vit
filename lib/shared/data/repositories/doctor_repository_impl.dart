import 'package:sembast/sembast.dart';
import 'package:vitacase/shared/domain/entities/doctor.dart';
import 'package:vitacase/shared/domain/repositories/doctor_repository.dart';
import '../datasources/sembast_database.dart';
import '../models/doctor_model.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final _store = stringMapStoreFactory.store('doctors');

  Future<Database> get _db async => SembastDatabase().db;

  @override
  Future<void> save(Doctor doctor) async {
    final db = await _db;
    final model = DoctorModel.fromEntity(doctor);
    await _store.record(doctor.id).put(db, model.toMap());
  }

  @override
  Future<Doctor?> getById(String id) async {
    final db = await _db;
    final record = await _store.record(id).get(db);
    if (record == null) return null;
    return DoctorModel.fromMap(record).toEntity();
  }

  @override
  Future<List<Doctor>> getAll() async {
    final db = await _db;
    final records = await _store.find(db, finder: Finder(sortOrders: [SortOrder('createdAt', false)]));
    return records.map((r) => DoctorModel.fromMap(r.value).toEntity()).toList();
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await _store.record(id).delete(db);
  }

  @override
  Future<List<Doctor>> search(String queryStr) async {
    final db = await _db;
    final q = queryStr.toLowerCase();
    final records = await _store.find(db, finder: Finder(sortOrders: [SortOrder('createdAt', false)]));
    final result = <Doctor>[];
    for (var r in records) {
      final map = r.value;
      final name = (map['name'] as String).toLowerCase();
      final dept = (map['department'] as String).toLowerCase();
      if (name.contains(q) || dept.contains(q)) {
        result.add(DoctorModel.fromMap(map).toEntity());
      }
    }
    return result;
  }
}
