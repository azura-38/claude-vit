import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import '../services/encryption_service.dart';
import 'database_codec.dart';
import 'dart:io';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseRecoveryRequiredException implements Exception {
  final Object cause;
  final StackTrace? stackTrace;

  DatabaseRecoveryRequiredException(this.cause, [this.stackTrace]);

  @override
  String toString() => 'DatabaseRecoveryRequiredException: $cause';
}

class SembastDatabase {
  Database? _db;

  /// Completer that resolves once [init] finishes successfully.
  final Completer<Database> _completer = Completer<Database>();

  /// Synchronous getter – only safe to call after [init] has completed.
  Database get db {
    if (_db == null) {
      throw StateError('SembastDatabase not initialized. Call init() first.');
    }
    return _db!;
  }

  /// Async getter – safe to call at any time. Suspends until [init] finishes.
  Future<Database> get ready => _completer.future;

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
      if (!_completer.isCompleted) _completer.complete(_db!);
    } catch (e, stackTrace) {
      // Capture exception to Sentry
      try {
        await Sentry.captureException(e, stackTrace: stackTrace);
      } catch (_) {}

      // Set recovery trigger flag in SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('db_corruption_recovery_triggered', true);
      } catch (_) {}

      // Self-healing database recovery block
      try {
        final dbFile = File(dbPath);
        if (await dbFile.exists()) {
          // Keep a backup before deleting
          try {
            await dbFile.copy('$dbPath.bak');
          } catch (_) {}
          await dbFile.delete();
        }
        
        final userDocsDir = Directory(p.join(docsDir.path, "documents"));
        if (await userDocsDir.exists()) {
          await userDocsDir.delete(recursive: true);
        }
      } catch (_) {}

      // Retry opening fresh database
      try {
        _db = await databaseFactory.openDatabase(dbPath, codec: codec);
        if (!_completer.isCompleted) _completer.complete(_db!);
      } catch (retryError) {
        if (!_completer.isCompleted) _completer.completeError(retryError, stackTrace);
        throw DatabaseRecoveryRequiredException(retryError, stackTrace);
      }
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
