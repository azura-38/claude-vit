import '../../domain/entities/health_metric.dart';

class HealthMetricModel {
  final String id;
  final String type;
  final double value;
  final String? note;
  final DateTime timestamp;

  HealthMetricModel({
    required this.id,
    required this.type,
    required this.value,
    this.note,
    required this.timestamp,
  });

  factory HealthMetricModel.fromEntity(HealthMetric entity) {
    return HealthMetricModel(
      id: entity.id,
      type: entity.type.name,
      value: entity.value,
      note: entity.note,
      timestamp: entity.timestamp,
    );
  }

  HealthMetric toEntity() {
    return HealthMetric(
      id: id,
      type: HealthMetricType.values.byName(type),
      value: value,
      note: note,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'value': value,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HealthMetricModel.fromMap(Map<String, dynamic> map) {
    return HealthMetricModel(
      id: map['id'],
      type: map['type'],
      value: map['value'],
      note: map['note'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
