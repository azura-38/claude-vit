import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/custom_tag_repository_impl.dart';
import '../domain/enums/document_tag.dart';
import '../domain/repositories/custom_tag_repository.dart';
import 'document_providers.dart';

final customTagRepositoryProvider = Provider<CustomTagRepository>((ref) {
  return CustomTagRepositoryImpl();
});

final customTagsProvider =
    AsyncNotifierProvider<CustomTagsNotifier, List<String>>(
  CustomTagsNotifier.new,
);

class CustomTagsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final repo = ref.read(customTagRepositoryProvider);
    return repo.getAllCustomTags();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(customTagRepositoryProvider).getAllCustomTags(),
    );
  }

  Future<String> createCustomTag(String rawName) async {
    final currentTags = state.value ?? [];
    final quickTagIds = DocumentTag.values.map((t) => t.id).toList();
    final quickTagLabels = DocumentTag.values.map((t) => t.key).toList();

    // Check against existing custom tags and quick tags
    final normalized = CustomTagValidator.validateAndNormalize(
      rawName,
      [...currentTags, ...quickTagIds, ...quickTagLabels],
    );

    final repo = ref.read(customTagRepositoryProvider);
    await repo.addCustomTag(normalized);

    final updated = [...currentTags, normalized]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    state = AsyncData(updated);
    return normalized;
  }

  Future<void> removeCustomTag(String tag) async {
    final repo = ref.read(customTagRepositoryProvider);
    await repo.deleteCustomTag(tag);
    if (state.hasValue) {
      final updated = state.value!
          .where((t) => t.toLowerCase() != tag.toLowerCase())
          .toList();
      state = AsyncData(updated);
    }
  }
}

/// Provider that aggregates all unique tags present across documents and saved custom tags
final allKnownTagsProvider = Provider<List<String>>((ref) {
  final customTags = ref.watch(customTagsProvider).value ?? [];
  final docs = ref.watch(documentListProvider).value ?? [];

  final set = <String>{};
  for (final tag in customTags) {
    if (tag.trim().isNotEmpty) set.add(tag.trim());
  }
  for (final doc in docs) {
    for (final tag in doc.tags) {
      if (tag.trim().isNotEmpty) set.add(tag.trim());
    }
    if (doc.tagId != null && doc.tagId!.trim().isNotEmpty) {
      set.add(doc.tagId!.trim());
    }
  }

  final list = set.toList();
  list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return list;
});
