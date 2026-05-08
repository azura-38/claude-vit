import '../entities/document.dart';

abstract class DocumentRepository {
  Future<void> save(Document document);
  Future<void> update(Document document);
  Future<Document?> getById(String id);
  Future<List<Document>> getAll();
  Future<void> delete(String id);
  Future<List<Document>> search(String queryStr);
  Future<List<Document>> getByCategory(String tagId);
}
