import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/document.dart';
import '../../../../shared/providers/document_providers.dart';

final vaultControllerProvider =
    AsyncNotifierProvider<VaultController, List<Document>>(
      VaultController.new,
    );

class VaultController extends AsyncNotifier<List<Document>> {
  @override
  Future<List<Document>> build() async {
    return ref.watch(documentListProvider.future);
  }

  Future<void> refresh() async {
    await ref.read(documentListProvider.notifier).refresh();
  }

  Future<void> deleteDocument(String id) async {
    await ref.read(documentListProvider.notifier).deleteDocument(id);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      ref.invalidateSelf();
      return;
    }
    
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(documentListProvider.notifier).searchDocuments(query);
    });
  }
}
