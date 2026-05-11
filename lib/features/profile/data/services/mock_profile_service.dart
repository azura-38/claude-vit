import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockProfileService {
  Future<void> createProfile(dynamic data) async {}
  Future<void> saveProfile(dynamic data) async {}
  Future<void> updateProfilePhoto(String path) async {}
}

final profileServiceProvider = Provider<MockProfileService>(
  (ref) => MockProfileService(),
);
