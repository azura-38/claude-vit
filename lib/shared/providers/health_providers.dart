import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/health_repository_impl.dart';
import '../domain/entities/health_metric.dart';
import '../domain/repositories/health_repository.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepositoryImpl();
});

final healthListProvider =
    AsyncNotifierProvider<HealthListNotifier, List<HealthMetric>>(
      HealthListNotifier.new,
    );

class HealthListNotifier extends AsyncNotifier<List<HealthMetric>> {
  @override
  Future<List<HealthMetric>> build() async {
    return ref.read(healthRepositoryProvider).getAll();
  }

  Future<void> addMetric(HealthMetric metric) async {
    await ref.read(healthRepositoryProvider).save(metric);
    ref.invalidateSelf();
  }

  Future<void> deleteMetric(String id) async {
    await ref.read(healthRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final dailyHealthProgressProvider = Provider<Map<String, double>>((ref) {
  final metrics = ref.watch(healthListProvider).asData?.value ?? [];
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  double todaySteps = 0;
  double todayWater = 0;
  double latestHeartRate = 0;
  double todaySleep = 0;

  // Sort metrics by timestamp to get latest heart rate correctly
  final sortedMetrics = List<HealthMetric>.from(metrics)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  for (final m in metrics) {
    if (m.timestamp.isAfter(todayStart)) {
      if (m.type == HealthMetricType.steps) todaySteps += m.value;
      if (m.type == HealthMetricType.water) todayWater += m.value;
      if (m.type == HealthMetricType.sleep) todaySleep += m.value;
    }
  }

  // Get latest heart rate today
  final heartMetrics =
      sortedMetrics
          .where(
            (m) =>
                m.type == HealthMetricType.heartRate &&
                m.timestamp.isAfter(todayStart),
          )
          .toList();
  if (heartMetrics.isNotEmpty) {
    latestHeartRate = heartMetrics.first.value;
  }

  return {
    'steps': todaySteps,
    'water': todayWater,
    'heartRate': latestHeartRate,
    'sleep': todaySleep,
  };
});
