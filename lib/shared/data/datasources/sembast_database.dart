import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import '../services/encryption_service.dart';
import 'database_codec.dart';
import 'dart:io';

class DatabaseRecoveryRequiredException implements Exception {
  final Object cause;
  final StackTrace? stackTrace;

  DatabaseRecoveryRequiredException(this.cause, [this.stackTrace]);

  @override
  String toString() => 'DatabaseRecoveryRequiredException: $cause';
}

class SembastDatabase {
  Database? _db;
  Database get db {
    if (_db == null) throw StateError('SembastDatabase not initialized. Call init() first.');
    return _db!;
  }

  static final SembastDatabase _instance = SembastDatabase._internal();

  factory SembastDatabase() {
    return _instance;
  }

  SembastDatabase._internal();

  Future<void> init(EncryptionService encryptionService) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, "vitacase.db");

    final masterKey = await encryptionService.getMasterKey();
    final codec = DatabaseEncryptionCodec(masterKey);

    final databaseFactory = databaseFactoryIo;

    try {
      _db = await databaseFactory.openDatabase(dbPath, codec: codec);
    } catch (e, stackTrace) {
      throw DatabaseRecoveryRequiredException(e, stackTrace);
    }
  }

  Future<void> close() async {
    await db.close();
  }

  Future<void> deleteDatabaseFile() async {
    try {
      await db.close();
    } catch (_) {}

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, "vitacase.db");
    final file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
