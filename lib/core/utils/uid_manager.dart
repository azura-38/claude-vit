import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class UIDManager {
  static const String _uidKey = 'app_user_uid';
  static const _storage = FlutterSecureStorage();

  static Future<String> getUID() async {
    // 1. Try to get from Secure Storage (High Security)
    String? uid = await _storage.read(key: _uidKey);
    
    if (uid != null) return uid;

    // 2. Migration Fallback: Try to get from old SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString(_uidKey);

    if (uid != null) {
      // Move to Secure Storage and delete from Prefs
      await _storage.write(key: _uidKey, value: uid);
      await prefs.remove(_uidKey);
      return uid;
    }

    // 3. New User: Create and store securely
    uid = const Uuid().v4();
    await _storage.write(key: _uidKey, value: uid);
    return uid;
  }
}
