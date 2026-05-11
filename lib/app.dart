import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/security/security_controller.dart';
import 'core/security/session_lock_service.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'package:vitacase/l10n/app_localizations.dart';
import 'shared/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'shared/providers/document_providers.dart';
import 'shared/data/services/smart_notification_system.dart';
import 'shared/providers/user_behavior_provider.dart';
import 'shared/data/services/ad_controller.dart';

class VitaCaseApp extends ConsumerStatefulWidget {
  const VitaCaseApp({super.key});

  @override
  ConsumerState<VitaCaseApp> createState() => _VitaCaseAppState();
}

class _VitaCaseAppState extends ConsumerState<VitaCaseApp>
    with WidgetsBindingObserver {
  DateTime? _lastPausedTime;
  bool _obscureScreen = false;
  final _sessionLockService = SessionLockService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLockState();
      unawaited(
        ref.read(securityControllerProvider.notifier).applySecureScreenPolicy(),
      );
      final user = ref.read(userBehaviorProvider);
      NotificationTriggers.onAppOpen(user);
      if (!ref.read(appLockEnabledProvider)) {
        unawaited(ref.read(adControllerProvider).onAppOpen());
      }
    });
  }

  void _initLockState() {
    final lockEnabled = ref.read(appLockEnabledProvider);
    if (lockEnabled) {
      ref.read(appLockStateProvider.notifier).setLocked();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final lockEnabled = ref.read(appLockEnabledProvider);

    // Obscure the screen when inactive or paused to prevent OS Snapshot leak
    setState(() {
      _obscureScreen = _sessionLockService.shouldObscure(
        lockEnabled: lockEnabled,
        state: state,
      );
    });

    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
      _sessionLockService.markPaused();
      NotificationTriggers.onAppClose();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(fileStorageServiceProvider).cleanupAllTempFiles();

      if (lockEnabled && _lastPausedTime != null) {
        final timeout = ref.read(lockTimeoutProvider);

        if (_sessionLockService.shouldLockOnResume(timeout.duration)) {
          ref.read(appLockStateProvider.notifier).setLocked();
        } else {
          unawaited(ref.read(adControllerProvider).onAppOpen());
        }
      } else {
        unawaited(ref.read(adControllerProvider).onAppOpen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTheme = ref.watch(themeTypeProvider);
    final currentLocale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'VitaCase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeByType(selectedTheme),
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (child != null) child,
            if (_obscureScreen)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.black.withValues(alpha: 0.1)),
              ),
          ],
        );
      },
    );
  }
}
