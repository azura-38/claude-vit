import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/sembast_database.dart';
import 'notification_engine.dart';
import 'encryption_service.dart';
import 'backup_service.dart';

class WipeService {
  static const _storage = FlutterSecureStorage();

  static Future<void> fullWipe() async {
    // 1. Close and Delete Database
    await SembastDatabase().deleteDatabaseFile();

    // 2. Clear Notifications
    try {
      await NotificationEngine.cancelAll();
    } catch (_) {}

    // 2. Clear Shared Preferences (preserve app settings)
    final prefs = await SharedPreferences.getInstance();
    final keysToPreserve = {
      'onboarding_completed',
      'theme_type',
      'app_locale',
      'app_lock_enabled',
      'biometric_enabled',
      'flutter.app_lock_enabled',
      'flutter.biometric_enabled',
    };
    final allKeys = prefs.getKeys().toList();
    for (final key in allKeys) {
      if (!keysToPreserve.contains(key)) {
        await prefs.remove(key);
      }
    }

    // 3. Clear Secure Storage (Master Key, etc.)
    await _storage.deleteAll();
    EncryptionService.clearCache();

    // 4. Delete Uploaded Documents & Recovery Artifacts
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final docsDir = Directory(p.join(appDir.path, 'documents'));
      if (await docsDir.exists()) {
        await docsDir.delete(recursive: true);
      }
      // Also delete any recovery/backup artifacts in app documents dir
      final entities = appDir.listSync();
      for (final entity in entities) {
        if (entity is File) {
          final filename = p.basename(entity.path);
          if (filename.endsWith('.bak') ||
              filename.endsWith('.old') ||
              filename.endsWith('.tmp') ||
              filename == BackupService.backupFileName) {
            try {
              await entity.delete();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}

    // 5. Clean Temp Files
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final entities = tempDir.listSync();
        for (final entity in entities) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}

    // 6. Ensure SembastDatabase instance is reset cleanly for next initialization
    SembastDatabase().reset();
  }
}
