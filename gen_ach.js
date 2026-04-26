const fs = require('fs');

// Mocking require for the TS file if needed, or just parsing it.
// Actually, I'll just hardcode the data from the previous output since I have it.

const achievements = [
  { id: "login_1", title_en: "Early Bird", desc_en: "Log in for the first time.", title_tr: "Hoş Geldin", desc_tr: "Kapıyı itip içeri ilk adımını attın." },
  { id: "login_3", title_en: "3 Day Streak", desc_en: "Log in for 3 consecutive days.", title_tr: "İstikrarlı", desc_tr: "Üst üste 3 gün boyunca bizimleydin." },
  { id: "login_7", title_en: "Week One", desc_en: "Log in for 7 consecutive days.", title_tr: "Haftalık Serüven", desc_tr: "Tam bir haftayı devirdin!" },
  { id: "login_14", title_en: "Two Weeks", desc_en: "Log in for 14 consecutive days.", title_tr: "On Dört Gün", desc_tr: "İki hafta boyunca hiç aksatmadın." },
  { id: "login_30", title_en: "Monthly Habit", desc_en: "Log in for 30 consecutive days.", title_tr: "Aylık Alışkanlık", desc_tr: "Artık bu iş sende bir alışkanlık oldu." },
  { id: "login_60", title_en: "Dedicated User", desc_en: "Log in for 60 consecutive days.", title_tr: "Adanmış", desc_tr: "İki aydır durdurulamıyorsun!" },
  { id: "login_100", title_en: "100 Day Hero", desc_en: "Log in for 100 consecutive days.", title_tr: "100 Günlük Kahraman", desc_tr: "Dile kolay, tam 100 gün!" },
  { id: "login_200", title_en: "Bicentennial", desc_en: "Log in for 200 consecutive days.", title_tr: "Çift Dalya", desc_tr: "200 gün boyunca buradaydın." },
  { id: "login_365", title_en: "Legendary Year", desc_en: "Log in for an entire year.", title_tr: "Efsanevi Yıl", desc_tr: "Tam bir yıl boyunca her gün bizimleydin. İnanılmaz!" },
  
  { id: "ads_1", title_en: "First Ad", desc_en: "Watch your first ad.", title_tr: "İlk Reklam", desc_tr: "Sisteme ilk katkını yaptın." },
  { id: "ads_5", title_en: "Ad Small Talk", desc_en: "Watch 5 ads.", title_tr: "Reklam Sohbeti", desc_tr: "Reklamlarla aran iyi görünüyor." },
  { id: "ads_15", title_en: "Ad Enthusiast", desc_en: "Watch 15 ads.", title_tr: "Reklam Meraklısı", desc_tr: "On beş reklamı geride bıraktın." },
  { id: "ads_30", title_en: "Bronze Viewer", desc_en: "Watch 30 ads.", title_tr: "Bronz İzleyici", desc_tr: "Otuzuncu reklamını izledin." },
  { id: "ads_50", title_en: "Silver Viewer", desc_en: "Watch 50 ads.", title_tr: "Gümüş İzleyici", desc_tr: "Ellinci reklamını kutlarız!" },
  { id: "ads_100", title_en: "Gold Viewer", desc_en: "Watch 100 ads.", title_tr: "Altın İzleyici", desc_tr: "Tam 100 reklam. Harikasın!" },
  { id: "ads_250", title_en: "Platinum Viewer", desc_en: "Watch 250 ads.", title_tr: "Platin İzleyici", desc_tr: "250 reklam izleyerek rekor kırdın." },
  { id: "ads_500", title_en: "Ad Mastery", desc_en: "Watch 500 ads.", title_tr: "Reklam Ustası", desc_tr: "Sen bir reklam ustasısın!" },
  
  { id: "doc_1", title_en: "First Doc", desc_en: "Upload your first document.", title_tr: "İlk Belge", desc_tr: "Sisteme ilk belgeni yükledin." },
  { id: "doc_5", title_en: "Helper Hand", desc_en: "Upload 5 documents.", title_tr: "Yardımcı El", desc_tr: "Beş belgeyle arşivin büyüyor." },
  { id: "doc_10", title_en: "Organizer", desc_en: "Upload 10 documents.", title_tr: "Düzenleyici", desc_tr: "Düzenleme işini ciddiye alıyorsun." },
  { id: "doc_25", title_en: "Archive Keeper", desc_en: "Upload 25 documents.", title_tr: "Arşiv Bekçisi", desc_tr: "Yirmi beş belge! Tam bir arşiv." },
  { id: "doc_50", title_en: "Silver Archives", desc_en: "Upload 50 documents.", title_tr: "Gümüş Arşiv", desc_tr: "Ellinci belgeni başarıyla ekledin." },
  { id: "doc_100", title_en: "Gold Archives", desc_en: "Upload 100 documents.", title_tr: "Altın Arşiv", desc_tr: "Yüz belgeye ulaştın!" },
  { id: "doc_250", title_en: "Platinum Archives", desc_en: "Upload 250 documents.", title_tr: "Platin Arşiv", desc_tr: "250 belge. Muazzam bir kapasite!" },
  { id: "doc_500", title_en: "Archive Master", desc_en: "Upload 500 documents.", title_tr: "Arşiv Ustası", desc_tr: "Sistemin en büyük arşivi senin!" },

  { id: "med_1", title_en: "Medicine Begun", desc_en: "Add your first medication.", title_tr: "İlaç Takibi", desc_tr: "İlk ilacını sisteme ekledin." },
  { id: "med_3", title_en: "Routine Check", desc_en: "Add 3 medications.", title_tr: "Rutin Kontrol", desc_tr: "Üç farklı ilacı takip ediyorsun." },
  { id: "med_5", title_en: "Caregiver", desc_en: "Add 5 medications.", title_tr: "Bakım Veren", desc_tr: "Beş ilacı düzenli takip ediyorsun." },
  { id: "med_10", title_en: "Care Master", desc_en: "Add 10 medications.", title_tr: "Bakım Ustası", desc_tr: "On ilacı başarıyla yönetiyorsun." },
  { id: "med_25", title_en: "Med Guru", desc_en: "Add 25 medications.", title_tr: "İlaç Gurusu", desc_tr: "Tam 25 ilaç! Büyük sorumluluk." },
  { id: "med_50", title_en: "Pharmacy Hero", desc_en: "Add 50 medications.", title_tr: "Eczane Kahramanı", desc_tr: "50 ilaç! Sen bir kahramansın." },

  { id: "app_1", title_en: "First Appt", desc_en: "Create your first appointment.", title_tr: "İlk Randevu", desc_tr: "Randevu defterini açtın." },
  { id: "app_3", title_en: "Busy Week", desc_en: "Create 3 appointments.", title_tr: "Yoğun Hafta", desc_tr: "Üç randevuyla haftan doluyor." },
  { id: "app_5", title_en: "Organizer", desc_en: "Create 5 appointments.", title_tr: "Organizatör", desc_tr: "Beş randevuyu planladın." },
  { id: "app_10", title_en: "Schedule Master", desc_en: "Create 10 appointments.", title_tr: "Program Ustası", desc_tr: "On randevuyu kusursuz yönettin." },
  { id: "app_20", title_en: "Planning King", desc_en: "Create 20 appointments.", title_tr: "Planlama Kralı", desc_tr: "Yirmi randevu! Harika." },
  { id: "app_30", title_en: "Master of Time", desc_en: "Create 30 appointments.", title_tr: "Zamanın Efendisi", desc_tr: "Otuz randevuyu koordine ettin." },

  { id: "profile_created", title_en: "Profile Setup", desc_en: "Create your user profile.", title_tr: "Profil Hazır", desc_tr: "Kendini sisteme tanıttın." },
  { id: "profile_completed", title_en: "Full Identity", desc_en: "Fill in all profile details.", title_tr: "Tam Kimlik", desc_tr: "Tüm profil bilgilerini doldurdun." },
  { id: "profile_updated", title_en: "Stay Fresh", desc_en: "Update your profile info.", title_tr: "Güncel", desc_tr: "Bilgilerini güncel tutuyorsun." },
  { id: "profile_with_photo", title_en: "Personalized", desc_en: "Add a profile photo.", title_tr: "Kişiselleştirme", desc_tr: "Profiline bir yüz verdin." },
  { id: "profile_master", title_en: "Profile Master", desc_en: "Complete your profile identity.", title_tr: "Profil Ustası", desc_tr: "Profilin artık tam ve eksiksiz." },

  { id: "emergency_added", title_en: "Safe First", desc_en: "Add an emergency contact.", title_tr: "Önce Güvenlik", desc_tr: "Bir acil durum kişisi ekledin." },
  { id: "emergency_contact", title_en: "Liaison", desc_en: "Set up your emergency liaison.", title_tr: "İrtibat", desc_tr: "Acil durum irtibatını kurdun." },
  { id: "emergency_complete", title_en: "Fully Shielded", desc_en: "Complete emergency profile.", title_tr: "Tam Kalkan", desc_tr: "Acil durum profilini tamamladın." },
  { id: "emergency_ready", title_en: "Safe & Ready", desc_en: "Be ready for emergencies.", title_tr: "Güvenli ve Hazır", desc_tr: "Tüm önlemlerini aldın." },
  { id: "emergency_master", title_en: "Guardian", desc_en: "Become an emergency master.", title_tr: "Muhafız", desc_tr: "Güvenlik konusunda bir numarasın." },

  { id: "health_1", title_en: "Heart Beat", desc_en: "Add your first health data.", title_tr: "Kalp Atışı", desc_tr: "İlk sağlık verisini kaydettin." },
  { id: "health_5", title_en: "Vitals Check", desc_en: "Add 5 health records.", title_tr: "Hayati Bulgular", desc_tr: "Beş sağlık kaydını tamamladın." },
  { id: "health_10", title_en: "Health Tracker", desc_en: "Add 10 health records.", title_tr: "Sağlık Takibi", desc_tr: "On sağlık kaydını geride bıraktın." },
  { id: "health_20", title_en: "Bio-Watcher", desc_en: "Add 20 health records.", title_tr: "Biyo-İzleyici", desc_tr: "20 kayıtla vücudunu tanıyorsun." },
  { id: "health_50", title_en: "Health Enthusiast", desc_en: "Add 50 health records.", title_tr: "Sağlık Meraklısı", desc_tr: "Sarsılmaz bir takip düzenin var!" },
  { id: "health_master", title_en: "Master of Health", desc_en: "Maintain full health data.", title_tr: "Sağlığın Efendisi", desc_tr: "Kendi sağlığın üzerinde tam hakimsin." },

  { id: "first_login", title_en: "Welcome", desc_en: "Enter VitaCase for the first time.", title_tr: "Hoş Geldiniz", desc_tr: "VitaCase dünyasına ilk adımı attın." },
  { id: "first_upload", title_en: "Explorer", desc_en: "First file uploaded.", title_tr: "Kaşif", desc_tr: "Sisteme ilk dosyanı yükledin." },
  { id: "first_ad", title_en: "Contributor", desc_en: "Interact with an ad.", title_tr: "Katkıda Bulunan", desc_tr: "İlk reklam etkileşimini yaptın." },
  { id: "first_premium", title_en: "Premium Join", desc_en: "Unlock premium features.", title_tr: "Premium Üye", desc_tr: "Sınırları kaldırdın!" },
  { id: "active_3_days", title_en: "Stayer", desc_en: "Be active for 3 days.", title_tr: "Kalıcı", desc_tr: "Üç gün boyunca bizimleydin." },
  { id: "active_7_days", title_en: "Loyal User", desc_en: "Be active for 7 days.", title_tr: "Sadık Kullanıcı", desc_tr: "Bir haftalık sadakatini kanıtladın." },
  { id: "active_30_days", title_en: "Core Fan", desc_en: "Be active for 30 days.", title_tr: "Sıkı Takipçi", desc_tr: "Tam bir ay boyunca aktiftin." },

  { id: "streak_saved", title_en: "Savior", desc_en: "Save a broken streak.", title_tr: "Kurtarıcı", desc_tr: "Serini bozulmaktan kurtardın." },
  { id: "streak_saved_5", title_en: "Guardian Angel", desc_en: "Save your streak 5 times.", title_tr: "Koruyucu Melek", desc_tr: "Serini 5 kez ipten aldın!" },
  { id: "streak_saved_10", title_en: "Resilient", desc_en: "Save your streak 10 times.", title_tr: "Dirençli", desc_tr: "En zor anlarda bile pes etmedin." },
  { id: "streak_perfect_30", title_en: "Perfect Month", desc_en: "Maintain streak for 30 days.", title_tr: "Kusursuz Ay", desc_tr: "Hiç bozmadan bir ayı tamamladın." },

  { id: "premium_trial_used", title_en: "Taster", desc_en: "Try a premium trial.", title_tr: "Tadımcı", desc_tr: "Premium dünyasına bir göz attın." },
  { id: "limit_breaker", title_en: "Unbound", desc_en: "Break a storage limit.", title_tr: "Sınırsız", desc_tr: "Depolama sınırlarını aştın!" },
  { id: "ad_skip_used", title_en: "Skipper", desc_en: "Use an ad-skip token.", title_tr: "Kaptan", desc_tr: "Zamanı verimli kullandın." },
  { id: "reward_collector", title_en: "Bounty Hunter", desc_en: "Collect 10 rewards.", title_tr: "Ödül Avcısı", desc_tr: "Tüm ödülleri tek tek topluyorsun." },

  { id: "multi_feature_user", title_en: "Power User", desc_en: "Use all core features.", title_tr: "Güçlü Kullanıcı", desc_tr: "Her özelliği tek tek keşfettin." },
  { id: "data_master", title_en: "Data Master", desc_en: "Master your medical data.", title_tr: "Veri Uzmanı", desc_tr: "Tüm sağlık verilerin kontrol altında." },
  { id: "organized_master", title_en: "Organized", desc_en: "Maintain perfect records.", title_tr: "Ultra Düzenli", desc_tr: "Her belgen yerli yerinde." },
  { id: "security_master", title_en: "Iron Vault", desc_en: "Secure your entire account.", title_tr: "Demir Kasa", desc_tr: "Hesabın tam bir kale gibi." },
  { id: "daily_master", title_en: "Daily Hero", desc_en: "30 days of mastery.", title_tr: "Günlük Kahraman", desc_tr: "30 gün boyunca her işi başardın." },
];

let output = "";
// generate EN
output += "// English Achievement Titles & Descs\n";
achievements.forEach(a => {
  output += `      'ach_${a.id}_title': '${a.title_en}',\n`;
  output += `      'ach_${a.id}_desc': '${a.desc_en}',\n`;
});

output += "\n// Turkish Achievement Titles & Descs\n";
achievements.forEach(a => {
  output += `      'ach_${a.id}_title': '${a.title_tr}',\n`;
  output += `      'ach_${a.id}_desc': '${a.desc_tr}',\n`;
});

fs.writeFileSync('c:/Users/olum3/OneDrive/Masaüstü/vit-case/ach_strings.txt', output);
