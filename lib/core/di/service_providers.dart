import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/services/notification_engine.dart';
import '../../shared/data/services/encryption_service.dart';
import '../../shared/data/datasources/sembast_database.dart';
import '../../shared/data/services/app_lock_service.dart';
import '../../shared/data/services/ad_service.dart';

/// Core Service Providers for Dependency Injection (DI)

final notificationEngineProvider = Provider<NotificationEngine>(
  (ref) => NotificationEngine(),
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

final adServiceProvider = Provider<AdService>((ref) => AdService());
