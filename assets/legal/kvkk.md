# 6698 SAYILI KİŞİSEL VERİLERİN KORUNMASI KANUNU (KVKK) AYDINLATMA METNİ

**Son Güncelleme: 5 Ekim 2026**
**Sürüm: 1.1.7-2026-10 (Uygulama Sürümü: 1.1.7+27)**

Bu Aydınlatma Metni, 6698 sayılı Kişisel Verilerin Korunması Kanunu ("KVKK") ve ilgili mevzuat uyarınca, **Limanex Software** ("Veri Sorumlusu") tarafından geliştirilen **VitaCase** mobil uygulaması ("Uygulama") kullanıcılarının kişisel verilerinin işlenmesine ilişkin usul ve esasları açıklamak amacıyla hazırlanmıştır.

---

## 1. VERİ SORUMLUSUNUN KİMLİĞİ VE BİLGİLERİ

* **Veri Sorumlusu**: Limanex Software (Bağımsız Yazılım Geliştirici & Veri Sorumlusu)
* **İletişim & Başvuru E-posta**: limanexsoftware@outlook.com
* **Uygulama**: VitaCase (Android / iOS)
* **Tebligat Adresi**: [TODO: Kayıtlı İş Yeri / Tebligat Adresi — Tüzel kişilik veya resmi sicil kaydı tamamlandığında güncellenecektir]
* **MERSİS / Sicil No**: [TODO: MERSİS / Ticaret Sicil No — Bağımsız geliştirici faaliyeti kapsamında bulunmamaktadır; tüzel kişilik tesis edilmesi halinde eklenecektir]
* **KEP Adresi**: [TODO: Kayıtlı Elektronik Posta (KEP) Adresi — KEP kaydı yapılması halinde eklenecektir]
* **Yetkili Temsilci**: [TODO: Tüzel Kişi Temsilcisi — Gerektiğinde atanacaktır]
* **Başvuru Usulü**: Veri Sorumlusuna Başvuru Usul ve Esasları Hakkında Tebliğ uyarınca, elektronik posta adresi üzerinden yapılacak başvurular kabul edilmektedir.

---

## 2. YEREL DEPOLAMA MİMARİSİ VE KULLANICI VERİLERİNİN DURUMU

VitaCase uygulaması, **cihaz üzerinde yerel depolama (offline-first)** ve **uçtan uca yerel şifreleme (AES-256-GCM)** prensibiyle çalışmaktadır.

* **Sağlık ve Belge Verileri**: Uygulamaya kaydettiğiniz belgeler, tahlil sonuçları, reçeteler, ilaç listeleri, randevu notları, boy/kilo ve sağlık istatistikleri **Limanex Software sunucularına iletilmez, depolanmaz ve tarafımızca erişilemez**.
* Bu veriler doğrudan kullanıcının kendi mobil cihazının korumalı uygulama alanında (sandbox) şifrelenmiş olarak saklanır. Bu verilerin zilyetliği ve denetimi tamamen kullanıcının kendisindedir.
* **Biyometrik Veriler**: Uygulama içi kilit açma amacıyla kullanılan parmak izi veya yüz tanıma verileri doğrudan cihaz işletim sistemi (`local_auth`) tarafından yerel olarak işlenir; VitaCase biyometrik verilerinizi asla toplamaz, kaydetmez veya harici sunuculara göndermez.

---

## 3. İŞLENEN KİŞİSEL VERİ KATEGORİLERİ VE TOPLANMA YÖNTEMİ

Uygulamanın teknik olarak çalışabilmesi, kararlılığının sağlanması ve yasal uyumluluk amacıyla yalnızca sınırlı teknik veriler otomatik yollarla toplanmaktadır:

1. **Cihaz ve Bağlantı Bilgileri**: Cihaz modeli, işletim sistemi sürümü, donanım özellikleri, sistem dili ve IP adresi (Google Firebase ve AdMob SDK'ları aracılığıyla).
2. **Kullanım ve Tanılama Verileri**: Uygulama içi ekran etkileşimleri, hata kayıtları (crash reports), bellek ve performans istatistikleri (Google Firebase Analytics, Firebase Crashlytics ve Sentry aracılığıyla).
3. **Reklam Tanımlayıcıları**: Kişiselleştirilmiş veya kişiselleştirilmemiş reklam gösterimi amacıyla cihaz reklam kimliği (Google AdMob aracılığıyla, kullanıcı iznine tabi olarak).

---

## 4. KİŞİSEL VERİ İŞLEMENİN HUKUKİ SEBEPLERİ VE AMAÇLARI

Teknik ve tanılama verileri aşağıdaki amaçlarla işlenmektedir:
* Uygulamanın teknik işlevselliğinin, güvenliğinin ve kararlılığının sürdürülmesi (KVKK m. 5/2-f: Meşru menfaat),
* Yazılımsal hataların, çökmelerin tespiti ve giderilmesi (KVKK m. 5/2-f),
* Reklam ve gelir modeli yönetimi (kullanıcının rızası veya meşru menfaat kapsamında Google UMP üzerinden yönetilen tercihler),
* İlgili mevzuattan kaynaklanan hukuki yükümlülüklerin yerine getirilmesi (KVKK m. 5/2-ç).

---

## 5. KİŞİSEL VERİLERİN AKTARILDIĞI TARAFLAR

Kullanıcının girdiği kişisel sağlık kayıtları ve belgeleri **hiçbir üçüncü tarafa aktarılmaz**. Yalnızca teknik ve tanılama verileri yukarıda belirtilen amaçların gerçekleştirilmesi için sınırlı olarak aşağıdaki altyapı sağlayıcılarına aktarılabilmektedir:
* **Google LLC**: Firebase Analytics, Firebase Crashlytics ve Google AdMob hizmetleri kapsamında.
* **Functional Software, Inc. (Sentry)**: Hata raporlama ve kararlılık takibi hizmetleri kapsamında.

---

## 6. VERİ SAKLAMA SÜRESİ VE SİLME HAKKI

* VitaCase üzerinde saklanan yerel veriler kullanıcı tarafından istendiği zaman silinebilir.
* Kullanıcı, Uygulama Ayarları içerisindeki **"Verileri Temizle" (Wipe All Data)** fonksiyonunu kullanarak veya uygulamayı cihazından kaldırarak tüm şifreli yerel veritabanını kalıcı ve geri döndürülemez şekilde silebilir.
* Teknik loglar ve hata kayıtları ise üçüncü taraf sistemlerinde ilgili sağlayıcıların saklama politikalarına uygun süreler boyunca tutulmaktadır.

---

## 7. İLGİLİ KİŞİNİN HAKLARI (KVKK MADDE 11)

KVKK'nın 11. maddesi uyarınca kullanıcılarımız, Veri Sorumlusuna başvurarak kendileriyle ilgili:
1. Kişisel veri işlenip işlenmediğini öğrenme,
2. Kişisel verileri işlenmişse buna ilişkin bilgi talep etme,
3. Kişisel verilerin işlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme,
4. Yurt içinde veya yurt dışında kişisel verilerin aktarıldığı üçüncü kişileri bilme,
5. Kişisel verilerin eksik veya yanlış işlenmiş olması hâlinde bunların düzeltilmesini isteme,
6. KVKK'nın 7. maddesinde öngörülen şartlar çerçevesinde kişisel verilerin silinmesini veya yok edilmesini isteme,
7. Düzeltme, silme ve yok edilme işlemlerinin verilerin aktarıldığı üçüncü kişilere bildirilmesini isteme,
8. İşlenen verilerin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle kişinin kendisi aleyhine bir sonucun ortaya çıkmasına itiraz etme,
9. Kişisel verilerin kanuna aykırı olarak işlenmesi sebebiyle zarara uğraması hâlinde zararın giderilmesini talep etme

haklarına sahiptir.

---

## 8. BAŞVURU YÖNTEMİ

KVKK kapsamındaki haklarınıza ilişkin taleplerinizi:
* 📧 **E-posta**: limanexsoftware@outlook.com (Konu: "KVKK İlgili Kişi Başvurusu — VitaCase")
* 📮 **Yazılı İletişim**: Talebiniz üzerine mevzuat uyarınca kayıtlı e-posta kanalı üzerinden sağlanacak tebligat adresi

üzerinden iletebilirsiniz. Başvurunuzda Veri Sorumlusuna Başvuru Usul ve Esasları Hakkında Tebliğ uyarınca ad, soyad, başvuru yazılı ise imza, T.C. kimlik numarası (veya yabancılar için uyruk, pasaport numarası), tebligata esas yerleşim yeri veya iş yeri adresi, bildirime esas e-posta adresi ve talep konusunun bulunması gerekmektedir. Talepleriniz, niteliğine göre en kısa sürede ve en geç 30 (otuz) gün içinde ücretsiz olarak sonuçlandırılacaktır.
