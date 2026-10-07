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
  Completer<Database> _completer = Completer<Database>();

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

  /// Resets internal instance state (for wipe and isolated testing).
  void reset() {
    _db = null;
    if (_completer.isCompleted) {
      _completer = Completer<Database>();
    }
  }

  Future<void> init(EncryptionService encryptionService) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, "vitacase.db");
    final databaseFactory = databaseFactoryIo;

    try {
      final masterKey = await encryptionService.getMasterKey();
      final codec = DatabaseEncryptionCodec(masterKey);
      _db = await databaseFactory.openDatabase(dbPath, codec: codec);
      if (!_completer.isCompleted) _completer.complete(_db!);
    } catch (e, stackTrace) {
      // Capture exception to Sentry
      try {
        await Sentry.captureException(e, stackTrace: stackTrace);
      } catch (_) {}

      // Record database open error state in SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('db_corruption_recovery_triggered', true);
      } catch (_) {}

      // CRITICAL PRE-RELEASE FIX:
      // Never delete user database or documents/ folder automatically on open failure.
      // Doing so risks irreversible data loss if keys fail temporarily or codec misbehaves.
      // Propagate error to caller safely.
      if (!_completer.isCompleted) {
        _completer.completeError(e, stackTrace);
        _completer.future.ignore();
      }
      throw DatabaseRecoveryRequiredException(e, stackTrace);
    }
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    if (_completer.isCompleted) {
      _completer = Completer<Database>();
    }
  }

  Future<void> deleteDatabaseFile() async {
    try {
      await _db?.close();
    } catch (_) {}
    _db = null;
    _completer = Completer<Database>();

    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, "vitacase.db");
    final file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
    }

    // Also clean up any recovery backup copy when the user explicitly triggers a wipe
    final bakFile = File('$dbPath.bak');
    if (await bakFile.exists()) {
      await bakFile.delete();
    }
  }
}
