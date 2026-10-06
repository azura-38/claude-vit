import 'package:sembast/sembast.dart';
import 'package:vitacase/shared/domain/entities/document.dart';
import 'package:vitacase/shared/domain/repositories/document_repository.dart';
import '../datasources/sembast_database.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final _store = stringMapStoreFactory.store('documents');

  Future<Database> get _db async => SembastDatabase().ready;

  @override
  Future<void> save(Document document) async {
    final db = await _db;
    final model = DocumentModel.fromEntity(document);
    await _store.record(document.id).put(db, model.toMap());
  }

  @override
  Future<void> update(Document document) async {
    final db = await _db;
    final model = DocumentModel.fromEntity(document);
    await _store.record(document.id).put(db, model.toMap());
  }

  @override
  Future<Document?> getById(String id) async {
    final db = await _db;
    final record = await _store.record(id).get(db);
    if (record == null) return null;
    return DocumentModel.fromMap(record).toEntity();
  }

  @override
  Future<List<Document>> getAll() async {
    final db = await _db;
    final records = await _store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('createdAt', false)]),
    );
    return records
        .map((r) => DocumentModel.fromMap(r.value).toEntity())
        .toList();
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await _store.record(id).delete(db);
  }

  @override
  Future<List<Document>> search(String queryStr) async {
    final db = await _db;
    final q = queryStr.toLowerCase();
    final records = await _store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('createdAt', false)]),
    );
    final result = <Document>[];
    for (var r in records) {
      final map = r.value;
      final fileName = (map['fileName'] as String).toLowerCase();
      final hospitalName =
          (map['hospitalName'] as String?)?.toLowerCase() ?? '';
      final tagLabel = (map['tagLabel'] as String?)?.toLowerCase() ?? '';
      final tags = (map['tags'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          <String>[];
      if (fileName.contains(q) ||
          hospitalName.contains(q) ||
          tagLabel.contains(q) ||
          tags.any((t) => t.contains(q))) {
        result.add(DocumentModel.fromMap(map).toEntity());
      }
    }
    return result;
  }

  @override
  Future<List<Document>> getByCategory(String tagId) async {
    final db = await _db;
    final records = await _store.find(
      db,
      finder: Finder(
        filter: Filter.equals('tagId', tagId),
        sortOrders: [SortOrder('createdAt', false)],
      ),
    );
    return records
        .map((r) => DocumentModel.fromMap(r.value).toEntity())
        .toList();
  }
}
