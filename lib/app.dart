import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_providers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_localizations.dart';
import 'presentation/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/document_providers.dart';
import 'data/services/smart_notification_system.dart';
import 'presentation/providers/user_behavior_provider.dart';
import 'data/services/ad_controller.dart';

class VitaCaseApp extends ConsumerStatefulWidget {
  const VitaCaseApp({super.key});

  @override
  ConsumerState<VitaCaseApp> createState() => _VitaCaseAppState();
}

class _VitaCaseAppState extends ConsumerState<VitaCaseApp>
    with WidgetsBindingObserver {
  DateTime? _lastPausedTime;
  bool _obscureScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLockState();
      final user = ref.read(userBehaviorProvider);
      NotificationTriggers.onAppOpen(user);
      unawaited(ref.read(adControllerProvider).onAppOpen());
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
      _obscureScreen =
          lockEnabled &&
          (state == AppLifecycleState.inactive ||
              state == AppLifecycleState.paused ||
              state == AppLifecycleState.hidden);
    });

    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
      NotificationTriggers.onAppClose();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(fileStorageServiceProvider).cleanupAllTempFiles();
      unawaited(ref.read(adControllerProvider).onAppOpen());

      if (lockEnabled && _lastPausedTime != null) {
        final timeout = ref.read(lockTimeoutProvider);
        final diff = DateTime.now().difference(_lastPausedTime!);

        if (diff >= timeout.duration) {
          ref.read(appLockStateProvider.notifier).setLocked();
        }
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
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('de'),
        Locale('es'),
        Locale('fr'),
        Locale('pt'),
        Locale('ar'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
      ],
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
