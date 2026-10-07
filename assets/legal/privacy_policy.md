# VITACASE – PRIVACY POLICY

**Last updated: October 5, 2026**
**Version: 1.1.7-2026-10 (App Version: 1.1.7+27)**

This Privacy Policy describes how Limanex Software ("we", "us", or "our") collects, uses, stores, and protects your information when you use the VitaCase mobile application ("App", "Service").

---

## 1. 📱 ABOUT THE APPLICATION

VitaCase is a private, offline-first personal health and document organization application designed to help you organize your personal records on your device:

* **Encrypted Document Vault**: Store and organize personal documents, prescriptions, lab results, insurance files, and reports using on-device AES-256-GCM encryption.
* **Medication & Stock Tracking**: Log medications, dosages, inventory counts, schedules, and local reminders.
* **Appointment Management**: Keep track of upcoming doctor visits, lab appointments, and consultation schedules with local notifications.
* **Health Metrics & BMI**: Record physical statistics, vital metrics, and personal health logs locally.
* **Emergency & Important Information**: Keep blood type, emergency contacts, allergy lists, and key notes readily accessible on your device.

⚠️ **Important Medical Notice**:
VitaCase is an organizational utility tool only. VitaCase is **not** a healthcare provider, medical device, diagnostic system, or treatment advisor. The App does not provide medical advice, diagnosis, dosage recommendations, or healthcare services.

---

## 2. 📊 INFORMATION ARCHITECTURE & DATA COLLECTION

### A. Local Storage Only — No Cloud Accounts or Remote Document Storage
VitaCase operates on a **local-first** security model:
* **No Remote Accounts**: There are no cloud user accounts, remote registrations, or central logins.
* **No Cloud Sync**: Your documents, notes, appointments, medications, health measurements, and profile data are stored **strictly on your terminal device**. We have no access to your documents or files.
* **Authenticated Local Encryption at Rest**: Files and sensitive database records stored in the VitaCase vault are encrypted on-device using industry-standard authenticated **AES-256-GCM** encryption.

### B. Biometric Authentication & Device Security
* VitaCase allows you to secure the App using a 6-digit PIN and optional biometric authentication (fingerprint or facial recognition).
* Biometric authentication is executed entirely by your device operating system via local platform security APIs (`local_auth`).
* **VitaCase never collects, receives, reads, accesses, or transmits your biometric data**. The operating system only returns a local cryptographic confirmation of authentication success or failure.

### C. Information You Enter
All information within the app is entered voluntarily by you, including:
* Uploaded files, PDFs, and document images
* Medication schedules, dosages, and notes
* Appointment times, doctor names, and clinic locations
* Emergency contact numbers and profile details

We do not inspect, analyze, validate, or process your files or notes. Everything remains under your direct, physical control on your device.

### D. Automatically Collected Technical Data
To ensure stability, security, and app improvement, the App and its third-party developer SDKs may automatically collect limited technical and diagnostic data:
* **Device & Operating System Details**: Device model, manufacturer, OS version, app version, language, and system locale.
* **Diagnostic & Crash Logs**: Crash traces, memory events, and performance logs to identify and resolve software errors (processed via Google Firebase Crashlytics and Sentry).
* **Usage & Event Metrics**: Aggregated, non-personally identifiable app interaction metrics (such as screen visits and feature usage counts) via Google Firebase Analytics to improve user experience.
* **Network & Identifiers**: Device IP address and advertising/instance identifiers processed automatically by SDKs for network connectivity, crash reporting, and ad delivery.

---

## 3. 🧠 SENSITIVE HEALTH DATA DISCLAIMER

VitaCase enables you to store health records, medications, and medical appointment details:
* This data is stored **only on your device** in encrypted local storage.
* We do not transmit, analyze, profile, monetize, or share your health records or personal files with any party.
* You are the sole custodian of your health information.

---

## 4. ⏰ NOTIFICATIONS & REMINDERS

VitaCase provides on-device medication and appointment reminders:
* Reminders are scheduled locally on your device via the operating system's notification system (`flutter_local_notifications`).
* Reminders are provided solely as an informational convenience.
* Delivery of notifications may be delayed, silenced, suppressed, or prevented by operating system battery optimizations, Do Not Disturb modes, background restrictions, permission revocations, or device power states.
* **Never rely solely on VitaCase for life-critical medications or emergency appointments.**

---

## 5. 🚫 WHAT WE DO NOT DO

Limanex Software is committed to your privacy:
* ❌ We do **NOT** sell, rent, or trade your personal data.
* ❌ We do **NOT** access, view, or read your stored documents or photos.
* ❌ We do **NOT** use your health data for advertising, profiling, or behavioral targeting.
* ❌ We do **NOT** operate a central cloud database storing your records.
* ❌ We do **NOT** use artificial intelligence or automated decision-making on your medical records.

---

## 6. 📢 THIRD-PARTY SERVICES, DIAGNOSTICS & ADVERTISING

While your health records and vault files never leave your device, the App integrates vetted third-party software development kits (SDKs) strictly for error monitoring, performance diagnostics, aggregated analytics, and advertising:

* **Google AdMob (Google LLC)**: Displays in-app banner, interstitial, rewarded, and app-open advertisements to support the free tier of the App. AdMob processes device identifiers (such as the Google Advertising ID), coarse location, and interaction events. In jurisdictions requiring consent (such as the European Economic Area, UK, and Switzerland), user consent is gathered through the Google User Messaging Platform (UMP).
* **Google Firebase Analytics (Google LLC)**: Collects pseudonymous, aggregated usage statistics (such as screen transitions and feature usage counts) to help us understand app adoption. No health data, file names, or medication details are ever logged to Firebase Analytics.
* **Google Firebase Crashlytics (Google LLC)**: Collects diagnostic crash reports and device operating states when an unexpected software failure occurs, allowing us to debug and patch errors.
* **Sentry (Functional Software, Inc.)**: Captures real-time application exceptions and stack traces for software reliability and performance monitoring. Sentry receives an anonymized, randomly generated installation UUID (`app_user_uid`) to correlate crashes without identifying you personally.

### Cross-Border & International Data Transfers
These third-party service providers (Google LLC and Functional Software, Inc.) maintain infrastructure in the United States and globally. Data collected by their SDKs is transferred using recognized international transfer mechanisms, such as the EU-U.S. Data Privacy Framework and Standard Contractual Clauses (SCCs), ensuring an adequate level of data protection.

### Legal Bases for Processing (Under GDPR & International Regimes)
Where applicable under the EU General Data Protection Regulation (GDPR) or similar laws:
* **Legitimate Interests (Art. 6(1)(f) GDPR)**: Operating, maintaining, securing, and debugging the App via crash reporting (Crashlytics, Sentry) and aggregated product telemetry.
* **Consent (Art. 6(1)(a) GDPR)**: Displaying personalized advertising via Google AdMob (managed through Google UMP consent preferences).
* **Explicit Consent for Local Health Data (Art. 9(2)(a) GDPR)**: You provide explicit consent by voluntarily entering health and medical information into the local encrypted vault on your device.

---

## 7. ⏳ DATA RETENTION, BACKUP & DELETION

### Complete User Control Over Local Data
* **Manual Deletion**: You can delete individual documents, medications, appointments, or profile data at any time from within the App.
* **In-App Complete Data Wipe**: Selecting "Wipe All Data" / "Verileri Temizle" in Settings permanently erases the local Sembast database, encrypted file vault, cryptographic master keys from Secure Storage, and cancels all local notification schedules.
* **App Uninstallation**: Uninstalling VitaCase permanently purges the application's isolated private data storage sandbox.
* **Backup Responsibility**: Because VitaCase operates offline without cloud synchronization, we cannot restore lost records. You are solely responsible for keeping independent, secure backups of your critical documents.

### Third-Party Retention Periods
Technical diagnostic logs and aggregated telemetry transmitted to third-party SDKs are retained under the respective providers' retention policies:
* Firebase Analytics: Typically retained for 2 to 14 months (Google configurable standard).
* Firebase Crashlytics: Crash reports typically retained for 90 days.
* Sentry: Error logs typically retained for 30 to 90 days.

---

## 8. 🔐 DATA SECURITY & ENCRYPTION

We enforce robust, defense-in-depth security measures on your device:
* **AES-256-GCM Encryption**: All documents, PDFs, images, and sensitive database records in the vault are encrypted at rest on your device using authenticated AES-256-GCM.
* **Hardware-Backed Key Storage**: Cryptographic 256-bit master keys are generated via cryptographically secure random bytes and stored in hardware-backed secure storage (`FlutterSecureStorage` / Android Keystore / iOS Keychain).
* **PIN & Biometric Lock**: An optional 6-digit PIN and operating system biometric authentication gate prevent unauthorized physical access to the App.

*Limitation*: While local encryption protects your stored data from unauthorized apps, overall security also depends on keeping your device operating system updated and your device lock screen protected.

---

## 9. 👶 CHILDREN'S PRIVACY

VitaCase is designed for general audiences and is not directed at children under the age of 13 (or under 16 in the European Union / EEA). We do not knowingly collect personal data from children. If you become aware that a child has provided us with personal information, please contact us so we can take appropriate steps.

---

## 10. 🌍 REGIONAL DATA PROTECTION RIGHTS & COMPLIANCE

### A. European Economic Area (EEA), UK & Swiss Users (GDPR / UK GDPR)
If you reside in the EEA, UK, or Switzerland, you have the following rights regarding data processed by us or our processors:
* Right to access the personal/technical data held about you.
* Right to rectification or erasure of your data.
* Right to restrict or object to processing.
* Right to withdraw consent at any time (e.g., for advertising preferences via Google UMP).
* Right to lodge a complaint with your local data protection supervisory authority.

### B. California & United States Residents (CCPA / CPRA)
Under the California Consumer Privacy Act (CCPA) and California Privacy Rights Act (CPRA):
* **No Sale of Personal Information**: VitaCase does not sell, rent, or monetize your personal or health information to data brokers or third parties.
* **No Sharing of Health Data for Cross-Context Behavioral Advertising**: Your health data and vault files are never shared for advertising.
* You have the right to know what categories of technical data are collected and to request deletion of any personal telemetry.

### C. Türkiye Residents (KVKK Notice)
For users located in the Republic of Turkey, the processing of personal data is governed by the Turkish Personal Data Protection Law No. 6698 (KVKK). Please consult our dedicated, Türkiye-specific **KVKK Aydınlatma Metni** ([assets/legal/kvkk.md](file:///c:/Users/olum3/OneDrive/Masa%C3%BCst%C3%BC/vit-case-recovery/assets/legal/kvkk.md)), which is also accessible directly within the application settings for full statutory disclosures and formal application procedures.

---

## 11. 📬 CONTACT INFORMATION & DATA CONTROLLER

If you have questions, feedback, or privacy-related requests, please contact:

**Limanex Software**
* 📧 **Email**: limanexsoftware@outlook.com
* 🌐 **Application**: VitaCase (Android / iOS)
* 🏢 **Registered Address**: [TODO: Registered Business Address — To be provided upon corporate incorporation]
* 👤 **Legal Representative**: [TODO: Legal Representative — If corporate entity appointed]

---

## 12. 🔄 CHANGES TO THIS POLICY

We may update this Privacy Policy periodically to reflect app updates, legal requirements, or service improvements. When material changes occur, the "Last Updated" date will be updated, and existing users will be presented with a one-time update notice and consent screen within the App before continued access.
