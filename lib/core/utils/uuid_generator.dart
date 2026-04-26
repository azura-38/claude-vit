import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a UUID v4 string.
String generateUuid() => _uuid.v4();

/// Generates a document-style ID matching the React app's pattern.
String generateDocId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = _uuid.v4().substring(0, 9);
  return 'doc_${timestamp}_$random';
}
