import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/backup_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../data/services/analytics_service.dart';

final backupServiceProvider = Provider((ref) => BackupService());

final backupActionProvider = AsyncNotifierProvider<BackupActionNotifier, void>(
  BackupActionNotifier.new,
);

class BackupActionNotifier extends AsyncNotifier<void> {
  @override
  void build() {
    return;
  }

  Future<void> exportBackup() async {
    state = const AsyncLoading();
    try {
      final service = ref.read(backupServiceProvider);
      final zipPath = await service.exportBackup();

      // Prompt user to save the file
      final fileName = BackupService.backupFileName.substring(
        1,
      ); // vitacase_backup.zip
      final result = await FilePicker.saveFile(
        dialogTitle: 'Yedeği Kaydet',
        fileName: fileName,
        allowedExtensions: ['zip'],
        type: FileType.custom,
      );

      if (result != null) {
        final zipFile = File(zipPath);
        final bytes = await zipFile.readAsBytes();

        final targetFile = File(result);
        await targetFile.writeAsBytes(bytes);

        // Cleanup temp file
        await zipFile.delete();
        AnalyticsService.log(AnalyticsService.backupCreated);
        AnalyticsService.log(AnalyticsService.backupExportSuccess);

        state = const AsyncData(null);
      } else {
        state = const AsyncData(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> importBackup() async {
    state = const AsyncLoading();
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final service = ref.read(backupServiceProvider);
        await service.importBackup(result.files.single.path!);
        AnalyticsService.log(AnalyticsService.backupImportSuccess);
        state = const AsyncData(null);
      } else {
        state = const AsyncData(null);
      }
    } catch (e, st) {
      AnalyticsService.log(AnalyticsService.backupImportFail, {
        'reason': e.runtimeType.toString(),
      });
      state = AsyncValue.error(e, st);
    }
  }
}
