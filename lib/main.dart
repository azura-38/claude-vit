import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/bootstrap/app_bootstrap_controller.dart';
import 'shared/providers/shared_prefs_provider.dart';

/// Entry point — kept intentionally minimal.
/// 
/// All initialization logic lives in [AppBootstrapController].
/// This function only:
///   1. Wraps with Sentry
///   2. Initializes Flutter bindings
///   3. Loads SharedPreferences (sync-safe, needed before ProviderContainer)
///   4. Creates the ProviderContainer with the prefs override
///   5. Starts the bootstrap controller
///   6. Calls runApp()
void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.environment = AppConfig.isProduction ? 'production' : 'debug';
      options.tracesSampleRate = AppConfig.isProduction ? 0.1 : 1.0;
      options.enableTombstone = true;
    },
    appRunner: () async {
      // ── Step 1: Flutter engine binding ─────────────────────────────────────
      WidgetsFlutterBinding.ensureInitialized();

      // ── Step 2: SharedPreferences (fast, sync-accessible post-load) ────────
      // Must be loaded before ProviderContainer so the override is available
      // immediately to all synchronously-built providers (onboarding, etc.)
      final prefs = await SharedPreferences.getInstance();

      // ── Step 3: ProviderContainer with SharedPreferences override ──────────
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      // ── Step 4: Run bootstrap (non-blocking for runApp) ────────────────────
      // We fire the bootstrap but do NOT await it here.
      // The [BootstrapScreen] widget watches [appBootstrapProvider] and shows
      // the splash until the bootstrap completes.
      // This means runApp() is called immediately — no white frame.
      unawaited(
        container.read(appBootstrapProvider.notifier).run(container),
      );

      // ── Step 5: Launch the app ─────────────────────────────────────────────
      runApp(
        UncontrolledProviderScope(
          container: container,
          child: const VitaCaseApp(),
        ),
      );
    },
  );
}

/// Suppresses the linter warning about unawaited futures.
void unawaited(Future<void> future) {
  future.catchError((Object e, StackTrace st) {
    debugPrint('[main] Unawaited future error: $e');
  });
}
