import 'package:flutter/widgets.dart';
import 'package:vitacase/core/l10n/translations.dart';
import 'package:vitacase/l10n/app_localizations.dart';

extension L10nBuildContext on BuildContext {
  dynamic get l10n => _L10nProxy(this);

  String tr(String key, {Map<String, String>? extra}) {
    return _lookupTranslation(this, key, extra: extra);
  }
}

class _L10nProxy {
  const _L10nProxy(this._context);

  final BuildContext _context;

  String call(String key, {Map<String, String>? extra}) {
    return _lookupTranslation(_context, key, extra: extra);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = _symbolName(invocation.memberName);
    if (name.isEmpty) return '';

    if (invocation.isGetter) {
      return _lookupTranslation(_context, name);
    }

    if (invocation.isMethod) {
      var value = _lookupTranslation(_context, name);
      for (final argument in invocation.positionalArguments) {
        value = value.replaceFirst(RegExp(r'\{[^}]+\}'), argument.toString());
      }
      return value;
    }

    return super.noSuchMethod(invocation);
  }
}

String _lookupTranslation(
  BuildContext context,
  String key, {
  Map<String, String>? extra,
}) {
  final locale = AppLocalizations.of(context)?.localeName ?? Localizations.localeOf(context).languageCode;
  final languageCode = locale.split('_').first;
  final normalized = _normalizeTranslationKey(key);

  var value = Translations.data[languageCode]?[normalized] ??
      _dynamicFallbacks[languageCode]?[normalized] ??
      Translations.data['en']?[normalized] ??
      _dynamicFallbacks['en']?[normalized] ??
      _humanizeMissingKey(normalized, languageCode);

  if (extra == null || extra.isEmpty) return value;

  for (final entry in extra.entries) {
    value = value.replaceAll('{${entry.key}}', entry.value);
  }
  return value;
}

String _normalizeTranslationKey(String key) {
  if (key.isEmpty || key.contains('_')) return key;

  final buffer = StringBuffer();
  for (var i = 0; i < key.length; i++) {
    final char = key[i];
    final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
    final isDigit = _isDigit(char);
    final previous = i > 0 ? key[i - 1] : null;
    final previousIsDigit = previous != null && _isDigit(previous);

    if (i > 0 && (isUpper || (isDigit && !previousIsDigit))) {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }
  return buffer.toString();
}

String _humanizeMissingKey(String key, String languageCode) {
  final direct = _missingKeyLabels[languageCode]?[key] ?? _missingKeyLabels['en']?[key];
  if (direct != null) return direct;

  final cleaned = key
      .replaceAll(RegExp(r'^(button|btn|label|title|hint|screen|route)_'), '')
      .replaceAll('_', ' ')
      .trim();
  if (cleaned.isEmpty) return '';

  return cleaned
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

bool _isDigit(String value) {
  if (value.isEmpty) return false;
  final code = value.codeUnitAt(0);
  return code >= 48 && code <= 57;
}

String _symbolName(Symbol symbol) {
  final text = symbol.toString();
  if (!text.startsWith('Symbol("') || !text.endsWith('")')) return '';
  final value = text.substring(8, text.length - 2);
  if (value.isEmpty) return '';
  return value;
}

const Map<String, Map<String, String>> _missingKeyLabels = {
  'en': {
    'add_appointment': 'Add Appointment',
    'appointment_add': 'Add Appointment',
    'create_appointment': 'Create Appointment',
    'add_document': 'Add Document',
    'document_add': 'Add Document',
    'add_medication': 'Add Medication',
    'medicine_add': 'Add Medicine',
    'health_data_add': 'Add Health Data',
    'doctor_add': 'Add Doctor',
    'personal_info': 'Personal Information',
    'important_info': 'Important Info',
  },
  'tr': {
    'add_appointment': 'Randevu Ekle',
    'appointment_add': 'Randevu Ekle',
    'create_appointment': 'Randevu Oluştur',
    'add_document': 'Belge Ekle',
    'document_add': 'Belge Ekle',
    'add_medication': 'İlaç Ekle',
    'medicine_add': 'İlaç Ekle',
    'health_data_add': 'Sağlık Verisi Ekle',
    'doctor_add': 'Doktor Ekle',
    'personal_info': 'Kişisel Bilgiler',
    'important_info': 'Önemli Bilgiler',
  },
};

const Map<String, Map<String, String>> _dynamicFallbacks = {
  'en': {
    'profile_photo': 'Profile photo',
    'profile_photo_add_desc': 'Add a photo to personalize your profile.',
    'profile_photo_selected': 'Photo selected. It will be saved with your profile.',
    'subcategory': 'Subcategory',
    'appointment_type_insurance': 'Insurance',
    'appointment_type_travel': 'Travel',
    'appointment_subcategory_general': 'General',
    'appointment_subcategory_doctor_visit': 'Doctor Visit',
    'appointment_subcategory_lab_test': 'Lab Test',
    'appointment_subcategory_dental': 'Dental',
    'appointment_subcategory_therapy': 'Therapy',
    'appointment_subcategory_payment': 'Payment',
    'appointment_subcategory_banking': 'Banking',
    'appointment_subcategory_tax': 'Tax',
    'appointment_subcategory_contract': 'Contract',
    'appointment_subcategory_consultation': 'Consultation',
    'appointment_subcategory_policy': 'Policy',
    'appointment_subcategory_claim': 'Claim',
    'appointment_subcategory_work_meeting': 'Work Meeting',
    'appointment_subcategory_family': 'Family',
    'appointment_subcategory_travel_plan': 'Travel Plan',
    'appointment_subcategory_task': 'Task',
    'appointment_subcategory_other': 'Other',
    'importance_high': 'High',
    'importance_normal': 'Normal',
    'label_date_time': 'Date & Time',
    'label_reminder': 'Reminder',
    'reminder_10m': '10 minutes before',
    'reminder_1h': '1 hour before',
    'reminder_1d': '1 day before',
    'reminder_7d': '7 days before',
    'hint_title': 'e.g. Annual checkup',
    'hint_location': 'e.g. Clinic, hospital, lab, office or online meeting',
  },
  'tr': {
    'profile_photo': 'Profil fotoğrafı',
    'profile_photo_add_desc': 'Profilini kişiselleştirmek için fotoğraf ekle.',
    'profile_photo_selected': 'Fotoğraf seçildi. Profilinle birlikte kaydedilecek.',
    'subcategory': 'Alt kategori',
    'appointment_type_insurance': 'Sigorta',
    'appointment_type_travel': 'Seyahat',
    'appointment_subcategory_general': 'Genel',
    'appointment_subcategory_doctor_visit': 'Muayene',
    'appointment_subcategory_lab_test': 'Test / Tetkik',
    'appointment_subcategory_dental': 'Diş',
    'appointment_subcategory_therapy': 'Terapi',
    'appointment_subcategory_payment': 'Ödeme',
    'appointment_subcategory_banking': 'Banka',
    'appointment_subcategory_tax': 'Vergi',
    'appointment_subcategory_contract': 'Sözleşme',
    'appointment_subcategory_consultation': 'Danışma',
    'appointment_subcategory_policy': 'Poliçe',
    'appointment_subcategory_claim': 'Talep / Hasar',
    'appointment_subcategory_work_meeting': 'İş görüşmesi',
    'appointment_subcategory_family': 'Aile',
    'appointment_subcategory_travel_plan': 'Seyahat planı',
    'appointment_subcategory_task': 'Görev',
    'appointment_subcategory_other': 'Diğer',
    'importance_high': 'Yüksek',
    'importance_normal': 'Normal',
    'label_date_time': 'Tarih ve Saat',
    'label_reminder': 'Hatırlatıcı',
    'reminder_10m': '10 dakika önce',
    'reminder_1h': '1 saat önce',
    'reminder_1d': '1 gün önce',
    'reminder_7d': '7 gün önce',
    'hint_title': 'Örn. Kontrol randevusu',
    'hint_location': 'Örn. Klinik, hastane, laboratuvar, ofis veya online görüşme',
  },
};
