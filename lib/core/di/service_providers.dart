import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/services/notification_service.dart';
import '../../shared/data/services/encryption_service.dart';
import '../../shared/data/datasources/sembast_database.dart';
import '../../features/gamification/data/services/combo_engine.dart';
import '../../shared/data/services/app_lock_service.dart';
import '../../shared/providers/shared_prefs_provider.dart';
import '../../shared/data/services/ad_service.dart';

/// Core Service Providers for Dependency Injection (DI)
/// Migrating away from direct Singleton access to improve testability and architecture score.

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ref.watch(sharedPreferencesProvider)),
);

final encryptionServiceProvider = Provider<EncryptionService>(
  (ref) => EncryptionService(),
);

final sembastDatabaseProvider = Provider<SembastDatabase>(
  (ref) => SembastDatabase(),
);

final appLockServiceProvider = Provider<AppLockService>(
  (ref) => AppLockService(),
);

final comboEngineProvider = Provider<ComboEngine>((ref) => ComboEngine());

final adServiceProvider = Provider<AdService>((ref) => AdService());
