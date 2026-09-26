import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';

import 'core/bootstrap/bootstrap_screen.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/dashboard/presentation/providers/app_lifecycle_controller.dart';
import 'shared/providers/locale_provider.dart';

class VitaCaseApp extends ConsumerStatefulWidget {
  const VitaCaseApp({super.key});

  @override
  ConsumerState<VitaCaseApp> createState() => _VitaCaseAppState();
}

class _VitaCaseAppState extends ConsumerState<VitaCaseApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appLifecycleProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    ref.read(appLifecycleProvider.notifier).handleLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTheme = ref.watch(themeTypeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);
    final obscureScreen = ref.watch(appLifecycleProvider);

    return MaterialApp.router(
      title: 'VitaCase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeByType(selectedTheme),
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: currentLocale,
      localizationsDelegates: VitaAppLocalizationsDelegate.localizationsDelegates,
      supportedLocales: VitaAppLocalizationsDelegate.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        final appBody = Stack(
          fit: StackFit.expand,
          alignment: Alignment.topLeft,
          children: [
            if (child != null) child,
            if (obscureScreen)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(color: Colors.black.withValues(alpha: 0.1)),
              ),
          ],
        );

        return BootstrapScreen(child: appBody);
      },
    );
  }
}
