import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../datasources/sembast_database.dart';

class WipeService {
  static const _storage = FlutterSecureStorage();

  static Future<void> fullWipe() async {
    // 1. Close and Delete Database
    await SembastDatabase().deleteDatabaseFile();

    // 2. Clear Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 3. Clear Secure Storage (Master Key, etc.)
    await _storage.deleteAll();

    // 4. Delete Uploaded Documents
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final docsDir = Directory(p.join(appDir.path, 'documents'));
      if (await docsDir.exists()) {
        await docsDir.delete(recursive: true);
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
  }
}
