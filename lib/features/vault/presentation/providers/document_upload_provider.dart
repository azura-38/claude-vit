import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => "Medical");
final selectedTypeProvider = StateProvider<String>((ref) => "Tax Return");

enum UploadState { idle, reading, compressing, encrypting, success }

final uploadStateProvider = StateProvider<UploadState>((ref) => UploadState.idle);
