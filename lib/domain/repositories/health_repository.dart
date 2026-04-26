import '../entities/health_metric.dart';

abstract class HealthRepository {
  Future<void> save(HealthMetric metric);
  Future<List<HealthMetric>> getAll();
  Future<void> delete(String id);
}
