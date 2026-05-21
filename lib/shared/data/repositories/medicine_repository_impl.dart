import 'package:sembast/sembast.dart';
import 'package:vitacase/features/medications/domain/entities/medicine.dart';
import 'package:vitacase/shared/domain/repositories/medicine_repository.dart';
import '../datasources/sembast_database.dart';
import '../models/medicine_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final _store = stringMapStoreFactory.store('medicines');

  Future<Database> get _db async => SembastDatabase().ready;

  @override
  Future<void> save(Medicine medicine) async {
    final db = await _db;
    final model = MedicineModel.fromEntity(medicine);
    await _store.record(medicine.id).put(db, model.toMap());
  }

  @override
  Future<Medicine?> getById(String id) async {
    final db = await _db;
    final record = await _store.record(id).get(db);
    if (record == null) return null;
    return MedicineModel.fromMap(record).toEntity();
  }

  @override
  Future<List<Medicine>> getAll() async {
    final db = await _db;
    final records = await _store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('createdAt', false)]),
    );
    return records
        .map((r) => MedicineModel.fromMap(r.value).toEntity())
        .toList();
  }

  @override
  Future<void> update(Medicine medicine) async {
    final db = await _db;
    final model = MedicineModel.fromEntity(medicine);
    await _store.record(medicine.id).put(db, model.toMap());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await _store.record(id).delete(db);
  }
}
