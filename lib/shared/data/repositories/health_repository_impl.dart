import 'package:sembast/sembast.dart';
import '../datasources/sembast_database.dart';
import '../../domain/entities/health_metric.dart';
import '../../domain/repositories/health_repository.dart';
import '../models/health_metric_model.dart';

class HealthRepositoryImpl implements HealthRepository {
  final _store = stringMapStoreFactory.store('health_metrics');

  Future<Database> get _db async => SembastDatabase().db;

  @override
  Future<void> save(HealthMetric metric) async {
    final db = await _db;
    final model = HealthMetricModel.fromEntity(metric);
    await _store.record(metric.id).put(db, model.toMap());
  }

  @override
  Future<List<HealthMetric>> getAll() async {
    final db = await _db;
    final records = await _store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('timestamp', false)]),
    );
    return records
        .map((r) => HealthMetricModel.fromMap(r.value).toEntity())
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await _store.record(id).delete(db);
  }
}
