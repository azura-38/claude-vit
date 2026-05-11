import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_notification_payload.dart';

final pendingNotificationRouteProvider =
    NotifierProvider<PendingNotificationRouteNotifier, String?>(
      PendingNotificationRouteNotifier.new,
    );

class PendingNotificationRouteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFromPayload(String payload) {
    final decoded = AppNotificationPayload.decode(payload);
    switch (decoded.type) {
      case NotificationType.medication:
      state = '/notification/medication';
      return;
      case NotificationType.appointment:
      state = '/notification/appointment';
      return;
      case NotificationType.refill:
      state = '/notification/refill';
        return;
      case NotificationType.emergency:
        state = '/profile';
        return;
      case NotificationType.engagement:
      case NotificationType.unknown:
        state = '/';
    }
  }

  void clear() {
    state = null;
  }
}
