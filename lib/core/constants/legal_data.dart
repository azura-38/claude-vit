class LegalData {
  static String getPrivacyPolicy(String locale) {
    return _privacyPolicy[locale] ?? _privacyPolicy['en']!;
  }

  static String getTerms(String locale) {
    return _terms[locale] ?? _terms['en']!;
  }

  static String getDisclaimer(String locale) {
    return _disclaimers[locale] ?? _disclaimers['en']!;
  }

  static final Map<String, String> _privacyPolicy = {
    'en': _privacyPolicyEn,
    'tr': _privacyPolicyTr,
    'de': _privacyPolicyDe,
    'es': _privacyPolicyEs,
    'fr': _privacyPolicyFr,
    'pt': _privacyPolicyPt,
    'ar': _privacyPolicyAr,
    'zh': _privacyPolicyZh,
    'ja': _privacyPolicyJa,
    'ko': _privacyPolicyKo,
  };

  static final Map<String, String> _terms = {
    'en': _termsEn,
    'tr': _termsTr,
    'de': _termsDe,
    'es': _termsEs,
    'fr': _termsFr,
    'pt': _termsPt,
    'ar': _termsAr,
    'zh': _termsZh,
    'ja': _termsJa,
    'ko': _termsKo,
  };

  static final Map<String, String> _disclaimers = {
    'en': _disclaimerEn,
    'tr': _disclaimerTr,
    'de': _disclaimerDe,
    'es': _disclaimerEs,
    'fr': _disclaimerFr,
    'pt': _disclaimerPt,
    'ar': _disclaimerAr,
    'zh': _disclaimerZh,
    'ja': _disclaimerJa,
    'ko': _disclaimerKo,
  };

  static const String _privacyPolicyEn = """
PRIVACY POLICY
Last updated: May 26, 2026

VitaCase is a free mobile app for storing personal health-related documents and reminders on your device.

1. WHAT STAYS ON DEVICE
- Documents, notes, medicine reminders, appointments, and profile data are stored locally on your device.
- Added files are encrypted locally before being written to app storage.
- We do not operate a consumer cloud backup for your document vault in this release.

2. WHAT MAY LEAVE THE DEVICE
- Firebase Analytics and Crashlytics may receive technical usage and crash diagnostics.
- Sentry may receive technical error context for debugging.
- AdMob and related Google advertising processors may receive ad request and device-level ad data.

3. WHAT WE DO NOT WANT IN TELEMETRY
- No document names, medical notes, doctor names, or medicine names as analytics payloads.

4. MEDICATION, APPOINTMENT AND REMINDER DATA
- Users may save medication names, schedules, appointment details, and reminder times.
- This data is user-entered and controlled. We do not verify, validate, or medically review it.
- Notifications may be delayed, blocked, or fail due to device settings, OS restrictions, or battery optimization.
- Users are responsible for keeping independent backups of important records.

5. MEDICAL DISCLAIMER
VitaCase is not a medical device and does not provide diagnosis, treatment, or clinical decision support.
""";

  static const String _privacyPolicyTr = """
GİZLİLİK POLİTİKASI
Son güncelleme: 26 Mayıs 2026

VitaCase, kişisel sağlıkla ilgili belgeleri ve hatırlatıcıları cihazınızda saklamak için sunulan ücretsiz bir mobil uygulamadır.

1. CİHAZDA KALAN VERİLER
- Belgeler, notlar, ilaç hatırlatıcıları, randevular ve profil verileri cihazınızda yerel olarak saklanır.
- Yüklenen dosyalar cihazda yerel olarak şifrelenir.

2. CİHAZDAN ÇIKABİLECEK VERİLER
- Firebase Analytics, Crashlytics ve Sentry teknik veriler alabilir.
- AdMob reklam verileri alabilir.

3. TELEMETRİYE GİTMEMESİ GEREKENLER
- Belge adları, tıbbi notlar veya ilaç adları analitik verisi olarak gönderilmez.

4. İLAÇ, RANDEVU VE HATIRLATICI VERİLERİ
- Kullanıcılar ilaç adlarını, programlarını, randevu bilgilerini ve hatırlatıcı zamanlarını kaydedebilir.
- Bu veriler kullanıcı tarafından girilir ve kontrol edilir. Doğrulamaz, analiz etmez veya tıbbi olarak incelemeyiz.
- Bildirimler cihaz ayarları, işletim sistemi kısıtlamaları veya pil optimizasyonu nedeniyle gecikebilir, engellenebilir veya başarısız olabilir.
- Kullanıcılar önemli kayıtlarının bağımsız yedeklerini tutmaktan sorumludur.

5. TIBBİ SORUMLULUK REDDİ
VitaCase tıbbi cihaz değildir; teşhis veya tedavi desteği sağlamaz.
""";

  static const String _privacyPolicyDe = """
DATENSCHUTZERKLÄRUNG
Zuletzt aktualisiert: 20. April 2026

VitaCase ist eine kostenlose mobile App zur Speicherung persönlicher gesundheitsbezogener Dokumente und Erinnerungen auf Ihrem Gerät.

1. WAS AUF DEM GERÄT BLEIBT
- Dokumente, Notizen, Medikamentenerinnerungen, Termine und Profildaten werden lokal gespeichert.
- Hochgeladene Dateien werden lokal verschlüsselt.

2. WAS DAS GERÄT VERLASSEN KANN
- Firebase, Crashlytics und Sentry können technische Nutzungsdaten erhalten.
- AdMob kann Werbedaten auf Geräteebene erhalten.

3. KEINE SENSIBLEN DATEN IN DER TELEMETRIE
- Keine Dokumentennamen, medizinischen Notizen oder Medikamentennamen in Analyse-Payloads.

4. MEDIZINISCHER HAFTUNGSAUSSCHLUSS
VitaCase ist kein Medizinprodukt und bietet keine Diagnose oder Behandlung.
""";

  static const String _privacyPolicyEs = """
POLÍTICA DE PRIVACIDAD
Última actualización: 20 de abril de 2026

VitaCase es una aplicación móvil gratuita para almacenar documentos y recordatorios personales relacionados con la salud en su dispositivo.

1. LO QUE PERMANECE EN EL DISPOSITIVO
- Documentos, notas, recordatorios de medicamentos, citas y datos de perfil se almacenan localmente.
- Los archivos subidos se cifran localmente.

2. LO QUE PUEDE SALIR DEL DISPOSITIVO
- Firebase, Crashlytics y Sentry pueden recibir diagnósticos técnicos.
- AdMob puede recibir datos publicitarios a nivel de dispositivo.

3. DATOS NO INCLUIDOS EN TELEMETRÍA
- No se envían nombres de documentos, notas médicas ni nombres de medicamentos como datos analíticos.

4. AVISO MÉDICO
VitaCase no es un dispositivo médico y no proporciona diagnóstico ni tratamiento.
""";

  static const String _privacyPolicyFr = """
POLITIQUE DE CONFIDENTIALITÉ
Dernière mise à jour : 20 avril 2026

VitaCase est une application mobile gratuite pour stocker des documents et des rappels de santé personnels sur votre appareil.

1. CE QUI RESTE SUR L'APPAREIL
- Les documents, notes, rappels de médicaments, rendez-vous et données de profil sont stockés localement.
- Les fichiers téléchargés sont cryptés localement.

2. CE QUI PEUT QUITTER L'APPAREIL
- Firebase, Crashlytics et Sentry peuvent recevoir des diagnostics techniques.
- AdMob peut recevoir des données publicitaires au niveau de l'appareil.

3. DONNÉES EXCLUES DE LA TÉLÉMÉTRIE
- Aucun nom de document, note médicale ou nom de médicament n'est envoyé comme donnée analytique.

4. AVIS MÉDICAL
VitaCase n'est pas un dispositif médical et ne fournit ni diagnostic ni traitement.
""";

  static const String _privacyPolicyPt = """
POLÍTICA DE PRIVACIDADE
Última atualização: 20 de abril de 2026

VitaCase é um aplicativo móvel gratuito para armazenar documentos e lembretes de saúde pessoais no seu dispositivo.

1. O QUE PERMANECE NO DISPOSITIVO
- Documentos, notas, lembretes de medicamentos, consultas e dados de perfil são armazenados localmente.
- Arquivos carregados são criptografados localmente.

2. O QUE PODE SAIR DO DISPOSITIVO
- Firebase, Crashlytics e Sentry podem receber diagnósticos técnicos.
- AdMob pode receber dados publicitários em nível de dispositivo.

3. DADOS EXCLUÍDOS DA TELEMETRIA
- Nomes de documentos, notas médicas ou nomes de medicamentos não são enviados como dados analíticos.

4. AVISO MÉDICO
VitaCase não é um dispositivo médico e não fornece diagnóstico ou tratamento.
""";

  static const String _privacyPolicyAr = """
سياسة الخصوصية
آخر تحديث: 20 أبريل 2026

VitaCase هو تطبيق جوال مجاني لتخزين المستندات والتذكيرات الصحية الشخصية على جهازك.

1. ما يبقى على الجهاز
- يتم تخزين المستندات والملاحظات وتذكيرات الأدوية والمواعيد وبيانات الملف الشخصي محلياً.
- يتم تشفير الملفات المرفوعة محلياً.

2. ما قد يغادر الجهاز
- قد تتلقى Firebase و Crashlytics و Sentry بيانات فنية وتشخيصية.
- قد تتلقى AdMob بيانات إعلانية على مستوى الجهاز.

3. البيانات المستبعدة من القياس عن بعد
- لا يتم إرسال أسماء المستندات أو الملاحظات الطبية أو أسماء الأدوية كبيانات تحليلية.

4. إخلاء المسؤولية الطبية
VitaCase ليس جهازاً طبياً ولا يقدم تشخيصاً أو علاجاً.
""";

  static const String _privacyPolicyZh = """
隐私政策
最后更新：2026年4月20日

VitaCase 是一款免费的移动应用程序，用于在您的设备上存储个人健康相关的文档和提醒。

1. 留在设备上的内容
- 文档、笔记、药物提醒、预约和个人资料数据均存储在本地。
- 上传的文件在本地加密。

2. 可能离开设备的内容
- Firebase, Crashlytics 和 Sentry 可能会接收技术诊断数据。
- AdMob 可能会接收设备级广告数据。

3. 遥测中不包含的内容
- 文档名称、医疗笔记或药物名称不会作为分析数据发送。

4. 医疗免责声明
VitaCase 不是医疗设备，不提供诊断或治疗。
""";

  static const String _privacyPolicyJa = """
プライバシーポリシー
最終更新日：2026年4月20日

VitaCaseは、個人の健康関連のドキュメントやリマインダーをデバイスに保存するための無料のモバイルアプリです。

1. デバイスに残るデータ
- ドキュメント、メモ、薬のリマインダー、予定、プロフィールデータはローカルに保存されます。
- アップロードされたファイルはローカルで暗号化されます。

2. デバイスから送信される可能性のあるデータ
- Firebase, Crashlytics, Sentryは技術的な診断データを受信する場合があります。
- AdMobはデバイスレベルの広告データを受信する場合があります。

3. テレメトリに含まれないデータ
- ドキュメント名、医療メモ、薬名は分析データとして送信されません。

4. 医療免責事項
VitaCaseは医療機器ではなく、診断や治療を提供するものではありません。
""";

  static const String _privacyPolicyKo = """
개인정보 처리방침
마지막 업데이트: 2026년 4월 20일

VitaCase는 개인 건강 관련 문서와 알림을 기기에 저장하는 무료 모바일 앱입니다.

1. 기기에 보관되는 데이터
- 문서, 메모, 약 알림, 일정, 프로필 데이터는 로컬에 저장됩니다.
- 업로드된 파일은 로컬에서 암호화됩니다.

2. 기기 외부로 전송될 수 있는 데이터
- Firebase, Crashlytics, Sentry는 기술 진단 데이터를 수신할 수 있습니다.
- AdMob은 기기 수준의 광고 데이터를 수신할 수 있습니다.

3. 텔레메트리에 포함되지 않는 데이터
- 문서 이름, 의료 메모, 약 이름은 분석 데이터로 전송되지 않습니다.

4. 의료 면책 조항
VitaCase는 의료 기기가 아니며 진단이나 치료를 제공하지 않습니다.
""";

  static const String _termsEn = """
TERMS AND CONDITIONS
Last Updated: May 26, 2026
1. VitaCase is a free app supported by ads.
2. You are responsible for the security of your device and backups.
3. The app uses Firebase, Sentry, and AdMob for operations.
4. VitaCase is not a medical service.
5. VitaCase does not provide medication instructions, dosage recommendations, or official appointment notices.
6. Notifications may be delayed, blocked, or fail due to device settings or technical reasons.
7. You agree not to rely solely on VitaCase for medication, appointments, or emergency decisions.
""";

  static const String _termsTr = """
KULLANIM KOŞULLARI
Son güncelleme: 26 Mayıs 2026
1. VitaCase reklam destekli ücretsiz bir uygulamadır.
2. Cihaz güvenliği ve yedekleme sorumluluğu size aittir.
3. Uygulama Firebase, Sentry ve AdMob kullanmaktadır.
4. VitaCase bir tıbbi hizmet değildir.
5. VitaCase ilaç talimatı, dozaj önerisi veya resmi randevu bildirimi sağlamaz.
6. Bildirimler cihaz ayarları veya teknik nedenlerle gecikebilir, engellenebilir veya başarısız olabilir.
7. İlaç kullanımı, randevular veya acil durumlar için yalnızca VitaCase'e güvenmemeyi kabul edersiniz.
""";

  static const String _termsDe = "NUTZUNGSBEDINGUNGEN...";
  static const String _termsEs = "TÉRMINOS Y CONDICIONES...";
  static const String _termsFr = "CONDITIONS D'UTILISATION...";
  static const String _termsPt = "TERMOS E CONDIÇÕES...";
  static const String _termsAr = "الشروط والأحكام...";
  static const String _termsZh = "使用条款...";
  static const String _termsJa = "利用規約...";
  static const String _termsKo = "이용 약관...";

  static const String _disclaimerEn = """
DISCLAIMER
Last updated: May 20, 2026
VitaCase is for organization only. It is not a medical device.
Medication use, dosage, and timing must always be based on instructions from qualified healthcare providers.
VitaCase is not an official appointment system and does not replace notifications from hospitals or clinics.
Notifications may be delayed, blocked, or fail due to device settings, OS restrictions, or battery optimization.
VitaCase is not an emergency service. In emergencies, contact local emergency services immediately.
""";

  static const String _disclaimerTr = """
SORUMLULUK REDDİ
Son güncelleme: 20 Mayıs 2026
VitaCase sadece düzenleme amaçlıdır. Tıbbi cihaz değildir.
İlaç kullanımı, dozajı ve zamanlaması her zaman nitelikli sağlık uzmanlarının talimatlarına dayanmalıdır.
VitaCase resmi bir randevu sistemi değildir ve hastane veya klinik bildirimlerinin yerini almaz.
Bildirimler cihaz ayarları, işletim sistemi kısıtlamaları veya pil optimizasyonu nedeniyle gecikebilir, engellenebilir veya başarısız olabilir.
VitaCase bir acil durum hizmeti değildir. Acil durumlarda derhal yerel acil servislerle iletişime geçin.
""";

  static const String _disclaimerDe = "HAFTUNGSAUSSCHLUSS...";
  static const String _disclaimerEs = "AVISO LEGAL...";
  static const String _disclaimerFr = "MENTIONS LÉGALES...";
  static const String _disclaimerPt = "AVISO LEGAL...";
  static const String _disclaimerAr = "إخلاء المسؤولية...";
  static const String _disclaimerZh = "免责声明...";
  static const String _disclaimerJa = "免責事項...";
  static const String _disclaimerKo = "면책 조항...";
}
