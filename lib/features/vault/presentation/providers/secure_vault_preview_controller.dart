import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/document.dart';
import '../../../../shared/domain/enums/document_category.dart';
import '../../../../shared/providers/document_providers.dart';

class SecureVaultPreviewData {
  final String fileName;
  final DocumentFileType fileType;
  final bool isImage;
  final Uint8List? imageBytes;
  final bool isDecrypted;
  final String? errorMessage;

  const SecureVaultPreviewData({
    required this.fileName,
    required this.fileType,
    required this.isImage,
    this.imageBytes,
    this.isDecrypted = false,
    this.errorMessage,
  });
}

final secureVaultPreviewProvider =
    FutureProvider.autoDispose.family<SecureVaultPreviewData, Document>((ref, document) async {
  final storage = ref.watch(fileStorageServiceProvider);

  if (document.fileType == DocumentFileType.image) {
    try {
      final bytes = await storage.readDecryptedBytes(document.localPath);
      return SecureVaultPreviewData(
        fileName: document.fileName,
        fileType: document.fileType,
        isImage: true,
        imageBytes: bytes,
        isDecrypted: true,
      );
    } catch (e) {
      return SecureVaultPreviewData(
        fileName: document.fileName,
        fileType: document.fileType,
        isImage: true,
        isDecrypted: false,
        errorMessage: e.toString(),
      );
    }
  }

  // PDF or non-image document
  return SecureVaultPreviewData(
    fileName: document.fileName,
    fileType: document.fileType,
    isImage: false,
    isDecrypted: true,
  );
});
