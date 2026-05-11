import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/medical_record_repository_impl.dart';
import '../domain/entities/medical_record.dart';
import '../domain/repositories/medical_record_repository.dart';

final medicalRecordRepositoryProvider = Provider<MedicalRecordRepository>((
  ref,
) {
  return MedicalRecordRepositoryImpl();
});

final medicalRecordListProvider =
    AsyncNotifierProvider<MedicalRecordListNotifier, List<MedicalRecord>>(
      MedicalRecordListNotifier.new,
    );

class MedicalRecordListNotifier extends AsyncNotifier<List<MedicalRecord>> {
  @override
  Future<List<MedicalRecord>> build() async {
    final repo = ref.read(medicalRecordRepositoryProvider);
    return repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(medicalRecordRepositoryProvider).getAll(),
    );
  }

  Future<void> addRecord(MedicalRecord record) async {
    final repo = ref.read(medicalRecordRepositoryProvider);
    await repo.save(record);
    await refresh();
  }

  Future<void> deleteRecord(String id) async {
    final repo = ref.read(medicalRecordRepositoryProvider);
    await repo.delete(id);
    await refresh();
  }
}
