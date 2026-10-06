/// Central legal version. Bump this whenever legal documents change.
/// Format: appVersion-yyyy-mm
class LegalVersion {
  LegalVersion._();

  /// Current legal document version.
  /// Changing this value will trigger the legal update consent screen
  /// for all existing users whose stored version doesn't match.
  static const String current = '1.1.7-2026-10';
}
