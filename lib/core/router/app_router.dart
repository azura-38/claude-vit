import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_guards.dart';

// Screens
import '../../features/appointments/presentation/screens/create_appointment_screen.dart';
import '../../features/appointments/presentation/screens/appointments_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/debug/presentation/screens/debug_panel_screen.dart';
import '../../features/doctors/presentation/screens/doctor_add_screen.dart';
import '../../features/doctors/presentation/screens/doctors_screen.dart';
import '../../features/vault/presentation/screens/document_add_screen.dart';
import '../../features/vault/presentation/screens/document_vault_screen.dart';
import '../../features/health_stats/presentation/screens/health_data_add_screen.dart';
import '../../features/health_stats/presentation/screens/health_stats_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/lock/lock_screen.dart';
import '../../features/medications/presentation/screens/add_medication_screen.dart';
import '../../features/medications/presentation/screens/medicines_screen.dart';
import '../../features/notifications/presentation/screens/reminder_troubleshooting_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/app_settings_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/important_information_screen.dart';
import '../../features/profile/presentation/screens/profile_create_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/personal_information_screen.dart';
import '../../features/onboarding/presentation/screens/legal/disclaimer_screen.dart';
import '../../features/onboarding/presentation/screens/legal/privacy_policy_screen.dart';
import '../../features/onboarding/presentation/screens/legal/terms_conditions_screen.dart';
import '../../features/profile/presentation/screens/theme_selection_screen.dart';
import '../error/presentation/screens/error_screen.dart';
import '../../features/doctors/presentation/screens/doctor_detail_screen.dart';
import '../../features/gamification/presentation/screens/achievements/achievements_screen.dart';
import '../../features/gamification/presentation/screens/season_pass/season_pass_screen.dart';

// Notifications
import '../../features/notifications/presentation/screens/medication_lock_notification.dart';
import '../../features/notifications/presentation/screens/appointment_lock_notification.dart';
import '../../features/notifications/presentation/screens/refill_banner_notification.dart';

// Core
import '../../features/auth/presentation/widgets/app_lock_gate.dart';
import '../../shared/widgets/vitacase_shell_ad_frame.dart';
import '../constants/app_routes.dart';
import '../security/secure_screen_guard.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<RouteGuardState>(routeGuardStateProvider, (prev, next) {
      notifyListeners();
    });
  }
}

Widget _withTopBanner(Widget child, {bool showBanner = true}) {
  return VitaCaseShellAdFrame(showBanner: showBanner, child: child);
}

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(routeGuardStateProvider);
  final refreshNotifier = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: AppRouter.navigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final currentGuard = ref.read(routeGuardStateProvider);
      if (!currentGuard.isBootstrapped) return null;

      return notificationRedirect(ref, state, currentGuard) ??
          onboardingRedirect(state, currentGuard) ??
          profileRedirect(state, currentGuard) ??
          legalRedirect(state, currentGuard) ??
          lockRedirect(state, currentGuard) ??
          completedEntryRedirect(state, currentGuard);
    },
    errorBuilder: (context, state) => ErrorScreen(message: state.error?.message),
    routes: [
      GoRoute(
        path: AppRoutes.lock,
        name: 'lock',
        builder: (context, state) => const SecureScreenGuard(child: LockScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileCreate,
        name: 'profileCreate',
        builder: (context, state) => const ProfileCreateScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsTerms,
        name: 'settingsTerms',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPrivacy,
        name: 'settingsPrivacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsDisclaimer,
        name: 'settingsDisclaimer',
        builder: (context, state) => const DisclaimerScreen(),
      ),
      GoRoute(
        path: '/notification/medication',
        builder: (context, state) => const MedicationLockNotificationScreen(),
      ),
      GoRoute(
        path: '/notification/appointment',
        builder: (context, state) => const AppointmentLockNotificationScreen(),
      ),
      GoRoute(
        path: '/notification/refill',
        builder: (context, state) => const RefillBannerNotificationScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppLockGate(child: child),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) => HomeScreen(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.home,
                    name: 'home',
                    builder: (context, state) => _withTopBanner(const DashboardScreen()),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.documents,
                    name: 'documents',
                    builder: (context, state) => _withTopBanner(const SecureScreenGuard(child: DocumentVaultScreen())),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/explore',
                    name: 'explore',
                    builder: (context, state) => _withTopBanner(const AchievementsScreen()),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.appointments,
                    name: 'appointments',
                    builder: (context, state) => _withTopBanner(const AppointmentsScreen()),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: 'appointmentAdd',
                        builder: (context, state) => const CreateAppointmentScreen(),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.profile,
                    name: 'profile',
                    builder: (context, state) => _withTopBanner(const ProfileScreen()),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'profileEdit',
                        builder: (context, state) => const EditProfileScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.seasonPass,
            name: 'seasonPass',
            builder: (context, state) => _withTopBanner(const SeasonPassScreen()),
          ),
          GoRoute(
            path: AppRoutes.achievements,
            name: 'achievements',
            builder: (context, state) => _withTopBanner(const AchievementsScreen()),
          ),
          GoRoute(
            path: AppRoutes.documentAdd,
            name: 'documentAdd',
            builder: (context, state) => const SecureScreenGuard(child: DocumentAddScreen()),
          ),
          GoRoute(
            path: AppRoutes.medicines,
            name: 'medicines',
            builder: (context, state) => _withTopBanner(const MedicinesScreen()),
            routes: [
              GoRoute(
                path: 'add',
                name: 'medicineAdd',
                builder: (context, state) => const AddMedicationScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.healthStats,
            name: 'healthStats',
            builder: (context, state) => _withTopBanner(const HealthStatsScreen()),
            routes: [
              GoRoute(
                path: 'add',
                name: 'healthDataAdd',
                builder: (context, state) => const HealthDataAddScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.doctors,
            name: 'doctors',
            builder: (context, state) => _withTopBanner(const DoctorsScreen()),
            routes: [
              GoRoute(
                path: 'add',
                name: 'doctorAdd',
                builder: (context, state) => const DoctorAddScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'doctorDetail',
                builder: (context, state) => _withTopBanner(DoctorDetailScreen(id: state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.personalInfo,
            name: 'profilePersonalInfo',
            builder: (context, state) => _withTopBanner(const PersonalInformationScreen()),
          ),
          GoRoute(
            path: AppRoutes.medicalInfo,
            name: 'medicalInfo',
            builder: (context, state) => _withTopBanner(const ImportantInformationScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => _withTopBanner(const AppSettingsScreen()),
            routes: [
              GoRoute(
                path: 'theme',
                name: 'settingsTheme',
                builder: (context, state) => _withTopBanner(const ThemeSelectionScreen()),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.reminderTroubleshooting,
            name: 'reminderTroubleshooting',
            builder: (context, state) => _withTopBanner(const ReminderTroubleshootingScreen()),
          ),
          GoRoute(
            path: AppRoutes.diagnosticsPanel,
            name: 'diagnosticsPanel',
            builder: (context, state) => _withTopBanner(const DebugPanelScreen()),
          ),
        ],
      ),
    ],
  );
});