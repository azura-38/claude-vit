import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Providers
import '../../shared/providers/onboarding_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../notifications/notification_navigation.dart';

// Screens
import '../../features/appointments/presentation/screens/create_appointment_screen.dart';
import '../../features/appointments/presentation/screens/appointments_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/doctors/presentation/screens/doctor_add_screen.dart';
import '../../features/doctors/presentation/screens/doctors_screen.dart';
import '../../features/vault/presentation/screens/document_vault_screen.dart';
import '../../features/health_stats/presentation/screens/health_data_add_screen.dart';
import '../../features/health_stats/presentation/screens/health_stats_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../features/auth/presentation/screens/lock/lock_screen.dart';
import '../../features/medications/presentation/screens/add_medication_screen.dart';
import '../../features/medications/presentation/screens/medicines_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/app_settings_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
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
import '../../features/explore/presentation/screens/coming_soon_screen.dart';

// Notifications
import '../../features/notifications/presentation/screens/medication_lock_notification.dart';
import '../../features/notifications/presentation/screens/appointment_lock_notification.dart';
import '../../features/notifications/presentation/screens/refill_banner_notification.dart';

// Domain

// Core
import '../../features/auth/presentation/widgets/app_lock_gate.dart';
import '../constants/app_routes.dart';
import '../types/runtime_types.dart';
import 'package:vitacase/features/profile/presentation/providers/legacy_providers.dart';

/// Centralized Scale-Proof Router Configuration
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth & onboarding state for reactive redirects
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);
  final lockState = ref.watch(appLockStateProvider);
  final isLockEnabled = ref.watch(appLockEnabledProvider);
  final pendingNotificationRoute = ref.watch(pendingNotificationRouteProvider);

  return GoRouter(
    navigatorKey: AppRouter.navigatorKey,
    initialLocation: AppRoutes.home,

    // Global App Brain: Logic Control Center
    redirect: (context, state) {
      final isGoingToLock = state.matchedLocation == AppRoutes.lock;
      final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isGoingToProfileCreate =
          state.matchedLocation == AppRoutes.profileCreate;

      if (pendingNotificationRoute != null &&
          lockState == AppLockState.unlocked &&
          onboardingCompleted &&
          state.matchedLocation != pendingNotificationRoute) {
        Future.microtask(
          () => ref.read(pendingNotificationRouteProvider.notifier).clear(),
        );
        return pendingNotificationRoute;
      }

      if (lockState == AppLockState.unknown && !isGoingToLock) {
        return AppRoutes.lock;
      }

      // 1. Force Lock Screen if app lock is enabled and session is locked
      if (isLockEnabled && lockState != AppLockState.unlocked) {
        if (!isGoingToLock) return AppRoutes.lock;
        return null;
      }
      if (isGoingToLock &&
          (!isLockEnabled || lockState == AppLockState.unlocked)) {
        return AppRoutes.home;
      }

      // 2. Force Onboarding if not completed
      if (!onboardingCompleted) {
        if (!isGoingToOnboarding && !isGoingToProfileCreate) {
          return AppRoutes.onboarding;
        }
        return null;
      }

      // 3. Force Legal Acceptance if not done
      // This is critical for medical compliance (Score 100)
      final legalAccepted = ref.read(legalAcceptedProvider);
      if (!legalAccepted) {
        final isGoingToLegal =
            state.matchedLocation.contains('terms') ||
            state.matchedLocation.contains('privacy') ||
            state.matchedLocation.contains('disclaimer');
        if (!isGoingToLegal && !isGoingToProfileCreate) {
          return AppRoutes
              .profileCreate; // Force them back to profile create to accept
        }
      }

      // 4. Prevent going back to onboarding if done
      if (isGoingToOnboarding || isGoingToProfileCreate) {
        // If they already have a name, they don't need profile create again
        final hasName = ref.read(profileNameProvider) != null;
        if (hasName && legalAccepted) return AppRoutes.home;
      }

      return null;
    },

    // Handling 404s
    errorBuilder:
        (context, state) => ErrorScreen(message: state.error?.message),

    routes: [
      // Auth & Entry Flow
      GoRoute(
        path: AppRoutes.lock,
        name: 'lock',
        builder: (context, state) => const LockScreen(),
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

      // Notifications
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

      // Main App Shell (Protected)
      ShellRoute(
        builder: (context, state, child) => AppLockGate(child: child),
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return HomeScreen(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path:
                        AppRoutes
                            .home, // Maps to Dashboard via HomeScreen logic or redirection
                    name: 'home',
                    builder: (context, state) => const DashboardScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.documents,
                    name: 'documents',
                    builder: (context, state) => const DocumentVaultScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/explore-placeholder',
                    builder: (context, state) => const ComingSoonScreen(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: AppRoutes.appointments,
                    name: 'appointments',
                    builder: (context, state) => const AppointmentsScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: 'appointmentAdd',
                        builder:
                            (context, state) => const CreateAppointmentScreen(),
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
                    builder: (context, state) => const ProfileScreen(),
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

          // Global Feature Routes
          GoRoute(
            path: AppRoutes.seasonPass,
            name: 'seasonPass',
            builder: (context, state) => const SeasonPassScreen(),
          ),
          GoRoute(
            path: AppRoutes.achievements,
            name: 'achievements',
            builder: (context, state) => const AchievementsScreen(),
          ),

          // Features (Scale-Proof Hierarchical Routes)
          GoRoute(
            path: AppRoutes.medicines,
            name: 'medicines',
            builder: (context, state) => const MedicinesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'medicineAdd',
                builder: (context, state) => const AddMedicationScreen(),
              ),
            ],
          ),

          GoRoute(
            path: AppRoutes.doctors,
            name: 'doctors',
            builder: (context, state) => const DoctorsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'doctorAdd',
                builder: (context, state) => const DoctorAddScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'doctorDetail',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  if (id == null) {
                    return const ErrorScreen(message: 'Doctor not found');
                  }
                  return DoctorDetailScreen(id: id);
                },
              ),
            ],
          ),

          GoRoute(
            path: '/health',
            routes: [
              GoRoute(
                path: 'add',
                name: 'healthAdd',
                builder: (context, state) => const HealthDataAddScreen(),
              ),
            ],
          ),

          // Profile & Settings Tree
          GoRoute(
            path: AppRoutes.personalInfo,
            name: 'personalInfo',
            builder: (context, state) => const PersonalInformationScreen(),
          ),
          GoRoute(
            path: AppRoutes.medicalInfo,
            name: 'medicalInfo',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.healthStats,
            name: 'healthStats',
            builder: (context, state) => const HealthStatsScreen(),
          ),

          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const AppSettingsScreen(),
            routes: [
              GoRoute(
                path: 'theme',
                name: 'settingsTheme',
                builder: (context, state) => const ThemeSelectionScreen(),
              ),
              GoRoute(
                path: 'terms',
                name: 'settingsTerms',
                builder: (context, state) => const TermsConditionsScreen(),
              ),
              GoRoute(
                path: 'privacy',
                name: 'settingsPrivacy',
                builder: (context, state) => const PrivacyPolicyScreen(),
              ),
              GoRoute(
                path: 'disclaimer',
                name: 'settingsDisclaimer',
                builder: (context, state) => const DisclaimerScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
