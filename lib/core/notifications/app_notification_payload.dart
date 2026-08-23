import 'dart:convert';

enum NotificationType {
  medication,
  appointment,
  refill,
  emergency,
  engagement,
  unknown,
}

class AppNotificationPayload {
  const AppNotificationPayload({
    required this.type,
    required this.entityId,
    this.action,
    this.occurrenceAt,
    this.route,
  });

  final NotificationType type;
  final String entityId;
  final String? action;
  final DateTime? occurrenceAt;
  final String? route;

  String encode() {
    return jsonEncode({
      'type': type.name,
      'entityId': entityId,
      'action': action,
      'occurrenceAt': occurrenceAt?.toIso8601String(),
      'route': route,
    });
  }

  static AppNotificationPayload decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AppNotificationPayload(
        type: NotificationType.values.firstWhere(
          (type) => type.name == map['type'],
          orElse: () => NotificationType.unknown,
        ),
        entityId: map['entityId'] as String? ?? '',
        action: map['action'] as String?,
        occurrenceAt:
            map['occurrenceAt'] is String
                ? DateTime.tryParse(map['occurrenceAt'] as String)
                : null,
        route: map['route'] as String?,
      );
    } catch (_) {
      if (raw.startsWith('medicine') || raw.startsWith('med_')) {
        return AppNotificationPayload(
          type: NotificationType.medication,
          entityId: raw,
        );
      }
      if (raw.startsWith('appointment') || raw.startsWith('appt_')) {
        return AppNotificationPayload(
          type: NotificationType.appointment,
          entityId: raw,
        );
      }
      if (raw.startsWith('low_stock')) {
        return AppNotificationPayload(type: NotificationType.refill, entityId: raw);
      }
      if (raw.startsWith('refill')) {
        return AppNotificationPayload(type: NotificationType.refill, entityId: raw);
      }
      return AppNotificationPayload(type: NotificationType.unknown, entityId: raw);
    }
  }
}
