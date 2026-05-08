enum HealthMetricType {
  water,
  steps,
  sleep,
  heartRate;

  String get labelKey => switch (this) {
    water => 'metric_water',
    steps => 'metric_steps',
    sleep => 'metric_sleep',
    heartRate => 'metric_heart_rate',
  };

  String get unitKey => switch (this) {
    water => 'unit_ml',
    steps => 'unit_steps',
    sleep => 'unit_hours',
    heartRate => 'unit_bpm',
  };
}

class HealthMetric {
  final String id;
  final HealthMetricType type;
  final double value;
  final String? note;
  final DateTime timestamp;

  const HealthMetric({
    required this.id,
    required this.type,
    required this.value,
    this.note,
    required this.timestamp,
  });

  HealthMetric copyWith({
    String? id,
    HealthMetricType? type,
    double? value,
    String? note,
    DateTime? timestamp,
  }) {
    return HealthMetric(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
