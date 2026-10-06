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
    'it': _privacyPolicyIt,
    'hi': _privacyPolicyHi,
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
    'it': _termsIt,
    'hi': _termsHi,
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
    'it': _disclaimerIt,
    'hi': _disclaimerHi,
    'ar': _disclaimerAr,
    'zh': _disclaimerZh,
    'ja': _disclaimerJa,
    'ko': _disclaimerKo,
  };

  static const String _privacyPolicyEn = """
PRIVACY POLICY
Last updated: October 5, 2026

VitaCase is a free mobile app for storing personal health-related documents and reminders on your device.

1. WHAT STAYS ON DEVICE
- Documents, notes, medicine reminders, appointments, and profile data are stored locally on your device.
- Uploaded files are encrypted locally before being written to app storage.
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
Son güncelleme: 5 Ekim 2026

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
Last Updated: October 5, 2026
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
Son güncelleme: 5 Ekim 2026
1. VitaCase reklam destekli ücretsiz bir uygulamadır.
2. Cihaz güvenliği ve yedekleme sorumluluğu size aittir.
3. Uygulama Firebase, Sentry ve AdMob kullanmaktadır.
4. VitaCase bir tıbbi hizmet değildir.
5. VitaCase ilaç talimatı, dozaj önerisi veya resmi randevu bildirimi sağlamaz.
6. Bildirimler cihaz ayarları veya teknik nedenlerle gecikebilir, engellenebilir veya başarısız olabilir.
7. İlaç kullanımı, randevular veya acil durumlar için yalnızca VitaCase'e güvenmemeyi kabul edersiniz.
""";

  static const String _termsDe = """
NUTZUNGSBEDINGUNGEN
Zuletzt aktualisiert: 5. Oktober 2026
1. VitaCase ist eine kostenlose, werbefinanzierte App.
2. Sie sind für die Sicherheit Ihres Geräts und Ihrer Backups selbst verantwortlich.
3. Die App nutzt Firebase, Sentry und AdMob für den Betrieb.
4. VitaCase ist kein medizinischer Dienst.
5. VitaCase bietet keine Medikamentenanweisungen, Dosierungsempfehlungen oder offizielle Terminerinnerungen.
6. Benachrichtigungen können sich aufgrund von Geräteeinstellungen oder technischen Gründen verzögern, blockiert werden oder ausbleiben.
7. Sie erklären sich damit einverstanden, sich bei Medikamenteneinnahme, Terminen oder Notfallentscheidungen nicht ausschließlich auf VitaCase zu verlassen.
""";

  static const String _termsEs = """
TÉRMINOS Y CONDICIONES
Última actualización: 5 de octubre de 2026
1. VitaCase es una aplicación gratuita financiada con anuncios.
2. Usted es responsable de la seguridad de su dispositivo y de sus copias de seguridad.
3. La aplicación utiliza Firebase, Sentry y AdMob para su funcionamiento.
4. VitaCase no es un servicio médico.
5. VitaCase no proporciona instrucciones sobre medicamentos, recomendaciones de dosificación ni avisos oficiales de citas.
6. Las notificaciones pueden retrasarse, bloquearse o fallar debido a la configuración del dispositivo o razones técnicas.
7. Usted acepta no depender exclusivamente de VitaCase para la toma de medicamentos, citas o decisiones de emergencia.
""";

  static const String _termsFr = """
CONDITIONS D'UTILISATION
Dernière mise à jour : 5 octobre 2026
1. VitaCase est une application gratuite financée par la publicité.
2. Vous êtes responsable de la sécurité de votre appareil et de vos sauvegardes.
3. L'application utilise Firebase, Sentry et AdMob pour son fonctionnement.
4. VitaCase n'est pas un service médical.
5. VitaCase ne fournit pas d'instructions sur les médicaments, de posologie ou de rappels de rendez-vous officiels.
6. Les notifications peuvent être retardées, bloquées ou échouer en raison des paramètres de l'appareil ou de raisons techniques.
7. Vous acceptez de ne pas vous fier uniquement à VitaCase pour les médicaments, les rendez-vous ou les décisions d'urgence.
""";

  static const String _termsPt = """
TERMOS E CONDIÇÕES
Última atualização: 5 de outubro de 2026
1. O VitaCase é um aplicativo gratuito financiado por anúncios.
2. Você é responsável pela segurança do seu dispositivo e pelas cópias de segurança.
3. O aplicativo utiliza Firebase, Sentry e AdMob para suas operações.
4. O VitaCase não é um serviço médico.
5. O VitaCase não fornece instruções sobre medicamentos, dosagens ou notificações oficiais de consultas.
6. As notificações podem sofrer atrasos, bloqueios ou falhar devido às configurações do dispositivo ou motivos técnicos.
7. Você concorda em não confiar exclusivamente no VitaCase para medicamentos, consultas ou decisões de emergência.
""";

  static const String _termsAr = """
الشروط والأحكام
آخر تحديث: 5 أكتوبر 2026
1. تطبيق VitaCase مجاني مدعوم بالإعلانات.
2. أنت المسؤول الوحيد عن أمان جهازك والنسخ الاحتياطية.
3. يستخدم التطبيق خدمات Firebase و Sentry و AdMob للتشغيل.
4. VitaCase ليس خدمة طبية ولا يقدم استشارات علاجية.
5. لا يقدم التطبيق إرشادات دوائية أو جرعات محددة أو إشعارات مواعيد رسمية.
6. قد تتأخر الإشعارات أو يتم حظرها أو تفشل لأسباب تقنية أو إعدادات النظام.
7. توافق على عدم الاعتماد فقط على التطبيق في تناول الأدوية أو المواعيد أو حالات الطوارئ.
""";

  static const String _termsZh = """
条款与条件
最后更新：2026年10月5日
1. VitaCase 是一款包含广告支持的免费应用程序。
2. 您需自行对设备安全及本地数据备份负责。
3. 本应用使用 Firebase、Sentry 和 AdMob 提供运营支持。
4. VitaCase 不是医疗服务机构。
5. VitaCase 不提供用药指导、剂量建议或医院官方就诊通知。
6. 由于设备系统设置或技术原因，提醒通知可能会延迟、受阻或无法发送。
7. 您同意不单独依赖 VitaCase 进行用药安排、就医安排或紧急健康决策。
""";

  static const String _termsJa = """
利用規約
最終更新日：2026年10月5日
1. VitaCaseは広告によって支えられている無料アプリです。
2. 端末のセキュリティおよびバックアップはお客様自身の責任となります。
3. アプリの運用にはFirebase、Sentry、AdMobを使用しています。
4. VitaCaseは医療サービスを提供するものではありません。
5. VitaCaseは服薬指示、用法用量の提案、または公式な予約通知を提供するものではありません。
6. 通知は端末の設定や技術的な要因により遅延、ブロック、または失敗する場合があります。
7. 服薬、通院予約、緊急時の判断をVitaCaseのみに依存しないことに同意するものとします。
""";

  static const String _termsKo = """
이용 약관
마지막 업데이트: 2026년 10월 5일
1. VitaCase는 광고로 지원되는 무료 모바일 애플리케이션입니다.
2. 기기 보안 및 데이터 백업의 책임은 사용자 본인에게 있습니다.
3. 본 앱은 원활한 운영을 위해 Firebase, Sentry 및 AdMob을 사용합니다.
4. VitaCase는 의료 서비스를 제공하지 않습니다.
5. VitaCase는 약물 복용 지침, 용량 권장 또는 공식 진료 예약을 제공하지 않습니다.
6. 기기 설정이나 기술적 요인으로 인해 알림이 지연되거나 차단되거나 실패할 수 있습니다.
7. 약물 복용, 진료 일정 또는 응급 상황 결정 시 VitaCase에만 의존하지 않는 것에 동의합니다.
""";

  static const String _disclaimerEn = """
DISCLAIMER
Last updated: October 5, 2026
VitaCase is for organization only. It is not a medical device.
Medication use, dosage, and timing must always be based on instructions from qualified healthcare providers.
VitaCase is not an official appointment system and does not replace notifications from hospitals or clinics.
Notifications may be delayed, blocked, or fail due to device settings, OS restrictions, or battery optimization.
VitaCase is not an emergency service. In emergencies, contact local emergency services immediately.
""";

  static const String _disclaimerTr = """
SORUMLULUK REDDİ
Son güncelleme: 5 Ekim 2026
VitaCase sadece düzenleme amaçlıdır. Tıbbi cihaz değildir.
İlaç kullanımı, dozajı ve zamanlaması her zaman nitelikli sağlık uzmanlarının talimatlarına dayanmalıdır.
VitaCase resmi bir randevu sistemi değildir ve hastane veya klinik bildirimlerinin yerini almaz.
Bildirimler cihaz ayarları, işletim sistemi kısıtlamaları veya pil optimizasyonu nedeniyle gecikebilir, engellenebilir veya başarısız olabilir.
VitaCase bir acil durum hizmeti değildir. Acil durumlarda derhal yerel acil servislerle iletişime geçin.
""";

  static const String _disclaimerDe = """
HAFTUNGSAUSSCHLUSS
Zuletzt aktualisiert: 5. Oktober 2026
VitaCase dient ausschließlich der Organisation. Es ist kein Medizinprodukt.
Die Anwendung, Dosierung und der Zeitpunkt von Medikamenten müssen stets auf den Anweisungen qualifizierter medizinischer Fachkräfte basieren.
VitaCase ist kein offizielles Terminsystem und ersetzt keine Benachrichtigungen von Krankenhäusern oder Praxen.
Benachrichtigungen können sich aufgrund von Geräteeinstellungen, Betriebssystemeinschränkungen oder Batterieoptimierungen verzögern oder ausfallen.
VitaCase ist kein Notfalldienst. Wenden Sie sich in Notfällen sofort an die örtlichen Notdienste.
""";

  static const String _disclaimerEs = """
AVISO LEGAL Y DE RESPONSABILIDAD
Última actualización: 5 de octubre de 2026
VitaCase es solo para fines organizativos. No es un dispositivo médico.
El uso, la dosis y el horario de los medicamentos siempre deben basarse en las instrucciones de profesionales de la salud calificados.
VitaCase no es un sistema oficial de gestión de citas ni reemplaza los avisos de clínicas u hospitales.
Las notificaciones pueden retrasarse, bloquearse o fallar debido a la configuración del sistema, restricciones del SO o ahorro de batería.
VitaCase no es un servicio de emergencias. En caso de emergencia médica, comuníquese de inmediato con los servicios de urgencias locales.
""";

  static const String _disclaimerFr = """
AVERTISSEMENT LÉGAL ET MÉDICAL
Dernière mise à jour : 5 octobre 2026
VitaCase est uniquement un outil d'organisation. Ce n'est pas un dispositif médical.
L'utilisation, le dosage et l'horaire des médicaments doivent toujours être conformes aux instructions de professionnels de santé qualifiés.
VitaCase n'est pas un système officiel de prise de rendez-vous et ne remplace pas les notifications des hôpitaux ou cliniques.
Les notifications peuvent être retardées, bloquées ou ne pas s'afficher en raison des réglages de l'appareil ou de l'optimisation de la batterie.
VitaCase n'est pas un service d'urgence. En cas d'urgence, contactez immédiatement les services de secours locaux.
""";

  static const String _disclaimerPt = """
AVISO LEGAL E MÉDICO
Última atualização: 5 de outubro de 2026
O VitaCase é apenas para fins de organização. Não é um dispositivo médico.
O uso, a dosagem e o horário dos medicamentos devem sempre seguir as instruções de profissionais de saúde qualificados.
O VitaCase não é um sistema oficial de consultas e não substitui os avisos de hospitais ou clínicas.
As notificações podem atrasar, ser bloqueadas ou falhar devido às configurações do sistema operacional ou economia de bateria.
O VitaCase não é um serviço de emergência. Em emergências, contate imediatamente os serviços de resgate locais.
""";

  static const String _disclaimerAr = """
إخلاء المسؤولية الطبية
آخر تحديث: 5 أكتوبر 2026
تطبيق VitaCase مخصص لأغراض التنظيم الشخصي فقط وليس جهازاً طبياً.
يجب أن يستند استخدام الأدوية وجرعاتها وتوقيتها دائماً إلى تعليمات مقدمي الرعاية الصحية المؤهلين.
VitaCase ليس نظاماً رسمياً للمواعيد ولا يحل محل إشعارات المستشفيات أو العيادات.
قد تتأخر الإشعارات أو تفشل بسبب إعدادات الجهاز أو قيود نظام التشغيل أو تحسين البطارية.
VitaCase ليس خدمة طوارئ. في حالات الطوارئ، اتصل فوراً بخدمات الإسعاف والطوارئ المحلية.
""";

  static const String _disclaimerZh = """
免责声明
最后更新：2026年10月5日
VitaCase 仅用于个人健康资料整理，不属于医疗器械。
任何药物的使用、剂量和服用时间必须始终遵循执业医生的医嘱。
VitaCase 不是官方预约系统，不能替代医院或诊所的正式通知。
由于设备系统设置、系统限制或电池优化，通知可能会延迟或无法送达。
VitaCase 不提供急救服务。遇到紧急医疗情况，请立即拨打当地急救电话。
""";

  static const String _disclaimerJa = """
免責事項
最終更新日：2026年10月5日
VitaCaseは個人の情報整理のみを目的としており、医療機器ではありません。
医薬品の使用、用量、および服用時間は、必ず資格を持つ医師や医療従事者の指示に従ってください。
VitaCaseは公的な予約システムではなく、病院やクリニックからの公式な通知に代わるものではありません。
通知は端末の設定、OSの制限、バッテリー最適化などにより遅延または届かない場合があります。
VitaCaseは緊急通報サービスではありません。緊急の場合は、直ちに現地の救急通報を行ってください。
""";

  static const String _disclaimerKo = """
의료 면책 조항
마지막 업데이트: 2026년 10월 5일
VitaCase는 개인 건강 기록 정리용 앱이며, 의료 기기가 아닙니다.
약물 복용, 용량 및 시기는 반드시 자격을 갖춘 의료 전문가의 지침을 따라야 합니다.
VitaCase는 공식 예약 시스템이 아니며 병원이나 클리닉의 공식 통지를 대신할 수 없습니다.
알림은 기기 설정, OS 제한 또는 배터리 최적화로 인해 지연되거나 실패할 수 있습니다.
VitaCase는 응급 서비스가 아닙니다. 응급 상황 시 즉시 현지 응급 의료 기관에 연락하십시오.
""";

  static const String _privacyPolicyIt = """
INFORMATIVA SULLA PRIVACY
Ultimo aggiornamento: 5 ottobre 2026

VitaCase è un'applicazione mobile gratuita per organizzare documenti personali e promemoria sanitari sul tuo dispositivo.

1. DATI CHE RIMANGONO SUL DISPOSITIVO
- Documenti, note, promemoria farmaci, appuntamenti e dati del profilo sono memorizzati localmente sul dispositivo.
- I file caricati vengono crittografati localmente (AES-256-GCM).
- Non archiviamo né sincronizziamo i tuoi documenti sanitari su server cloud remoti.

2. DATI TECNICI ED ESTERNI
- Firebase, Crashlytics e Sentry possono ricevere diagnostica tecnica e rapporti sugli errori.
- Google AdMob può ricevere identificatori pubblicitari e dati a livello di dispositivo.

3. COSA NON VIENE TRASMESSO
- Nessun nome di documento, nota medica, nome di medico o nome di farmaco viene inviato come payload di analisi.

4. ESCLUSIONE DI RESPONSABILITÀ MEDICA
VitaCase non è un dispositivo medico e non fornisce diagnosi, trattamenti o consulenza clinica.
""";

  static const String _privacyPolicyHi = """
गोपनीयता नीति
अंतिम अपडेट: 5 अक्टूबर 2026

VitaCase आपके डिवाइस पर व्यक्तिगत स्वास्थ्य संबंधी दस्तावेज़ों और अनुस्मारकों को व्यवस्थित करने के लिए एक निःशुल्क मोबाइल ऐप है।

1. डिवाइस पर क्या रहता है
- दस्तावेज़, नोट्स, दवा अनुस्मारक, अपॉइंटमेंट और प्रोफ़ाइल डेटा आपके डिवाइस पर स्थानीय रूप से संग्रहीत होते हैं।
- अपलोड की गई फ़ाइलें स्थानीय रूप से एन्क्रिप्ट की जाती हैं (AES-256-GCM)।
- हम आपके दस्तावेज़ों के लिए किसी रिमोट क्लाउड बैकअप का संचालन नहीं करते हैं।

2. डिवाइस से क्या तकनीकी डेटा जा सकता है
- Firebase Analytics और Crashlytics तकनीकी उपयोग और क्रैश रिपोर्ट प्राप्त कर सकते हैं।
- Sentry तकनीकी त्रुटि संदर्भ प्राप्त कर सकता है।
- AdMob विज्ञापन अनुरोध और डिवाइस-स्तरीय विज्ञापन पहचानकर्ता प्राप्त कर सकता है।

3. टेलीमेट्री में क्या शामिल नहीं है
- विश्लेषण पेलोड के रूप में कोई दस्तावेज़ नाम, मेडिकल नोट्स या दवाओं के नाम नहीं भेजे जाते हैं।

4. चिकित्सा अस्वीकरण
VitaCase कोई चिकित्सा उपकरण नहीं है और यह निदान, उपचार या नैदानिक सहायता प्रदान नहीं करता है।
""";

  static const String _termsIt = """
TERMINI E CONDIZIONI
Ultimo aggiornamento: 5 ottobre 2026

1. ACCETTAZIONE DEI TERMINI
Scaricando o utilizzando VitaCase, accetti i presenti Termini e Condizioni forniti da Limanex Software.

2. FINALITÀ DEL SERVIZIO
VitaCase è un'applicazione di organizzazione personale e archiviazione locale. Non è un fornitore di assistenza sanitaria né un dispositivo medico.

3. RESPONSABILITÀ SUI FARMACI E APPUNTAMENTI
L'utente è l'unico responsabile della verifica di dosaggi, orari e istruzioni con il proprio medico curante o farmacista. I promemoria locali possono subire ritardi a causa delle impostazioni di sistema o ottimizzazioni della batteria.

4. NON PER EMERGENZE
In caso di emergenza medica, contatta immediatamente il numero di soccorso locale (es. 112).
""";

  static const String _termsHi = """
नियम एवं शर्तें
अंतिम अपडेट: 5 अक्टूबर 2026

1. शर्तों की स्वीकृति
VitaCase डाउनलोड या उपयोग करके, आप Limanex Software द्वारा प्रदान किए गए इन नियमों और शर्तों से बाध्य होने के लिए सहमत होते हैं।

2. सेवा का विवरण
VitaCase एक व्यक्तिगत संगठन और स्थानीय भंडारण उपयोगिता है। यह कोई स्वास्थ्य सेवा प्रदाता या प्रमाणित चिकित्सा उपकरण नहीं है।

3. दवा और अपॉइंटमेंट की जिम्मेदारी
उपयोगकर्ता अपने चिकित्सक या फार्मासिस्ट के साथ दवा के नाम, खुराक और समय की पुष्टि करने के लिए पूरी तरह जिम्मेदार हैं। ऑपरेटिंग सिस्टम बैटरी अनुकूलन या अनुमतियों के कारण स्थानीय सूचनाएं विलंबित हो सकती हैं।

4. आपातकालीन स्थितियों के लिए नहीं
आपातकालीन स्थिति में तुरंत स्थानीय आपातकालीन सेवाओं (जैसे 112) से संपर्क करें।
""";

  static const String _disclaimerIt = """
ESCLUSIONE DI RESPONSABILITÀ MEDICA
Ultimo aggiornamento: 5 ottobre 2026
VitaCase è destinato esclusivamente a scopi organizzativi personali e non costituisce un dispositivo medico.
L'assunzione, il dosaggio e gli orari dei farmaci devono sempre basarsi sulle indicazioni di operatori sanitari qualificati.
VitaCase non è un sistema di prenotazione ufficiale e non sostituisce gli avvisi formali di ospedali o cliniche.
I promemoria possono subire ritardi, essere bloccati o non comparire a causa delle impostazioni del dispositivo, limitazioni del sistema operativo o ottimizzazioni della batteria.
VitaCase non è un servizio di emergenza. In caso di emergenza, contatta immediatamente il pronto soccorso locale (112).
""";

  static const String _disclaimerHi = """
चिकित्सा अस्वीकरण
अंतिम अपडेट: 5 अक्टूबर 2026
VitaCase केवल व्यक्तिगत संगठन के उद्देश्यों के लिए है और यह कोई चिकित्सा उपकरण नहीं है।
दवा का उपयोग, खुराक और समय हमेशा योग्य स्वास्थ्य पेशेवरों के निर्देशों पर आधारित होना चाहिए।
VitaCase कोई आधिकारिक बुकिंग प्रणाली नहीं है और यह अस्पतालों या क्लीनिकों की आधिकारिक सूचनाओं का स्थान नहीं लेता है।
डिवाइस सेटिंग्स, ऑपरेटिंग सिस्टम प्रतिबंधों या बैटरी अनुकूलन के कारण अनुस्मारक सूचनाएं विलंबित या विफल हो सकती हैं।
VitaCase कोई आपातकालीन सेवा नहीं है। आपात स्थिति में तुरंत अपनी स्थानीय आपातकालीन सेवा से संपर्क करें।
""";
}

