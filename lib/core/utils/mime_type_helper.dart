class MimeTypeHelper {
  static String getMimeType(String fileName) {
    final lowerName = fileName.toLowerCase();
    
    if (lowerName.endsWith('.pdf')) {
      return 'application/pdf';
    } else if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (lowerName.endsWith('.png')) {
      return 'image/png';
    } else if (lowerName.endsWith('.heic')) {
      return 'image/heic';
    } else if (lowerName.endsWith('.doc')) {
      return 'application/msword';
    } else if (lowerName.endsWith('.docx')) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    } else if (lowerName.endsWith('.xls')) {
      return 'application/vnd.ms-excel';
    } else if (lowerName.endsWith('.xlsx')) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    
    return 'application/octet-stream';
  }
}
