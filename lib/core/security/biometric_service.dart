import '../../shared/data/services/app_lock_service.dart';

class BiometricService {
  BiometricService(this._appLockService);

  final AppLockService _appLockService;

  Future<bool> get isAvailable => _appLockService.isAvailable();

  Future<bool> authenticate({String? reason}) {
    return _appLockService.authenticate(reason: reason);
  }
}
