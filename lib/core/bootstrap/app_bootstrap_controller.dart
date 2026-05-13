import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../firebase_options.dart';
import '../../shared/providers/document_providers.dart';
import '../../shared/data/services/notification_engine.dart';
import '../../shared/data/services/notification_service.dart';
import '../../shared/providers/medicine_providers.dart';
import '../../features/appointments/presentation/providers/appointment_providers.dart';
import '../../core/notifications/notification_navigation.dart';
import '../../core/di/service_providers.dart';
import '../../core/utils/uid_manager.dart';
import '../../shared/providers/shared_prefs_provider.dart';

/// Key used to gate notification reschedule (avoid running every cold start).
const _kLastRescheduleKey = 'last_notification_reschedule_ts';

/// Minimum gap (in minutes) between reschedule runs.
const _kRescheduleGapMinutes = 30;

/// The global bootstrap provider.
/// Watched by [BootstrapScreen] to decide what UI to show.
final appBootstrapProvider = AsyncNotifierProvider<AppBootstrapController, void>(
  AppBootstrapController.new,
);

class AppBootstrapController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Startup is kicked off from main() because it needs the ProviderContainer.
  }

  /// Called from main() with the ProviderContainer — kicks off all phases.
  Future<void> run(ProviderContainer container) async {
    state = const AsyncLoading();

    try {
      await _executeAllPhases(container);
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('[Bootstrap] Fatal error: $e');
      debugPrintStack(stackTrace: st);
      try {
        await Sentry.captureException(e, stackTrace: st);
      } catch (_) {}
      state = AsyncError(e, st);
    }
  }

  Future<void> _executeAllPhases(ProviderContainer container) async {
    _setupErrorHandlers();
    _log('Phase 0: Error handlers installed');

    // Web preview does not support all native plugins used by the mobile vault
    // stack (path_provider documents directory, native secure screen, local
    // notification scheduling). Keep web usable for UI review, while Android/iOS
    // continue to run the full production bootstrap.
    if (kIsWeb) {
      _log('Web preview detected — skipping mobile-only bootstrap phases ✅');
      await _initializeLocalizationOnly();
      return;
    }

    // ── Phase 1: Encrypted database (encryption key → DB open) ────────────
    _log('Phase 1: Opening encrypted database...');
    final encryptionService = container.read(encryptionServiceProvider);
    final sembastDb = container.read(sembastDatabaseProvider);

    try {
      await sembastDb.init(encryptionService);
    } catch (e, st) {
      debugPrint('[Bootstrap][sembast_init] FATAL DB error: $e');
      debugPrintStack(stackTrace: st);
      try {
        await Sentry.captureException(e, stackTrace: st);
      } catch (_) {}
      rethrow;
    }

    _log('Phase 1: Database ready ✅');

    // ── Phase 2: Firebase + localization ─────────────────────────────────
    _log('Phase 2: Firebase + localization...');

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, st) {
      debugPrint('[Bootstrap][firebase] FATAL Firebase error: $e');
      debugPrintStack(stackTrace: st);
      try {
        await Sentry.captureException(e, stackTrace: st);
      } catch (_) {}
      rethrow;
    }

    await _initializeLocalizationOnly();
    _log('Phase 2: Firebase + localization ✅');

    // ── Phase 3: Notification CORE only (no permission requests) ──────────
    _log('Phase 3: Notification core init...');
    await Future.wait([
      _safeRun('notif_service_core', NotificationService.initCore()),
      _safeRun('notif_engine_core', NotificationEngine.initializeCore()),
    ]);
    _log('Phase 3: Notification core ✅');

    // ── Phase 4: File storage cleanup ─────────────────────────────────────
    _log('Phase 4: File storage init...');
    await _safeRun('file_storage', container.read(fileStorageServiceProvider).init());
    _log('Phase 4: File storage ✅');

    // ── Phase 5: Crashlytics handler (Firebase must be ready first) ────────
    _log('Phase 5: Crashlytics...');
    await _safeRun('crashlytics', _setupCrashlytics());
    _log('Phase 5: Crashlytics ✅');

    // ── Phase 6: Sentry user identity ─────────────────────────────────────
    _log('Phase 6: Identity...');
    await _safeRun('identity', _configureIdentity());
    _log('Phase 6: Identity ✅');

    _schedulePostFrameWork(container);
    _log('Phase 7: Deferred work scheduled ✅');
  }

  Future<void> _initializeLocalizationOnly() {
    return Future.wait([
      _safeRun('date_tr', initializeDateFormatting('tr_TR', null)),
      _safeRun('date_en', initializeDateFormatting('en_US', null)),
      _safeRun('date_de', initializeDateFormatting('de_DE', null)),
      _safeRun('date_fr', initializeDateFormatting('fr_FR', null)),
      _safeRun('date_es', initializeDateFormatting('es_ES', null)),
      _safeRun('date_it', initializeDateFormatting('it_IT', null)),
      _safeRun('date_pt', initializeDateFormatting('pt_PT', null)),
    ]);
  }

  // ── Error Handlers ────────────────────────────────────────────────────────

  void _setupErrorHandlers() {
    FlutterError.onError = (details) {
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
      if (!kIsWeb) {
        try {
          FirebaseCrashlytics.instance.recordFlutterError(details);
        } catch (_) {}
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[PlatformError] $error');
      if (!kIsWeb) {
        try {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        } catch (_) {}
      }
      return true;
    };
  }

  Future<void> _setupCrashlytics() async {
    if (kIsWeb) return;
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  Future<void> _configureIdentity() async {
    final uid = await UIDManager.getUID();
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: uid));
    });
  }

  // ── Deferred Post-Frame Work ──────────────────────────────────────────────

  void _schedulePostFrameWork(ProviderContainer container) {
    Future.delayed(const Duration(milliseconds: 300), () {
      _runDeferredWork(container);
    });
  }

  Future<void> _runDeferredWork(ProviderContainer container) async {
    if (kIsWeb) return;

    _log('Deferred: Requesting notification permissions...');
    await _safeRun('notif_permissions', NotificationService.requestStartupPermissions());
    await _safeRun('engine_permissions', NotificationEngine.requestPermissions());

    _log('Deferred: Starting notification listeners...');
    await _safeRun('notif_listeners', _setupNotificationListeners(container));

    _log('Deferred: Conditional reschedule...');
    await _safeRun('reschedule', _conditionalReschedule(container));
  }

  Future<void> _setupNotificationListeners(ProviderContainer container) async {
    await NotificationEngine.startListening((receivedAction) async {
      final payload = receivedAction.payload?['payload'];
      if (payload != null && payload.isNotEmpty) {
        try {
          container.read(pendingNotificationRouteProvider.notifier).setFromPayload(payload);
        } catch (e) {
          debugPrint('[Bootstrap] Failed to set notification route: $e');
        }
      }

      if (receivedAction.buttonKeyPressed == 'MARK_DONE') {
        final entityId = receivedAction.payload?['entityId'];
        if (entityId != null) {
          await _safeRun(
            'medicine_taken',
            container.read(medicineListProvider.notifier).markAsTaken(entityId),
          );
        }
      } else if (receivedAction.buttonKeyPressed == 'SKIP') {
        final entityId = receivedAction.payload?['entityId'];
        if (entityId != null) {
          await _safeRun(
            'medicine_skipped',
            container.read(medicineListProvider.notifier).markAsSkipped(entityId),
          );
        }
      }
    });
  }

  Future<void> _conditionalReschedule(ProviderContainer container) async {
    final prefs = container.read(sharedPreferencesProvider);
    final lastTs = prefs.getInt(_kLastRescheduleKey) ?? 0;
    final lastReschedule = DateTime.fromMillisecondsSinceEpoch(lastTs);
    final gapMinutes = DateTime.now().difference(lastReschedule).inMinutes;

    if (gapMinutes < _kRescheduleGapMinutes) {
      _log('Skipping reschedule — last ran ${gapMinutes}m ago (gate: ${_kRescheduleGapMinutes}m)');
      return;
    }

    _log('Running notification reschedule (gap: ${gapMinutes}m)...');
    final meds = await container.read(medicineListProvider.future);
    final appts = await container.read(appointmentListProvider.future);

    await container.read(medicineListProvider.notifier).rescheduleAllNotifications(meds);
    await container.read(appointmentListProvider.notifier).rescheduleAllNotifications(appts);

    await prefs.setInt(_kLastRescheduleKey, DateTime.now().millisecondsSinceEpoch);
    _log('Reschedule complete ✅');
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  Future<void> _safeRun(String tag, Future<void> future) async {
    try {
      await future;
    } catch (e, st) {
      debugPrint('[Bootstrap][$tag] Non-fatal error: $e');
      try {
        await Sentry.captureException(e, stackTrace: st);
      } catch (_) {}
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[Bootstrap] $message');
  }
}
