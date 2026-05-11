import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/utils/uid_manager.dart';
import 'core/di/service_providers.dart';
import 'shared/providers/shared_prefs_provider.dart';
import 'shared/providers/document_providers.dart';
import 'shared/data/services/smart_notification_system.dart';
import 'features/appointments/presentation/providers/appointment_providers.dart';
import 'shared/providers/medicine_providers.dart';
import 'shared/data/services/notification_service.dart';
import 'core/notifications/notification_navigation.dart';

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.isProduction ? 'production' : 'debug';
      options.tracesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;
      options.enableTombstone = true;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 1. Core Services (Critical Path)
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final sembastDb = container.read(sembastDatabaseProvider);
      final encryptionService = container.read(encryptionServiceProvider);
      final notificationService = container.read(notificationServiceProvider);

      try {
        // 2. Data & Localization
        await Future.wait([
          Firebase.initializeApp(),
          initializeDateFormatting('tr_TR', null),
          initializeDateFormatting('en_US', null),
          sembastDb.init(encryptionService),
          NotificationService.init(
            onMedicineTaken:
                (id) => container
                    .read(medicineListProvider.notifier)
                    .markAsTaken(id),
            onMedicineSkipped:
                (id) => container
                    .read(medicineListProvider.notifier)
                    .markAsSkipped(id),
          ),
        ]);
      } catch (e) {
        debugPrint('[Bootstrap] Error: $e');
      }

      // 3. Crashlytics & Analytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      // 4. File Storage Setup
      await container.read(fileStorageServiceProvider).init();

      // 5. User Identity
      final uid = await UIDManager.getUID();
      await Sentry.configureScope((scope) {
        scope.setUser(SentryUser(id: uid));
      });

      // 6. Launch Application
      await SmartNotificationService.loadSettings();
      SmartNotificationService.configure(notificationService);
      NotificationService.setRouteHandler(
        (payload) => container
            .read(pendingNotificationRouteProvider.notifier)
            .setFromPayload(payload),
      );

      // 7. Startup Reschedule (Production Fix)
      Future.microtask(() async {
        try {
          await NotificationService.cancelAll();
          await scheduleAllFromProviders(container);
          debugPrint('[NotificationReschedule] Sync completed');
        } catch (e) {
          debugPrint('[NotificationReschedule] Failed: $e');
        }
      });

      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const VitaCaseApp(),
        ),
      );
    },
  );
}

Future<void> scheduleAllFromProviders(ProviderContainer container) async {
  final meds = await container.read(medicineListProvider.future);
  final appts = await container.read(appointmentListProvider.future);

  await container
      .read(medicineListProvider.notifier)
      .rescheduleAllNotifications(meds);
  await container
      .read(appointmentListProvider.notifier)
      .rescheduleAllNotifications(appts);
}
