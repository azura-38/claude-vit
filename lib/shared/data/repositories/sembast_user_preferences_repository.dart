import 'package:sembast/sembast.dart';
import 'package:vitacase/shared/domain/repositories/user_preferences_repository.dart';
import 'package:vitacase/shared/domain/entities/user_preferences.dart';
import 'package:vitacase/shared/data/models/user_preferences_model.dart';
import 'package:vitacase/shared/data/datasources/sembast_database.dart';

class SembastUserPreferencesRepository implements UserPreferencesRepository {
  final SembastDatabase _database;
  final _store = stringMapStoreFactory.store('preferences');
  static const _key = 'user_preferences_v2';

  SembastUserPreferencesRepository(this._database);

  @override
  Future<UserPreferences> getPreferences() async {
    final db = await _database.ready;
    final map = await _store.record(_key).get(db);
    if (map == null) return const UserPreferences();
    return UserPreferencesModel.fromMap(map);
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    final db = await _database.ready;
    await _store.record(_key).put(db, UserPreferencesModel.toMap(preferences));
  }
}
