import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_routes.dart';
import 'app_notification_payload.dart';

final pendingNotificationRouteProvider = NotifierProvider<PendingNotificationRouteNotifier, String?>(
  PendingNotificationRouteNotifier.new,
);

class PendingNotificationRouteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFromPayload(String payload) {
    final decoded = AppNotificationPayload.decode(payload);
    switch (decoded.type) {
      case NotificationType.medication:
        state = AppRoutes.medicines;
        return;
      case NotificationType.appointment:
        state = AppRoutes.appointments;
        return;
      case NotificationType.refill:
        state = AppRoutes.medicines;
        return;
      case NotificationType.emergency:
        state = AppRoutes.profile;
        return;
      case NotificationType.engagement:
      case NotificationType.unknown:
        state = AppRoutes.home;
        return;
    }
  }

  void clear() {
    state = null;
  }
}
