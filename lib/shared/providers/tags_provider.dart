import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_prefs_provider.dart';

const List<String> defaultPresetTags = [
  'Cardiologist 2025',
  'Annual Physical',
  'Blood Test',
  'Prescription',
  'Dentist',
  'Family',
  'Important',
];

final tagsProvider = StateNotifierProvider<TagsNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TagsNotifier(prefs);
});

class TagsNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  static const _key = 'user_custom_tags';

  TagsNotifier(this._prefs) : super([]) {
    _load();
  }

  void _load() {
    final custom = _prefs.getStringList(_key) ?? [];
    final set = <String>{...defaultPresetTags, ...custom};
    state = set.toList();
  }

  Future<void> addCustomTag(String tag) async {
    final trimmed = tag.trim();
    if (trimmed.isEmpty || state.any((t) => t.toLowerCase() == trimmed.toLowerCase())) return;
    final updated = [...state, trimmed];
    state = updated;
    final customOnly = updated.where((t) => !defaultPresetTags.contains(t)).toList();
    await _prefs.setStringList(_key, customOnly);
  }
}
