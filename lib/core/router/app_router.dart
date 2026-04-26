import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Providers
import '../../presentation/providers/onboarding_provider.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/providers/profile_provider.dart';

// Screens
import '../../presentation/screens/appointments/appointment_add_screen.dart';
import '../../presentation/screens/appointments/appointments_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/doctors/doctor_add_screen.dart';
import '../../presentation/screens/doctors/doctors_screen.dart';
import '../../presentation/screens/documents/documents_screen.dart';
import '../../presentation/screens/health/health_data_add_screen.dart';
import '../../presentation/screens/health/health_stats_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/lock/lock_screen.dart';
import '../../presentation/screens/medicines/medicine_add_screen.dart';
import '../../presentation/screens/medicines/medicines_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/profile/app_settings_screen.dart';
import '../../presentation/screens/profile/medical_info_screen.dart';
import '../../presentation/screens/profile/personal_info_screen.dart';
import '../../presentation/screens/profile/profile_create_screen.dart';
import '../../presentation/screens/profile/profile_edit_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/legal/disclaimer_screen.dart';
import '../../presentation/screens/legal/privacy_policy_screen.dart';
import '../../presentation/screens/legal/terms_conditions_screen.dart';
import '../../presentation/screens/profile/theme_selection_screen.dart';
import '../../presentation/screens/error/error_screen.dart';
import '../../presentation/screens/documents/document_detail_screen.dart';
import '../../presentation/screens/doctors/doctor_detail_screen.dart';
import '../../presentation/screens/achievements/achievements_screen.dart';
import '../../presentation/screens/season_pass/season_pass_screen.dart';



// Domain
import '../../domain/entities/appointment.dart';
import '../../domain/entities/medicine.dart';

// Core
import '../../presentation/widgets/app_lock_gate.dart';
import '../constants/app_routes.dart';
import '../types/runtime_types.dart';

/// Centralized Scale-Proof Router Configuration
class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth & onboarding state for reactive redirects
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);
  final lockState = ref.watch(appLockStateProvider);
  final isLockEnabled = ref.watch(appLockEnabledProvider);

  return GoRouter(
    navigatorKey: AppRouter.navigatorKey,
    initialLocation: AppRoutes.home,
    
    // Global App Brain: Logic Control Center
    redirect: (context, state) {
      final isGoingToLock = state.matchedLocation == AppRoutes.lock;
      final isGoingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final isGoingToProfileCreate = state.matchedLocation == AppRoutes.profileCreate;

      if (lockState == AppLockState.unknown && !isGoingToLock) {
        return AppRoutes.lock;
      }

      // 1. Force Lock Screen if app lock is enabled and session is locked
      if (isLockEnabled && lockState != AppLockState.unlocked) {
        if (!isGoingToLock) return AppRoutes.lock;
        return null;
      }
      if (isGoingToLock && (!isLockEnabled || lockState == AppLockState.unlocked)) {
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
        final isGoingToLegal = state.matchedLocation.contains('terms') || 
                               state.matchedLocation.contains('privacy') || 
                               state.matchedLocation.contains('disclaimer');
        if (!isGoingToLegal && !isGoingToProfileCreate) {
          return AppRoutes.profileCreate; // Force them back to profile create to accept
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
    errorBuilder: (context, state) => ErrorScreen(message: state.error?.message),

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
                    path: AppRoutes.home, // Maps to Dashboard via HomeScreen logic or redirection
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
                    builder: (context, state) => const DocumentsScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: 'documentDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id'];
                          if (id == null || id.isEmpty) return const ErrorScreen(message: 'Invalid Document ID');
                          return DocumentDetailScreen(id: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/explore-placeholder',
                    builder: (context, state) => const SizedBox.shrink(),
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
                        builder: (context, state) => AppointmentAddScreen(appointment: state.extra as Appointment?),
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
                        builder: (context, state) => ProfileEditScreen(initialData: state.extra as ProfileData?),
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
                builder: (context, state) => MedicineAddScreen(medicine: state.extra as Medicine?),
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
                  if (id == null) return const ErrorScreen(message: 'Doctor not found');
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
            builder: (context, state) => const PersonalInfoScreen(),
          ),
          GoRoute(
            path: AppRoutes.medicalInfo,
            name: 'medicalInfo',
            builder: (context, state) => const MedicalInfoScreen(),
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
