import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingNotificationRouteProvider =
    NotifierProvider<PendingNotificationRouteNotifier, String?>(
      PendingNotificationRouteNotifier.new,
    );

class PendingNotificationRouteNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFromPayload(String payload) {
    if (payload.startsWith('medicine') || payload.startsWith('med_')) {
      state = '/notification/medication';
      return;
    }
    if (payload.startsWith('appointment') || payload.startsWith('appt_')) {
      state = '/notification/appointment';
      return;
    }
    if (payload.startsWith('refill')) {
      state = '/notification/refill';
    }
  }

  void clear() {
    state = null;
  }
}
