import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:vitacase/shared/data/services/notification_engine.dart';

class FakeAwesomeNotificationsClient implements AwesomeNotificationsClient {
  int initializeCallCount = 0;
  int cancelCallCount = 0;
  int cancelAllCallCount = 0;
  int createNotificationCallCount = 0;
  int requestPermissionCallCount = 0;
  bool isAllowed = true;
  bool shouldThrowOnInitialize = false;
  bool shouldThrowOnSchedule = false;
  bool shouldThrowOnCancel = false;

  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<int> cancelledIds = [];
  Future<void> Function(ReceivedAction)? actionCallback;

  @override
  Future<bool> initialize(
    String? defaultIcon,
    List<NotificationChannel> channels, {
    List<NotificationChannelGroup>? channelGroups,
    bool debug = false,
  }) async {
    initializeCallCount++;
    if (shouldThrowOnInitialize) {
      throw Exception('Simulated platform initialization failure');
    }
    return true;
  }

  @override
  Future<bool> isNotificationAllowed() async => isAllowed;

  @override
  Future<bool> requestPermissionToSendNotifications({
    String? channelKey,
    List<NotificationPermission> permissions = const [],
  }) async {
    requestPermissionCallCount++;
    return isAllowed;
  }

  @override
  Future<bool> createNotification({
    required NotificationContent content,
    NotificationCalendar? schedule,
    List<NotificationActionButton>? actionButtons,
  }) async {
    createNotificationCallCount++;
    if (shouldThrowOnSchedule) {
      throw Exception('Simulated platform zonedSchedule failure');
    }
    scheduledNotifications.removeWhere((item) => item['id'] == content.id);
    scheduledNotifications.add({
      'id': content.id,
      'title': content.title,
      'body': content.body,
      'channelKey': content.channelKey,
      'payload': content.payload?['payload'],
      'entityId': content.payload?['entityId'],
      'schedule': schedule,
    });
    return true;
  }

  @override
  Future<void> cancel(int id) async {
    cancelCallCount++;
    if (shouldThrowOnCancel) {
      throw Exception('Simulated platform cancel failure');
    }
    cancelledIds.add(id);
    scheduledNotifications.removeWhere((item) => item['id'] == id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCallCount++;
    scheduledNotifications.clear();
  }

  @override
  Future<List<NotificationModel>> listScheduledNotifications() async {
    return scheduledNotifications.map((s) {
      return NotificationModel(
        content: NotificationContent(
          id: (s['id'] as int?) ?? 0,
          channelKey: (s['channelKey'] as String?) ?? '',
          payload: {
            'payload': s['payload'] as String? ?? '',
            'entityId': s['entityId'] as String? ?? '',
          },
        ),
        schedule: s['schedule'] as NotificationSchedule?,
      );
    }).toList();
  }

  @override
  Future<void> setListeners({
    required Future<void> Function(ReceivedAction) onActionReceivedMethod,
  }) async {
    actionCallback = onActionReceivedMethod;
  }

  String fakeTimeZone = 'Europe/Istanbul';

  @override
  Future<String> getLocalTimeZoneIdentifier() async => fakeTimeZone;
}
