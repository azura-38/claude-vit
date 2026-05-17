import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/file_storage_service.dart';
import '../../core/di/repository_providers.dart';
import '../domain/entities/document.dart';
import '../domain/enums/document_category.dart';
import '../../core/utils/uuid_generator.dart';
import '../../features/gamification/presentation/providers/achievement_providers.dart';
import 'daily_mission_providers.dart';
import 'season_providers.dart';
import '../data/services/analytics_service.dart';
import '../data/services/ad_controller.dart';

final fileStorageServiceProvider = Provider<FileStorageService>((ref) {
  return FileStorageService();
});

final documentListProvider = AsyncNotifierProvider<DocumentListNotifier, List<Document>>(
  DocumentListNotifier.new,
);

class DocumentListNotifier extends AsyncNotifier<List<Document>> {
  @override
  Future<List<Document>> build() async {
    final repo = ref.read(documentRepositoryProvider);
    return repo.getAll();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(documentRepositoryProvider).getAll());
  }

  Future<Document> uploadDocument({
    required Object file,
    required String fileName,
    required DocumentFileType fileType,
    required DocumentCategory category,
    String? hospitalName,
    String? doctorName,
    String? documentDate,
    String? tagId,
    String? tagLabel,
    String? note,
  }) async {
    final storage = ref.read(fileStorageServiceProvider);
    final repo = ref.read(documentRepositoryProvider);

    final docId = generateDocId();
    final extension = fileName.split('.').last;
    final destFileName = '$docId.$extension';

    final localPath = await storage.copyFileToAppDir(file, destFileName);

    final document = Document(
      id: docId,
      fileName: fileName,
      fileType: fileType,
      localPath: localPath,
      category: category,
      hospitalName: hospitalName,
      doctorName: doctorName,
      documentDate: documentDate,
      tagId: tagId,
      tagLabel: tagLabel,
      note: note,
      createdAt: DateTime.now(),
    );

    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData([document, ...currentList]);
    }

    try {
      await repo.save(document);
      ref.read(adControllerProvider).onActionTriggered();
      ref.read(achievementProvider.notifier).track('doc_added', value: 1);
      ref.read(dailyMissionProvider.notifier).track('doc_daily');
      ref.read(seasonProvider.notifier).addXP(10);
      AnalyticsService.log(AnalyticsService.documentAdded);
    } catch (e) {
      await refresh();
      rethrow;
    }

    return document;
  }

  Future<void> updateDocument(Document document) async {
    final repo = ref.read(documentRepositoryProvider);

    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData(currentList.map((d) => d.id == document.id ? document : d).toList());
    }

    try {
      await repo.update(document);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> deleteDocument(String id) async {
    final storage = ref.read(fileStorageServiceProvider);
    final repo = ref.read(documentRepositoryProvider);

    final doc = await repo.getById(id);
    if (doc != null) {
      if (state.hasValue) {
        state = AsyncData(state.value!.where((d) => d.id != id).toList());
      }

      try {
        await storage.deleteFile(doc.localPath);
        await repo.delete(id);
        AnalyticsService.log(AnalyticsService.documentDeleted);
      } catch (e) {
        await refresh();
        rethrow;
      }
    }
  }

  Future<List<Document>> searchDocuments(String query) async {
    final repo = ref.read(documentRepositoryProvider);
    return repo.search(query);
  }
}
