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
import 'core/types/runtime_types.dart';
import 'data/datasources/file_storage_service.dart';
import 'data/datasources/sembast_database.dart';
import 'presentation/providers/shared_prefs_provider.dart';
import 'data/services/smart_notification_system.dart';
import 'data/services/consent_service.dart';
import 'presentation/providers/appointment_providers.dart';
import 'presentation/providers/medicine_providers.dart';
import 'core/l10n/translations.dart';
import 'data/services/notification_service.dart';

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
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
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
          NotificationService.init().then((_) async {
            // Step 4: Test notification (Standardized Static Call)
            await NotificationService.schedule(
              id: "debug_test",
              title: "VitaCase Engine",
              body: "Notification system is ONLINE! ✅",
              date: DateTime.now().add(const Duration(seconds: 30)),
            );
          }),
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
      NotificationService.setContainer(container);

      // 7. Startup Reschedule (Production Fix)
      Future.microtask(() async {
        try {
          final meds = await container.read(medicineListProvider.future);
          final appts = await container.read(appointmentListProvider.future);
          
          final items = [
            ...meds.map((m) => {
                  "id": m.id,
                  "title": "💊 Medication",
                  "body": m.name,
                  "date": m.nextReminderTime,
                }),
            ...appts.map((a) => {
                  "id": a.id,
                  "title": "📅 Appointment",
                  "body": a.doctor,
                  "date": a.fullDateTime,
                }),
          ];
          
          await NotificationService.rescheduleAll(items);
          debugPrint('[NotificationReschedule] Sync completed for ${items.length} items');
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
