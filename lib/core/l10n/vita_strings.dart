import 'package:flutter/widgets.dart';

class VitaStrings {
  VitaStrings._(this.languageCode);

  final String languageCode;

  static VitaStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return VitaStrings._(code == 'tr' ? 'tr' : 'en');
  }

  String _pick(String en, String tr) => languageCode == 'tr' ? tr : en;

  String get addDocument => _pick('Add Document', 'Belge Ekle');
  String get category => _pick('Category', 'Kategori');
  String get subcategory => _pick('Subcategory', 'Alt Kategori');
  String get hospitalInstitution => _pick('Institution / Source', 'Kurum / Kaynak');
  String get doctorContact => _pick('Person / Contact', 'Kişi / İletişim');
  String get notes => _pick('Notes', 'Notlar');
  String get choosePdfOrImage => _pick('Choose PDF or Image', 'PDF veya Görsel Seç');
  String get encryptedLocalFileInfo => _pick(
        'Your file will be encrypted and stored locally on this device.',
        'Dosyanız şifrelenir ve bu cihazda yerel olarak saklanır.',
      );
  String get webUploadInfo => _pick(
        'File vault upload is available on Android/iOS builds.',
        'Dosya kasasına yükleme Android/iOS sürümlerinde kullanılabilir.',
      );
  String get webPreviewNoUpload => _pick(
        'Web preview does not store encrypted files. Use Android/iOS for vault upload.',
        'Web önizleme şifreli dosya saklamaz. Kasa yüklemesi için Android/iOS kullanın.',
      );
  String get chooseFileFirst => _pick(
        'Please choose a PDF or image first.',
        'Lütfen önce PDF veya görsel seçin.',
      );
  String get documentSaved => _pick('Document saved securely.', 'Belge güvenli şekilde kaydedildi.');
  String saveDocumentFailed(Object error) => _pick(
        'Could not save document: $error',
        'Belge kaydedilemedi: $error',
      );
  String get saveSecurely => _pick('Save Securely', 'Güvenli Kaydet');
  String get saving => _pick('Saving...', 'Kaydediliyor...');
  String get localOrganizerDisclaimer => _pick(
        'VitaCase is a local document organizer. It does not diagnose, analyze, or provide medical advice.',
        'VitaCase yerel bir belge düzenleyicidir. Tanı koymaz, analiz yapmaz veya tıbbi tavsiye vermez.',
      );

  String get termsAndLegalAgreement => _pick(
        'I agree to the Privacy Policy, Terms & Conditions, and Legal Disclaimer.',
        'Gizlilik Politikası, Kullanım Koşulları ve Yasal Uyarı metinlerini kabul ediyorum.',
      );
  String get privacyPolicyShort => _pick('Privacy Policy', 'Gizlilik Politikası');
  String get termsShort => _pick('Terms', 'Koşullar');
  String get disclaimerShort => _pick('Disclaimer', 'Yasal Uyarı');

  String get freeThemes => _pick('Free themes', 'Ücretsiz temalar');
  String get rewardThemes => _pick('Reward themes', 'Reklamla Açılan Temalar');
  String get rewardThemesInfo => _pick(
        'Watch one rewarded ad to unlock these themes for 3 days. Every extra ad adds +1 day.',
        'Bu temaları 3 gün açmak için bir ödüllü reklam izleyin. Her ek reklam +1 gün kazandırır.',
      );
  String get watchAdToUnlock => _pick('Watch ad to unlock', 'Açmak için reklam izle');
  String get tapToPreview => _pick('Tap to preview', 'Önizlemek için dokun');
  String get unlock => _pick('Unlock', 'Kilidi Aç');
  String get apply => _pick('Apply', 'Uygula');
  String get active => _pick('Active', 'Aktif');
  String get addOneDay => _pick('Add +1 day', '+1 gün ekle');
  String get oneDayAdded => _pick('+1 day added.', '+1 gün eklendi.');
  String get adUnavailable => _pick('Ad unavailable.', 'Reklam kullanılamıyor.');
  String get adUnavailableTryLater => _pick(
        'Ad unavailable. Please try again later.',
        'Reklam kullanılamıyor. Lütfen daha sonra tekrar deneyin.',
      );
  String get themeUnlocked => _pick(
        'Theme unlocked. Each extra ad adds +1 day.',
        'Tema açıldı. Her ek reklam +1 gün kazandırır.',
      );
  String rewardThemesActive(int days) => _pick(
        'Reward themes active for $days day(s).',
        'Reklamla açılan temalar $days gün aktif.',
      );
}
