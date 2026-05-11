import 'package:local_auth/local_auth.dart';

class AppLockService {
  final _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      return isSupported || canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({String? reason}) async {
    try {
      if (!await isAvailable()) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: reason ?? 'Authenticate to unlock VitaCase',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
