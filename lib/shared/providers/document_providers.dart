import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/repository_providers.dart';
import '../../core/utils/uuid_generator.dart';
import '../../features/gamification/presentation/providers/achievement_providers.dart';
import '../data/datasources/file_storage_service.dart';
import '../data/services/ad_controller.dart';
import '../data/services/analytics_service.dart';
import '../data/services/usage_limit_service.dart';
import '../domain/entities/document.dart';
import '../domain/enums/document_category.dart';
import 'daily_mission_providers.dart';
import 'season_providers.dart';

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

  Future<Document> addDocument({
    required Object file,
    required String fileName,
    required DocumentFileType fileType,
    required DocumentCategory category,
    List<String> tags = const [],
    String? hospitalName,
    String? doctorName,
    String? documentDate,
    String? tagId,
    String? tagLabel,
    String? note,
  }) async {
    final limit = await ref.read(usageLimitServiceProvider).consumeCreate();
    if (!limit.allowed) {
      throw UsageLimitExceededException(limit.limit);
    }

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
      tags: tags,
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
      await ref.read(dailyMissionProvider.notifier).track('doc_daily');
      await _trackDocumentAchievements();
      await ref.read(seasonProvider.notifier).addXP(10);
      AnalyticsService.log(AnalyticsService.documentAdded);
    } catch (e) {
      await refresh();
      rethrow;
    }

    return document;
  }

  Future<void> _trackDocumentAchievements() async {
    final count = state.valueOrNull?.length ?? (await ref.read(documentRepositoryProvider).getAll()).length;
    final achievement = ref.read(achievementProvider.notifier);
    for (final id in const ['doc_1', 'doc_5', 'doc_10', 'doc_25', 'doc_50', 'doc_100', 'doc_250', 'doc_500']) {
      await achievement.track(id, setAbsolute: count);
    }
    // Legacy key kept for backward-compatibility with existing users
    await achievement.track('first_upload', setAbsolute: count > 0 ? 1 : 0);
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
