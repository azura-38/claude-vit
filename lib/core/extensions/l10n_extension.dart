import 'package:flutter/widgets.dart';
import 'package:vitacase/core/l10n/translations.dart';
import 'package:vitacase/l10n/app_localizations.dart';

extension L10nBuildContext on BuildContext {
  /// Backward-compatible translation proxy.
  ///
  /// Prefer `context.tr('snake_case_key')` in new code. The proxy exists so the
  /// current codebase can keep working while old `context.l10n.someCamelKey`
  /// calls are migrated screen by screen.
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
      normalized;

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

const Map<String, Map<String, String>> _dynamicFallbacks = {
  'en': {
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
  'es': {
    'subcategory': 'Subcategoría',
    'appointment_type_insurance': 'Seguro',
    'appointment_type_travel': 'Viaje',
    'appointment_subcategory_general': 'General',
    'appointment_subcategory_doctor_visit': 'Consulta médica',
    'appointment_subcategory_lab_test': 'Prueba de laboratorio',
    'appointment_subcategory_dental': 'Dental',
    'appointment_subcategory_therapy': 'Terapia',
    'appointment_subcategory_payment': 'Pago',
    'appointment_subcategory_banking': 'Banco',
    'appointment_subcategory_tax': 'Impuestos',
    'appointment_subcategory_contract': 'Contrato',
    'appointment_subcategory_consultation': 'Consulta',
    'appointment_subcategory_policy': 'Póliza',
    'appointment_subcategory_claim': 'Reclamo',
    'appointment_subcategory_work_meeting': 'Reunión de trabajo',
    'appointment_subcategory_family': 'Familia',
    'appointment_subcategory_travel_plan': 'Plan de viaje',
    'appointment_subcategory_task': 'Tarea',
    'appointment_subcategory_other': 'Otro',
    'importance_high': 'Alta',
    'importance_normal': 'Normal',
    'label_date_time': 'Fecha y hora',
    'label_reminder': 'Recordatorio',
    'reminder_10m': '10 minutos antes',
    'reminder_1h': '1 hora antes',
    'reminder_1d': '1 día antes',
    'reminder_7d': '7 días antes',
    'hint_title': 'Ej. revisión anual',
    'hint_location': 'Ej. clínica, hospital, laboratorio, oficina o reunión online',
  },
  'pt': {
    'subcategory': 'Subcategoria',
    'appointment_type_insurance': 'Seguro',
    'appointment_type_travel': 'Viagem',
    'appointment_subcategory_general': 'Geral',
    'appointment_subcategory_doctor_visit': 'Consulta médica',
    'appointment_subcategory_lab_test': 'Exame laboratorial',
    'appointment_subcategory_dental': 'Dental',
    'appointment_subcategory_therapy': 'Terapia',
    'appointment_subcategory_payment': 'Pagamento',
    'appointment_subcategory_banking': 'Banco',
    'appointment_subcategory_tax': 'Imposto',
    'appointment_subcategory_contract': 'Contrato',
    'appointment_subcategory_consultation': 'Consulta',
    'appointment_subcategory_policy': 'Apólice',
    'appointment_subcategory_claim': 'Reclamação',
    'appointment_subcategory_work_meeting': 'Reunião de trabalho',
    'appointment_subcategory_family': 'Família',
    'appointment_subcategory_travel_plan': 'Plano de viagem',
    'appointment_subcategory_task': 'Tarefa',
    'appointment_subcategory_other': 'Outro',
    'importance_high': 'Alta',
    'importance_normal': 'Normal',
    'label_date_time': 'Data e hora',
    'label_reminder': 'Lembrete',
    'reminder_10m': '10 minutos antes',
    'reminder_1h': '1 hora antes',
    'reminder_1d': '1 dia antes',
    'reminder_7d': '7 dias antes',
    'hint_title': 'Ex. check-up anual',
    'hint_location': 'Ex. clínica, hospital, laboratório, escritório ou reunião online',
  },
  'de': {
    'subcategory': 'Unterkategorie',
    'appointment_type_insurance': 'Versicherung',
    'appointment_type_travel': 'Reise',
    'appointment_subcategory_general': 'Allgemein',
    'appointment_subcategory_doctor_visit': 'Arztbesuch',
    'appointment_subcategory_lab_test': 'Labortest',
    'appointment_subcategory_dental': 'Zahnarzt',
    'appointment_subcategory_therapy': 'Therapie',
    'appointment_subcategory_payment': 'Zahlung',
    'appointment_subcategory_banking': 'Bank',
    'appointment_subcategory_tax': 'Steuer',
    'appointment_subcategory_contract': 'Vertrag',
    'appointment_subcategory_consultation': 'Beratung',
    'appointment_subcategory_policy': 'Police',
    'appointment_subcategory_claim': 'Anspruch',
    'appointment_subcategory_work_meeting': 'Arbeitsmeeting',
    'appointment_subcategory_family': 'Familie',
    'appointment_subcategory_travel_plan': 'Reiseplan',
    'appointment_subcategory_task': 'Aufgabe',
    'appointment_subcategory_other': 'Andere',
    'importance_high': 'Hoch',
    'importance_normal': 'Normal',
    'label_date_time': 'Datum & Uhrzeit',
    'label_reminder': 'Erinnerung',
    'reminder_10m': '10 Minuten vorher',
    'reminder_1h': '1 Stunde vorher',
    'reminder_1d': '1 Tag vorher',
    'reminder_7d': '7 Tage vorher',
    'hint_title': 'z. B. jährliche Kontrolle',
    'hint_location': 'z. B. Klinik, Krankenhaus, Labor, Büro oder Online-Meeting',
  },
  'fr': {
    'subcategory': 'Sous-catégorie',
    'appointment_type_insurance': 'Assurance',
    'appointment_type_travel': 'Voyage',
    'appointment_subcategory_general': 'Général',
    'appointment_subcategory_doctor_visit': 'Consultation médicale',
    'appointment_subcategory_lab_test': 'Test de laboratoire',
    'appointment_subcategory_dental': 'Dentaire',
    'appointment_subcategory_therapy': 'Thérapie',
    'appointment_subcategory_payment': 'Paiement',
    'appointment_subcategory_banking': 'Banque',
    'appointment_subcategory_tax': 'Impôt',
    'appointment_subcategory_contract': 'Contrat',
    'appointment_subcategory_consultation': 'Consultation',
    'appointment_subcategory_policy': 'Police',
    'appointment_subcategory_claim': 'Réclamation',
    'appointment_subcategory_work_meeting': 'Réunion de travail',
    'appointment_subcategory_family': 'Famille',
    'appointment_subcategory_travel_plan': 'Plan de voyage',
    'appointment_subcategory_task': 'Tâche',
    'appointment_subcategory_other': 'Autre',
    'importance_high': 'Élevée',
    'importance_normal': 'Normale',
    'label_date_time': 'Date et heure',
    'label_reminder': 'Rappel',
    'reminder_10m': '10 minutes avant',
    'reminder_1h': '1 heure avant',
    'reminder_1d': '1 jour avant',
    'reminder_7d': '7 jours avant',
    'hint_title': 'Ex. bilan annuel',
    'hint_location': 'Ex. clinique, hôpital, laboratoire, bureau ou réunion en ligne',
  },
  'hi': {
    'subcategory': 'उपश्रेणी',
    'appointment_type_insurance': 'बीमा',
    'appointment_type_travel': 'यात्रा',
    'appointment_subcategory_general': 'सामान्य',
    'appointment_subcategory_doctor_visit': 'डॉक्टर विज़िट',
    'appointment_subcategory_lab_test': 'लैब टेस्ट',
    'appointment_subcategory_dental': 'डेंटल',
    'appointment_subcategory_therapy': 'थेरेपी',
    'appointment_subcategory_payment': 'भुगतान',
    'appointment_subcategory_banking': 'बैंकिंग',
    'appointment_subcategory_tax': 'टैक्स',
    'appointment_subcategory_contract': 'अनुबंध',
    'appointment_subcategory_consultation': 'परामर्श',
    'appointment_subcategory_policy': 'पॉलिसी',
    'appointment_subcategory_claim': 'क्लेम',
    'appointment_subcategory_work_meeting': 'वर्क मीटिंग',
    'appointment_subcategory_family': 'परिवार',
    'appointment_subcategory_travel_plan': 'यात्रा योजना',
    'appointment_subcategory_task': 'कार्य',
    'appointment_subcategory_other': 'अन्य',
    'importance_high': 'उच्च',
    'importance_normal': 'सामान्य',
    'label_date_time': 'दिनांक और समय',
    'label_reminder': 'रिमाइंडर',
    'reminder_10m': '10 मिनट पहले',
    'reminder_1h': '1 घंटा पहले',
    'reminder_1d': '1 दिन पहले',
    'reminder_7d': '7 दिन पहले',
    'hint_title': 'जैसे वार्षिक चेकअप',
    'hint_location': 'जैसे क्लिनिक, अस्पताल, लैब, कार्यालय या ऑनलाइन मीटिंग',
  },
  'ja': {
    'subcategory': 'サブカテゴリ',
    'appointment_type_insurance': '保険',
    'appointment_type_travel': '旅行',
    'appointment_subcategory_general': '一般',
    'appointment_subcategory_doctor_visit': '診察',
    'appointment_subcategory_lab_test': '検査',
    'appointment_subcategory_dental': '歯科',
    'appointment_subcategory_therapy': 'セラピー',
    'appointment_subcategory_payment': '支払い',
    'appointment_subcategory_banking': '銀行',
    'appointment_subcategory_tax': '税金',
    'appointment_subcategory_contract': '契約',
    'appointment_subcategory_consultation': '相談',
    'appointment_subcategory_policy': '保険証券',
    'appointment_subcategory_claim': '請求',
    'appointment_subcategory_work_meeting': '仕事の会議',
    'appointment_subcategory_family': '家族',
    'appointment_subcategory_travel_plan': '旅行計画',
    'appointment_subcategory_task': 'タスク',
    'appointment_subcategory_other': 'その他',
    'importance_high': '高',
    'importance_normal': '通常',
    'label_date_time': '日付と時刻',
    'label_reminder': 'リマインダー',
    'reminder_10m': '10分前',
    'reminder_1h': '1時間前',
    'reminder_1d': '1日前',
    'reminder_7d': '7日前',
    'hint_title': '例：年次チェックアップ',
    'hint_location': '例：クリニック、病院、検査室、オフィス、オンライン会議',
  },
  'zh': {
    'subcategory': '子类别',
    'appointment_type_insurance': '保险',
    'appointment_type_travel': '旅行',
    'appointment_subcategory_general': '常规',
    'appointment_subcategory_doctor_visit': '就诊',
    'appointment_subcategory_lab_test': '实验室检查',
    'appointment_subcategory_dental': '牙科',
    'appointment_subcategory_therapy': '治疗',
    'appointment_subcategory_payment': '付款',
    'appointment_subcategory_banking': '银行',
    'appointment_subcategory_tax': '税务',
    'appointment_subcategory_contract': '合同',
    'appointment_subcategory_consultation': '咨询',
    'appointment_subcategory_policy': '保单',
    'appointment_subcategory_claim': '理赔',
    'appointment_subcategory_work_meeting': '工作会议',
    'appointment_subcategory_family': '家庭',
    'appointment_subcategory_travel_plan': '旅行计划',
    'appointment_subcategory_task': '任务',
    'appointment_subcategory_other': '其他',
    'importance_high': '高',
    'importance_normal': '普通',
    'label_date_time': '日期和时间',
    'label_reminder': '提醒',
    'reminder_10m': '提前10分钟',
    'reminder_1h': '提前1小时',
    'reminder_1d': '提前1天',
    'reminder_7d': '提前7天',
    'hint_title': '例如：年度检查',
    'hint_location': '例如：诊所、医院、实验室、办公室或线上会议',
  },
};
