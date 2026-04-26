import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/doctor_repository_impl.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/repositories/doctor_repository.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepositoryImpl();
});

final doctorListProvider =
    AsyncNotifierProvider<DoctorListNotifier, List<Doctor>>(
  DoctorListNotifier.new,
);

class DoctorListNotifier extends AsyncNotifier<List<Doctor>> {
  @override
  Future<List<Doctor>> build() async {
    final repo = ref.read(doctorRepositoryProvider);
    return repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(doctorRepositoryProvider).getAll());
  }

  Future<void> addDoctor(Doctor doctor) async {
    final repo = ref.read(doctorRepositoryProvider);
    await repo.save(doctor);
    await refresh();
  }

  Future<void> deleteDoctor(String id) async {
    final repo = ref.read(doctorRepositoryProvider);
    await repo.delete(id);
    await refresh();
  }
}
