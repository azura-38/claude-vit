import 'package:vitacase/shared/domain/entities/user_preferences.dart';

abstract class UserPreferencesRepository {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences preferences);
}
