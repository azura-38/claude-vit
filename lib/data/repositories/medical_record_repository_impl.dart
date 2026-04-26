import 'package:sembast/sembast.dart';
import '../../../domain/entities/medical_record.dart';
import '../../../domain/repositories/medical_record_repository.dart';
import '../datasources/sembast_database.dart';
import '../models/medical_record_model.dart';

class MedicalRecordRepositoryImpl implements MedicalRecordRepository {
  final _store = stringMapStoreFactory.store('medical_records');

  Future<Database> get _db async => SembastDatabase().db;

  @override
  Future<void> save(MedicalRecord record) async {
    final db = await _db;
    final model = MedicalRecordModel.fromEntity(record);
    await _store.record(record.id).put(db, model.toMap());
  }

  @override
  Future<MedicalRecord?> getById(String id) async {
    final db = await _db;
    final record = await _store.record(id).get(db);
    if (record == null) return null;
    return MedicalRecordModel.fromMap(record).toEntity();
  }

  @override
  Future<List<MedicalRecord>> getAll() async {
    final db = await _db;
    final records = await _store.find(db, finder: Finder(sortOrders: [SortOrder('createdAt', false)]));
    return records.map((r) => MedicalRecordModel.fromMap(r.value).toEntity()).toList();
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await _store.record(id).delete(db);
  }
}
