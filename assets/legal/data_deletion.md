# VITACASE – DATA RETENTION & DELETION POLICY

**Last updated: October 5, 2026**
**Version: 1.1.7-2026-10 (App Version: 1.1.7+27)**

This Data Retention and Deletion Policy describes how your data is managed, stored, and deleted when you use the VitaCase mobile application ("App", "Service"), provided by **Limanex Software** ("we", "us", or "our").

---

## 1. 📂 LOCAL-FIRST DATA ARCHITECTURE

VitaCase operates under an **offline-first, local storage** architecture:
* **No Cloud Accounts or Remote Storage**: Your personal documents, health records, prescriptions, medications, appointment details, and vital health logs are stored and encrypted (**AES-256-GCM**) **locally on your device**.
* **Zero Remote Copies**: Limanex Software does not maintain central servers, cloud backups, or remote copies of your stored files and databases.
* **Sole User Custody**: You maintain exclusive physical and logical custody over all personal and medical information entered into the App.

---

## 2. 🗑️ DATA DELETION METHODS AVAILABLE TO USERS

VitaCase gives you complete autonomy to delete your information at any time:

### A. Selective Manual Deletion
You can manually delete individual items directly within the App:
* **Documents & Files**: Swipe or open any document and select "Delete" to permanently remove the file from your local encrypted vault.
* **Medications**: Delete or archive individual medication records and their associated dosage schedules.
* **Appointments**: Remove past or upcoming appointment entries and cancel their associated local notifications.
* **Profile & Health Data**: Edit or clear health metrics, emergency contact details, and personal notes.

### B. In-App Complete Data Wipe ("Verileri Temizle" / "Wipe All Data")
Located in **Settings → Security & Data**:
* **Database Purge**: Permanently deletes the local Sembast database containing all your records, metadata, appointments, and medication schedules.
* **File Vault Purge**: Completely deletes all stored, uploaded, and cached encrypted files from the device's application documents directory (`/documents`).
* **Cryptographic Key Purge**: Wipes the master encryption key and authentication salts from the device's secure hardware keystore (`FlutterSecureStorage`).
* **Cache & Temp Clean**: Removes temporary files and preview caches.
* **Notification Cancellation**: Cancels all scheduled local reminders and notifications.
* *Note on basic preferences*: Essential UI preferences (such as selected language and theme) are preserved to allow the App to restart cleanly.

### C. Application Uninstallation
* Uninstalling VitaCase via your operating system settings permanently removes the application's isolated private data storage sandbox.
* All encrypted vault files, databases, cached documents, and locally stored preferences are permanently and irrecoverably erased by the device operating system.

---

## 3. ⚠️ IMPORTANT LIMITATIONS: THIRD-PARTY DATA & LOGS

While the in-app "Wipe All Data" feature and app uninstallation completely purge all local user data and documents from your device, **they do not automatically delete telemetry and technical logs that may have been transmitted to third-party services**:

* **Google Firebase (Analytics & Crashlytics)**: Aggregated usage statistics and anonymized crash traces transmitted to Google servers are retained in accordance with Google's standard retention cycles (typically 2 to 14 months for analytics, 90 days for crash logs). The in-app wipe cannot reach or delete records residing on Google servers.
* **Sentry**: Real-time error diagnostic logs sent to Sentry are retained in accordance with Sentry's data retention policy (typically 30 to 90 days) and are not automatically erased by a local device wipe.
* **Google AdMob**: Device-level advertising interactions and frequency capping records managed by Google Mobile Ads SDK follow Google's advertising policies. Users can reset their Advertising Identifier or revoke consent via device system settings or the in-app consent options.

---

## 4. 📬 FORMAL DATA DELETION REQUESTS (GDPR / KVKK)

If you have questions regarding technical telemetry, or wish to exercise your statutory rights under GDPR (Article 17 — Right to Erasure) or KVKK (Article 11 — Deletion and Destruction of Personal Data):

📧 **Email**: limanexsoftware@outlook.com
**Subject**: Data Deletion Request — VitaCase

Please note that because VitaCase does not collect your name, email, or cloud account credentials, you may need to provide your technical device identifier (or installation ID) so that we can verify whether any non-personal diagnostic logs can be identified and purged from third-party developer consoles.

---

## 5. 🔄 UPDATES TO THIS POLICY

We may update this Data Retention & Deletion Policy periodically. Any modifications will be reflected with an updated date at the top of this document.
