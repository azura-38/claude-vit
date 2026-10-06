# Google Play Data Safety Declaration & Compliance Audit
**Application:** VitaCase  
**Package Name:** `com.limanex.vitacase`  
**App Version:** `1.1.7+27`  
**Legal Version:** `1.1.7-2026-10`  
**Developer:** Limanex Software (`limanexsoftware@outlook.com`)  
**Audit Date:** October 5, 2026  

---

## 1. Executive Summary

VitaCase is engineered as a **privacy-first, offline-first personal document vault**. All sensitive health records, prescriptions, lab results, medication schedules, appointment calendars, emergency data, and profile details are encrypted (**AES-256-GCM**) and stored strictly on the user's physical device in private application sandboxed storage. 

**VitaCase operates zero consumer cloud databases, zero remote backups, and zero server-side user accounts.**

The only data transmitted off-device consists of non-personal technical telemetry, crash logs, and advertising request data handled by vetted industry-standard SDKs (Google Firebase, Sentry, and Google AdMob).

---

## 2. Play Console Data Safety Questionnaire Mapping

### A. Data Collection and Security Overview
| Question | App Answer | Technical Justification |
| :--- | :--- | :--- |
| **Does your app collect or share any of the required user data types?** | **Yes** | Technical diagnostic logs (Crashlytics, Sentry), aggregated usage events (Firebase Analytics), and device advertising IDs (AdMob) are processed. |
| **Is all of the user data collected by your app encrypted in transit?** | **Yes** | All SDK network communication with Google and Sentry servers is enforced over TLS/HTTPS. |
| **Do you provide a way for users to request that their data be deleted?** | **Yes** | 1. In-app instant complete wipe (`WipeService.fullWipe()`).<br>2. App uninstallation (purges sandbox).<br>3. Dedicated email request mechanism (`limanexsoftware@outlook.com`). |

---

### B. Detailed Data Category Declarations

#### 1. Health and Fitness
| Data Type | Collected? | Shared? | Purpose | Handling & Storage |
| :--- | :--- | :--- | :--- | :--- |
| **Health info** (medical records, prescriptions, medications, lab tests, blood type) | **NO** | **NO** | Not collected by developer | Stored strictly locally on terminal device inside an AES-256-GCM encrypted vault. Never transmitted to developer or third parties. |
| **Fitness info** (height, weight, BMI metrics) | **NO** | **NO** | Not collected by developer | Processed and stored exclusively on-device in local encrypted database. |

#### 2. Personal Info
| Data Type | Collected? | Shared? | Purpose | Handling & Storage |
| :--- | :--- | :--- | :--- | :--- |
| **Name** | **NO** | **NO** | N/A | Stored locally in on-device database for profile display only. |
| **Email address** | **NO** | **NO** | N/A | No user registration or login required. |
| **User IDs** | **NO** | **NO** | N/A | No account system. |
| **Address, Phone number** | **NO** | **NO** | N/A | Never collected. |

#### 3. Photos and Videos / Files and Docs
| Data Type | Collected? | Shared? | Purpose | Handling & Storage |
| :--- | :--- | :--- | :--- | :--- |
| **Files and documents** (PDFs, images) | **NO** | **NO** | Personal vault | Encrypted locally before filesystem write. Never sent off-device. |

#### 4. App Activity
| Data Type | Collected? | Shared? | Purpose | Handling & Storage |
| :--- | :--- | :--- | :--- | :--- |
| **App interactions** (screen views, feature taps, button clicks) | **YES** | **Shared with Google** (Firebase Analytics) | Analytics, App functionality | Aggregated, pseudonymous. Does NOT contain document names, doctor names, or medication details. |

#### 5. App Info and Performance
| Data Type | Collected? | Shared? | Purpose | Handling & Storage |
| :--- | :--- | :--- | :--- | :--- |
| **Crash logs** | **YES** | **Shared with Google & Sentry** | Diagnostics, Crash reporting | Stack traces and device state at crash. Handled via Firebase Crashlytics and Sentry. |
| **Diagnostics** | **YES** | **Shared with Sentry** | Performance & stability | Technical system context. |

#### 6. Device or Other Identifiers
| Data Type | Collected? | Shared? | Purpose | Handling & Storage |
| :--- | :--- | :--- | :--- | :--- |
| **Device or other IDs** (Ad ID, App Set ID) | **YES** | **Shared with Google** (AdMob) | Advertising & Marketing, Fraud prevention | Handled by Google Mobile Ads SDK. Gated by Google UMP consent form in EEA/UK/CH. Ad display is fully blocked until legal terms are accepted. |

---

## 3. Privacy Policy & Legal Links Verification
* **Target Public Privacy Policy URL:** `https://limanexstudio.com/privacy/vitacase`
* **Target Public Terms of Service URL:** `https://limanexstudio.com/terms/vitacase`
* **Target Public Medical Disclaimer URL:** `https://limanexstudio.com/disclaimer/vitacase`
* **In-App Direct Legal Access:**
  - `PrivacyPolicyScreen` (`assets/legal/privacy_policy.md`)
  - `TermsConditionsScreen` (`assets/legal/terms_of_service.md`)
  - `DisclaimerScreen` (`assets/legal/disclaimer.md`)
  - `KvkkScreen` (`assets/legal/kvkk.md`)
  - `DataDeletionScreen` (`assets/legal/data_deletion.md`)

---

## 4. Play Console & External Verification Notes
* **Console Submission Required**: This document constitutes an accurate internal mapping based on verified codebase architecture. It must be manually matched to the live Google Play Console Data Safety questionnaire prior to release.
* **External Website Verification**: The public domain `limanexstudio.com` was verified live. The web route `https://limanexstudio.com/privacy/vitacase` is reachable; however, its published text currently reflects a previous draft (May 2026) and must be synchronized with the updated October 5, 2026 policy (`assets/legal/privacy_policy.md`) on the web server prior to public release.
* **Health Data "No Collection" Justification**: Under Google Play Data Safety policies, "collection" refers exclusively to off-device transmission to the developer or third parties. Because VitaCase stores health records, prescriptions, and medical files strictly inside an on-device encrypted sandbox (AES-256-GCM) with zero remote sync or upload, Health and Fitness data collection is accurately reported as "No".


