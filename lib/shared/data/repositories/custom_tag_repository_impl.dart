import 'package:sembast/sembast.dart';
import '../../domain/enums/document_tag.dart';
import '../../domain/repositories/custom_tag_repository.dart';
import '../datasources/sembast_database.dart';

class CustomTagException implements Exception {
  final String messageKey;
  const CustomTagException(this.messageKey);

  @override
  String toString() => messageKey;
}

class CustomTagValidator {
  static const int maxTagLength = 30;

  static String validateAndNormalize(String rawInput, Iterable<String> existingTags) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) {
      throw const CustomTagException('tag_name_empty');
    }
    if (trimmed.length > maxTagLength) {
      throw const CustomTagException('tag_too_long');
    }
    final lower = trimmed.toLowerCase();
    final duplicate = existingTags.any((t) => t.trim().toLowerCase() == lower);
    if (duplicate) {
      throw const CustomTagException('tag_already_exists');
    }
    return trimmed;
  }
}

class CustomTagRepositoryImpl implements CustomTagRepository {
  CustomTagRepositoryImpl({Database? database}) : _database = database;

  final Database? _database;
  final _store = stringMapStoreFactory.store('custom_tags');

  Future<Database> get _db async => _database ?? await SembastDatabase().ready;

  @override
  Future<List<String>> getAllCustomTags() async {
    final db = await _db;
    final records = await _store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('name', true)]),
    );
    return records.map((r) => r.value['name'] as String).toList();
  }

  @override
  Future<void> addCustomTag(String tag) async {
    final existing = await getAllCustomTags();
    final quickTags = DocumentTag.values.expand((t) => [t.id, t.label]).toSet();
    final normalized = CustomTagValidator.validateAndNormalize(tag, [...existing, ...quickTags]);
    final db = await _db;
    final key = normalized.toLowerCase();
    await _store.record(key).put(db, {
      'name': normalized,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteCustomTag(String tag) async {
    final db = await _db;
    final key = tag.trim().toLowerCase();
    await _store.record(key).delete(db);
  }
}
