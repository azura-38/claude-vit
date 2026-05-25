import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('tr'),
    Locale('zh')
  ];

  /// Translation for app_name
  ///
  /// In en, this message translates to:
  /// **'VitaCase'**
  String get app_name;

  /// Translation for skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Translation for next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Translation for start
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Translation for back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Translation for save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Translation for cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Translation for error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Translation for success
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Translation for loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Translation for active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Translation for inactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Translation for premium_feature
  ///
  /// In en, this message translates to:
  /// **'Premium Feature 🌟'**
  String get premium_feature;

  /// Translation for premium_required_desc
  ///
  /// In en, this message translates to:
  /// **'Premium membership is required for App Lock.'**
  String get premium_required_desc;

  /// Translation for go_premium
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get go_premium;

  /// Translation for index
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get index;

  /// Translation for view_weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get view_weekly;

  /// Translation for view_monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get view_monthly;

  /// Translation for phone_country_code
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get phone_country_code;

  /// Translation for coming_soon
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get coming_soon;

  /// Translation for coming_soon_desc
  ///
  /// In en, this message translates to:
  /// **'This feature will be available in the next update.'**
  String get coming_soon_desc;

  /// Translation for tap_for_test
  ///
  /// In en, this message translates to:
  /// **'Tap {count} more times for test notification'**
  String tap_for_test(int count);

  /// Translation for unit_ml
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unit_ml;

  /// Translation for unit_l
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unit_l;

  /// Translation for metric_water
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get metric_water;

  /// Translation for metric_steps
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get metric_steps;

  /// Translation for metric_sleep
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get metric_sleep;

  /// Translation for metric_heart_rate
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get metric_heart_rate;

  /// Translation for unit_steps
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get unit_steps;

  /// Translation for unit_hours
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get unit_hours;

  /// Translation for unit_bpm
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get unit_bpm;

  /// Translation for quick_actions_visibility
  ///
  /// In en, this message translates to:
  /// **'Quick Access Visibility'**
  String get quick_actions_visibility;

  /// Translation for personal_notes
  ///
  /// In en, this message translates to:
  /// **'Personal Notes'**
  String get personal_notes;

  /// Translation for save_and_list
  ///
  /// In en, this message translates to:
  /// **'Save and List'**
  String get save_and_list;

  /// Translation for doctor_info
  ///
  /// In en, this message translates to:
  /// **'Doctor Information'**
  String get doctor_info;

  /// Translation for add_doctor_desc
  ///
  /// In en, this message translates to:
  /// **'Keep your doctors contact info for quick access.'**
  String get add_doctor_desc;

  /// Translation for basic_info
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basic_info;

  /// Translation for institution_contact
  ///
  /// In en, this message translates to:
  /// **'Institution & Contact'**
  String get institution_contact;

  /// Translation for notes_bio
  ///
  /// In en, this message translates to:
  /// **'Notes & Bio'**
  String get notes_bio;

  /// Translation for unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Translation for hospital_clinic_name
  ///
  /// In en, this message translates to:
  /// **'Hospital / Clinic Name'**
  String get hospital_clinic_name;

  /// Translation for phone_number
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// Translation for email_address
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// Translation for address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Translation for emergency_info
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY INFORMATION'**
  String get emergency_info;

  /// Translation for emergency_contact_name
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact (Name)'**
  String get emergency_contact_name;

  /// Translation for emergency_contact_phone
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact (Phone)'**
  String get emergency_contact_phone;

  /// Translation for blood_type
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get blood_type;

  /// Translation for blood_unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get blood_unknown;

  /// Translation for profile_updated
  ///
  /// In en, this message translates to:
  /// **'Profile updated! ✅'**
  String get profile_updated;

  /// Translation for please_enter_name
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get please_enter_name;

  /// Translation for continue_btn
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// Translation for let_start
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start'**
  String get let_start;

  /// Translation for ob_1_title
  ///
  /// In en, this message translates to:
  /// **'VitaCase'**
  String get ob_1_title;

  /// Translation for ob_1_subtitle
  ///
  /// In en, this message translates to:
  /// **'All Your Files in One Place'**
  String get ob_1_subtitle;

  /// Translation for ob_1_desc
  ///
  /// In en, this message translates to:
  /// **'Store your documents, appointments, and medications safely, always carry them with you.'**
  String get ob_1_desc;

  /// Translation for ob_2_title
  ///
  /// In en, this message translates to:
  /// **'Organize All Your Files'**
  String get ob_2_title;

  /// Translation for ob_2_desc
  ///
  /// In en, this message translates to:
  /// **'Upload your documents, categorize them, and manage them easily.'**
  String get ob_2_desc;

  /// Translation for ob_3_title
  ///
  /// In en, this message translates to:
  /// **'Save Your Appointments'**
  String get ob_3_title;

  /// Translation for ob_3_desc
  ///
  /// In en, this message translates to:
  /// **'Keep all your appointments in one place, never miss one with reminders.'**
  String get ob_3_desc;

  /// Translation for ob_4_title
  ///
  /// In en, this message translates to:
  /// **'Save and Track Your Medications'**
  String get ob_4_title;

  /// Translation for ob_4_desc
  ///
  /// In en, this message translates to:
  /// **'Record your medications and usage times, don’t forget to use them regularly with reminders.'**
  String get ob_4_desc;

  /// Translation for ob_5_title
  ///
  /// In en, this message translates to:
  /// **'Save, Don’t Lose'**
  String get ob_5_title;

  /// Translation for ob_5_desc
  ///
  /// In en, this message translates to:
  /// **'Keep your appointments and medications safe, you stay relaxed.'**
  String get ob_5_desc;

  /// Translation for ob_feature_1_title
  ///
  /// In en, this message translates to:
  /// **'Secure Storage'**
  String get ob_feature_1_title;

  /// Translation for ob_feature_1_desc
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and only belongs to you.'**
  String get ob_feature_1_desc;

  /// Translation for ob_feature_2_title
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get ob_feature_2_title;

  /// Translation for ob_feature_2_desc
  ///
  /// In en, this message translates to:
  /// **'Never miss your appointment and medication times.'**
  String get ob_feature_2_desc;

  /// Translation for ob_feature_3_title
  ///
  /// In en, this message translates to:
  /// **'Access Everywhere'**
  String get ob_feature_3_title;

  /// Translation for ob_feature_3_desc
  ///
  /// In en, this message translates to:
  /// **'Access all your information whenever you want.'**
  String get ob_feature_3_desc;

  /// Translation for hi
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// Translation for good_morning
  ///
  /// In en, this message translates to:
  /// **'GOOD MORNING'**
  String get good_morning;

  /// Translation for good_afternoon
  ///
  /// In en, this message translates to:
  /// **'GOOD AFTERNOON'**
  String get good_afternoon;

  /// Translation for good_evening
  ///
  /// In en, this message translates to:
  /// **'GOOD EVENING'**
  String get good_evening;

  /// Translation for good_night
  ///
  /// In en, this message translates to:
  /// **'GOOD NIGHT'**
  String get good_night;

  /// Translation for synced
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// Translation for guest_mode
  ///
  /// In en, this message translates to:
  /// **'Guest Mode Active'**
  String get guest_mode;

  /// Translation for guest_desc
  ///
  /// In en, this message translates to:
  /// **'Data is local only. Create an account to back up.'**
  String get guest_desc;

  /// Translation for guest_user
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guest_user;

  /// Translation for all_records
  ///
  /// In en, this message translates to:
  /// **'Secure Archive'**
  String get all_records;

  /// Translation for vault_is_empty
  ///
  /// In en, this message translates to:
  /// **'Your Vault is Ready'**
  String get vault_is_empty;

  /// Translation for vault_desc
  ///
  /// In en, this message translates to:
  /// **'Store and organize your most important records in a private sanctuary.'**
  String get vault_desc;

  /// Translation for quick_access
  ///
  /// In en, this message translates to:
  /// **'QUICK ACCESS'**
  String get quick_access;

  /// Translation for steps
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// Translation for heart
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get heart;

  /// Translation for sleep
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// Translation for water
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// Translation for bpm
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// Translation for hours
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// Translation for ml
  ///
  /// In en, this message translates to:
  /// **'ML'**
  String get ml;

  /// Translation for home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Translation for vault
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vault;

  /// Translation for explore
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// Translation for appointments
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// Translation for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Translation for pharmacies
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get pharmacies;

  /// Translation for medicines
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// Translation for health_data
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get health_data;

  /// Translation for important_info
  ///
  /// In en, this message translates to:
  /// **'Important Info'**
  String get important_info;

  /// Translation for create_profile
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get create_profile;

  /// Translation for profile_desc
  ///
  /// In en, this message translates to:
  /// **'We need a few details to personalize your journey.'**
  String get profile_desc;

  /// Translation for full_name
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get full_name;

  /// Translation for gender
  ///
  /// In en, this message translates to:
  /// **'GENDER'**
  String get gender;

  /// Translation for birth_date
  ///
  /// In en, this message translates to:
  /// **'DATE OF BIRTH'**
  String get birth_date;

  /// Translation for date_format_hint
  ///
  /// In en, this message translates to:
  /// **'DD.MM.YYYY'**
  String get date_format_hint;

  /// Translation for save_continue
  ///
  /// In en, this message translates to:
  /// **'Save and Continue'**
  String get save_continue;

  /// Translation for security_badge_label
  ///
  /// In en, this message translates to:
  /// **'VITACASE ADVANCED ENCRYPTION v2.4'**
  String get security_badge_label;

  /// Translation for health_stats
  ///
  /// In en, this message translates to:
  /// **'Health Hub'**
  String get health_stats;

  /// Translation for health_stats_desc
  ///
  /// In en, this message translates to:
  /// **'Your comprehensive daily health summary.'**
  String get health_stats_desc;

  /// Translation for recent_activity
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recent_activity;

  /// Translation for no_health_records
  ///
  /// In en, this message translates to:
  /// **'No records found yet.'**
  String get no_health_records;

  /// Translation for add_health_data
  ///
  /// In en, this message translates to:
  /// **'Add Health Data'**
  String get add_health_data;

  /// Translation for step_unit
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get step_unit;

  /// Translation for privacy_guarantee
  ///
  /// In en, this message translates to:
  /// **'Your data is safe'**
  String get privacy_guarantee;

  /// Translation for privacy_box_desc
  ///
  /// In en, this message translates to:
  /// **'Your information is securely stored and never shared.'**
  String get privacy_box_desc;

  /// Translation for privacy_box_warning
  ///
  /// In en, this message translates to:
  /// **'Your data is private and stored securely on your device. Please avoid uploading highly sensitive information. You are responsible for the data you store.'**
  String get privacy_box_warning;

  /// Translation for docs_secure_storage_title
  ///
  /// In en, this message translates to:
  /// **'Secure Local Storage 🔒'**
  String get docs_secure_storage_title;

  /// Translation for docs_secure_storage_desc
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get docs_secure_storage_desc;

  /// Translation for docs_sensitive_warning
  ///
  /// In en, this message translates to:
  /// **'Avoid storing highly sensitive information. You are responsible for your data.'**
  String get docs_sensitive_warning;

  /// Translation for gender_female
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// Translation for gender_male
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// Translation for gender_other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get gender_other;

  /// Translation for appearance
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// Translation for theme_settings
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get theme_settings;

  /// Translation for app_settings
  ///
  /// In en, this message translates to:
  /// **'APP SETTINGS'**
  String get app_settings;

  /// Translation for text_size
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get text_size;

  /// Translation for quick_actions
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// Translation for data_security
  ///
  /// In en, this message translates to:
  /// **'DATA & SECURITY'**
  String get data_security;

  /// Translation for app_lock
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get app_lock;

  /// Translation for backup_zip
  ///
  /// In en, this message translates to:
  /// **'Backup (ZIP)'**
  String get backup_zip;

  /// Translation for import_backup
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get import_backup;

  /// Translation for import_desc
  ///
  /// In en, this message translates to:
  /// **'Import a ZIP backup file'**
  String get import_desc;

  /// Translation for export_desc
  ///
  /// In en, this message translates to:
  /// **'Export documents'**
  String get export_desc;

  /// Translation for emergency_contact
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergency_contact;

  /// Translation for daily_step_goal
  ///
  /// In en, this message translates to:
  /// **'Daily Step Goal'**
  String get daily_step_goal;

  /// Translation for support_legal
  ///
  /// In en, this message translates to:
  /// **'SUPPORT & LEGAL'**
  String get support_legal;

  /// Translation for help_center
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get help_center;

  /// Translation for report_issue
  ///
  /// In en, this message translates to:
  /// **'Error, Suggestion, Request & Complaint'**
  String get report_issue;

  /// Translation for privacy_policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// Translation for terms_conditions
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_conditions;

  /// Translation for legal_disclaimer
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer'**
  String get legal_disclaimer;

  /// Translation for legal
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get legal;

  /// Translation for lock_gate_title
  ///
  /// In en, this message translates to:
  /// **'VitaCase Locked'**
  String get lock_gate_title;

  /// Translation for lock_gate_desc
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access your secure document vault.'**
  String get lock_gate_desc;

  /// Translation for lock_gate_unlock
  ///
  /// In en, this message translates to:
  /// **'Unlock with Biometrics'**
  String get lock_gate_unlock;

  /// Translation for lock_set_pin
  ///
  /// In en, this message translates to:
  /// **'Set Secure PIN'**
  String get lock_set_pin;

  /// Translation for lock_confirm_pin
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get lock_confirm_pin;

  /// Translation for lock_pin_mismatch
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get lock_pin_mismatch;

  /// Translation for lock_pin_incorrect
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get lock_pin_incorrect;

  /// Translation for lock_use_biometrics
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get lock_use_biometrics;

  /// Translation for lock_too_many_attempts
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s.'**
  String lock_too_many_attempts(int seconds);

  /// Translation for lock_timeout_instant
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get lock_timeout_instant;

  /// Translation for lock_timeout_1min
  ///
  /// In en, this message translates to:
  /// **'1 Minute'**
  String get lock_timeout_1min;

  /// Translation for lock_timeout_5min
  ///
  /// In en, this message translates to:
  /// **'5 Minutes'**
  String get lock_timeout_5min;

  /// Translation for lock_timeout_15min
  ///
  /// In en, this message translates to:
  /// **'15 Minutes'**
  String get lock_timeout_15min;

  /// Translation for lock_timeout
  ///
  /// In en, this message translates to:
  /// **'Lock Timeout'**
  String get lock_timeout;

  /// Translation for change_pin
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get change_pin;

  /// Translation for biometric_login
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometric_login;

  /// Translation for biometric_unavailable
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device.'**
  String get biometric_unavailable;

  /// Translation for digits
  ///
  /// In en, this message translates to:
  /// **'digits'**
  String get digits;

  /// Translation for lock_skip_desc
  ///
  /// In en, this message translates to:
  /// **'You can set this up later from Settings.'**
  String get lock_skip_desc;

  /// Translation for setup_pin_later
  ///
  /// In en, this message translates to:
  /// **'Set up later from Settings'**
  String get setup_pin_later;

  /// Translation for skip_pin_setup
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip_pin_setup;

  /// Translation for setup_app_lock
  ///
  /// In en, this message translates to:
  /// **'Set Up App Lock'**
  String get setup_app_lock;

  /// Translation for setup_app_lock_desc
  ///
  /// In en, this message translates to:
  /// **'Protect your data with a 6-digit PIN.'**
  String get setup_app_lock_desc;

  /// Translation for step_profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get step_profile;

  /// Translation for step_security
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get step_security;

  /// Translation for daily_missions
  ///
  /// In en, this message translates to:
  /// **'DAILY MISSIONS'**
  String get daily_missions;

  /// Translation for mission_doc_daily
  ///
  /// In en, this message translates to:
  /// **'Add 1 Document'**
  String get mission_doc_daily;

  /// Translation for mission_ad_daily
  ///
  /// In en, this message translates to:
  /// **'Watch 1 Ad'**
  String get mission_ad_daily;

  /// Translation for mission_app_daily
  ///
  /// In en, this message translates to:
  /// **'Schedule 1 Appointment'**
  String get mission_app_daily;

  /// Translation for mission_med_daily
  ///
  /// In en, this message translates to:
  /// **'Add 1 Medicine'**
  String get mission_med_daily;

  /// Translation for export_data_zip
  ///
  /// In en, this message translates to:
  /// **'Export Data (.zip)'**
  String get export_data_zip;

  /// Translation for clear_all_data
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clear_all_data;

  /// Translation for quick_actions_desc
  ///
  /// In en, this message translates to:
  /// **'Quick shortcuts on dashboard'**
  String get quick_actions_desc;

  /// Translation for app_section
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get app_section;

  /// Translation for premium_required
  ///
  /// In en, this message translates to:
  /// **'Premium Required'**
  String get premium_required;

  /// Translation for logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Translation for logout_confirm
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logout_confirm;

  /// Translation for yes_logout
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get yes_logout;

  /// Translation for version
  ///
  /// In en, this message translates to:
  /// **'VERSION'**
  String get version;

  /// Translation for my_medicines
  ///
  /// In en, this message translates to:
  /// **'My Medicines'**
  String get my_medicines;

  /// Translation for med_count_desc
  ///
  /// In en, this message translates to:
  /// **'You have {count} medicines for today.'**
  String med_count_desc(int count);

  /// Translation for low_stock_warning
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get low_stock_warning;

  /// Translation for critical_level
  ///
  /// In en, this message translates to:
  /// **'Critical level for {name}.'**
  String critical_level(String name);

  /// Translation for refill
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get refill;

  /// Translation for intake_chart
  ///
  /// In en, this message translates to:
  /// **'Intake Compliance Chart'**
  String get intake_chart;

  /// Translation for weekly_avg
  ///
  /// In en, this message translates to:
  /// **'Weekly Avg: {perc}%'**
  String weekly_avg(int perc);

  /// Translation for medicine_cabinet
  ///
  /// In en, this message translates to:
  /// **'Medicine Cabinet'**
  String get medicine_cabinet;

  /// Translation for active_inventory
  ///
  /// In en, this message translates to:
  /// **'Your active inventory'**
  String get active_inventory;

  /// Translation for add
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Translation for daily_routine
  ///
  /// In en, this message translates to:
  /// **'Daily Routine'**
  String get daily_routine;

  /// Translation for morning
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// Translation for afternoon
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// Translation for night
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// Translation for med_cabinet_add
  ///
  /// In en, this message translates to:
  /// **'New Medicine'**
  String get med_cabinet_add;

  /// Translation for stock_left
  ///
  /// In en, this message translates to:
  /// **'{count} LEFT'**
  String stock_left(int count);

  /// Translation for vital_signs
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get vital_signs;

  /// Translation for daily_goals
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get daily_goals;

  /// Translation for activity
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// Translation for step_counter
  ///
  /// In en, this message translates to:
  /// **'Step Counter'**
  String get step_counter;

  /// Translation for water_tracker
  ///
  /// In en, this message translates to:
  /// **'Water Tracker'**
  String get water_tracker;

  /// Translation for safety_footer_med
  ///
  /// In en, this message translates to:
  /// **'VitaCase is a management tool. It does not provide medical advice or dosage recommendations. Always follow your doctor\'s instructions.'**
  String get safety_footer_med;

  /// Translation for safety_footer_health
  ///
  /// In en, this message translates to:
  /// **'Health data is for informational purposes only. Consult a professional for diagnosis.'**
  String get safety_footer_health;

  /// Translation for medical_device_warning
  ///
  /// In en, this message translates to:
  /// **'VitaCase is not a medical device. Always consult a professional.'**
  String get medical_device_warning;

  /// Translation for management_tool_warning
  ///
  /// In en, this message translates to:
  /// **'VitaCase is a management tool, not a diagnostic service.'**
  String get management_tool_warning;

  /// Translation for hint_name
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get hint_name;

  /// Translation for hint_emergency
  ///
  /// In en, this message translates to:
  /// **'Full Name / Phone'**
  String get hint_emergency;

  /// Translation for docs_title
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get docs_title;

  /// Translation for docs_search_hint
  ///
  /// In en, this message translates to:
  /// **'Search your vault (document, note, identity...)'**
  String get docs_search_hint;

  /// Translation for docs_info_secure
  ///
  /// In en, this message translates to:
  /// **'Your documents are stored securely and are exclusive to you.'**
  String get docs_info_secure;

  /// Translation for docs_info_encrypted
  ///
  /// In en, this message translates to:
  /// **'Your data is protected locally with encryption.'**
  String get docs_info_encrypted;

  /// Translation for docs_sort_all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get docs_sort_all;

  /// Translation for docs_sort_newest
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get docs_sort_newest;

  /// Translation for docs_sort_oldest
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get docs_sort_oldest;

  /// Translation for docs_empty_title
  ///
  /// In en, this message translates to:
  /// **'It\'s Empty Here'**
  String get docs_empty_title;

  /// Translation for docs_empty_subtitle
  ///
  /// In en, this message translates to:
  /// **'Start organizing your vault by adding your first document.'**
  String get docs_empty_subtitle;

  /// Translation for docs_category_health
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get docs_category_health;

  /// Translation for docs_category_identity
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get docs_category_identity;

  /// Translation for docs_category_finance
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get docs_category_finance;

  /// Translation for docs_category_legal
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get docs_category_legal;

  /// Translation for docs_category_notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get docs_category_notes;

  /// Translation for docs_category_other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get docs_category_other;

  /// Translation for docs_loading_open
  ///
  /// In en, this message translates to:
  /// **'Opening Secure File...'**
  String get docs_loading_open;

  /// Translation for docs_loading_decrypt
  ///
  /// In en, this message translates to:
  /// **'AES-256 Decrypting'**
  String get docs_loading_decrypt;

  /// Translation for docs_add_btn
  ///
  /// In en, this message translates to:
  /// **'ADD DOCUMENT'**
  String get docs_add_btn;

  /// Translation for docs_add_title
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get docs_add_title;

  /// Translation for docs_add_source
  ///
  /// In en, this message translates to:
  /// **'Source / Institution (optional)'**
  String get docs_add_source;

  /// Translation for docs_add_person
  ///
  /// In en, this message translates to:
  /// **'Related Person / Detail'**
  String get docs_add_person;

  /// Translation for docs_add_cat
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get docs_add_cat;

  /// Translation for docs_add_type
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get docs_add_type;

  /// Translation for docs_add_note
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get docs_add_note;

  /// Translation for docs_add_secure
  ///
  /// In en, this message translates to:
  /// **'This info is encrypted with AES-256.'**
  String get docs_add_secure;

  /// Translation for docs_add_pick_diff
  ///
  /// In en, this message translates to:
  /// **'Pick different file'**
  String get docs_add_pick_diff;

  /// Translation for docs_success
  ///
  /// In en, this message translates to:
  /// **'Document saved successfully!'**
  String get docs_success;

  /// Translation for docs_error_save
  ///
  /// In en, this message translates to:
  /// **'Failed to save document'**
  String get docs_error_save;

  /// Translation for docs_error_pick
  ///
  /// In en, this message translates to:
  /// **'Please select a file'**
  String get docs_error_pick;

  /// Translation for docs_error_source
  ///
  /// In en, this message translates to:
  /// **'Institution name is required for health docs'**
  String get docs_error_source;

  /// Translation for docs_error_size
  ///
  /// In en, this message translates to:
  /// **'File size must be max 10 MB'**
  String get docs_error_size;

  /// Translation for docs_add_pick
  ///
  /// In en, this message translates to:
  /// **'Select Document / Image'**
  String get docs_add_pick;

  /// Translation for docs_add_file_selected
  ///
  /// In en, this message translates to:
  /// **'Selected File'**
  String get docs_add_file_selected;

  /// Translation for docs_action_delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get docs_action_delete;

  /// Translation for docs_no_results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get docs_no_results;

  /// Translation for docs_no_matching
  ///
  /// In en, this message translates to:
  /// **'No documents match your criteria'**
  String get docs_no_matching;

  /// Translation for docs_try_different
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different keyword.'**
  String get docs_try_different;

  /// Translation for docs_no_filter_match
  ///
  /// In en, this message translates to:
  /// **'No documents found for the selected filter.'**
  String get docs_no_filter_match;

  /// Translation for docs_show_all
  ///
  /// In en, this message translates to:
  /// **'SHOW ALL'**
  String get docs_show_all;

  /// Translation for privacy_warning_title
  ///
  /// In en, this message translates to:
  /// **'Privacy Warning'**
  String get privacy_warning_title;

  /// Translation for privacy_warning_desc
  ///
  /// In en, this message translates to:
  /// **'The sole responsibility for any sensitive information and uploaded documents belongs entirely to the user. Please be cautious when storing high-risk data.'**
  String get privacy_warning_desc;

  /// Translation for hint_select
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get hint_select;

  /// Translation for hint_institution
  ///
  /// In en, this message translates to:
  /// **'e.g. City Hospital, Bank, Notary'**
  String get hint_institution;

  /// Translation for hint_person_detail
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Mehmet, Lawyer Ahmet, Tax No'**
  String get hint_person_detail;

  /// Translation for hint_add_note
  ///
  /// In en, this message translates to:
  /// **'Add note...'**
  String get hint_add_note;

  /// Translation for docs_category_prescriptions
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get docs_category_prescriptions;

  /// Translation for docs_category_reports
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get docs_category_reports;

  /// Translation for docs_category_test_results
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get docs_category_test_results;

  /// Translation for docs_category_images
  ///
  /// In en, this message translates to:
  /// **'Medical Image'**
  String get docs_category_images;

  /// Translation for upcoming_appointment
  ///
  /// In en, this message translates to:
  /// **'UPCOMING APPOINTMENT'**
  String get upcoming_appointment;

  /// Translation for my_appointments
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get my_appointments;

  /// Translation for weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Translation for monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Translation for no_more_appointments
  ///
  /// In en, this message translates to:
  /// **'No more appointments found.'**
  String get no_more_appointments;

  /// Translation for add_new_appointment
  ///
  /// In en, this message translates to:
  /// **'Add New Appointment'**
  String get add_new_appointment;

  /// Translation for join_meeting
  ///
  /// In en, this message translates to:
  /// **'Join Meeting'**
  String get join_meeting;

  /// Translation for location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Translation for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Translation for tomorrow
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Translation for health_trend_desc
  ///
  /// In en, this message translates to:
  /// **'7-Day Health Trend'**
  String get health_trend_desc;

  /// Translation for all_records_title
  ///
  /// In en, this message translates to:
  /// **'All Records'**
  String get all_records_title;

  /// Translation for personal_health_data
  ///
  /// In en, this message translates to:
  /// **'Personal Health Data'**
  String get personal_health_data;

  /// Translation for personal_info
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_info;

  /// Translation for account_settings
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get account_settings;

  /// Translation for emergency_card
  ///
  /// In en, this message translates to:
  /// **'Emergency Card'**
  String get emergency_card;

  /// Translation for allergies
  ///
  /// In en, this message translates to:
  /// **'ALLERGIES'**
  String get allergies;

  /// Translation for none
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Translation for not_added
  ///
  /// In en, this message translates to:
  /// **'Not Added'**
  String get not_added;

  /// Translation for active_goals
  ///
  /// In en, this message translates to:
  /// **'Active Goals'**
  String get active_goals;

  /// Translation for daily_steps
  ///
  /// In en, this message translates to:
  /// **'Daily Steps'**
  String get daily_steps;

  /// Translation for water_intake
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get water_intake;

  /// Translation for liter_unit
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get liter_unit;

  /// Translation for speed_up
  ///
  /// In en, this message translates to:
  /// **'SPEED UP'**
  String get speed_up;

  /// Translation for stay_fresh
  ///
  /// In en, this message translates to:
  /// **'STAY FRESH'**
  String get stay_fresh;

  /// Translation for target_label
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target_label;

  /// Translation for logout_desc_safe
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? Your data will remain securely stored on your device.'**
  String get logout_desc_safe;

  /// Translation for years_old
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get years_old;

  /// Translation for add_medicine
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get add_medicine;

  /// Translation for medicine_name
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicine_name;

  /// Translation for med_name_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Aspirin'**
  String get med_name_hint;

  /// Translation for frequency
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Translation for reminder_times
  ///
  /// In en, this message translates to:
  /// **'Reminder Times'**
  String get reminder_times;

  /// Translation for current_stock
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get current_stock;

  /// Translation for stock_warning
  ///
  /// In en, this message translates to:
  /// **'We will remind you when stock falls below 5 units.'**
  String get stock_warning;

  /// Translation for hero_health_tip
  ///
  /// In en, this message translates to:
  /// **'For Your Health'**
  String get hero_health_tip;

  /// Translation for hero_consistency
  ///
  /// In en, this message translates to:
  /// **'Consistency is key'**
  String get hero_consistency;

  /// Translation for med_added_success
  ///
  /// In en, this message translates to:
  /// **'Medicine added successfully!'**
  String get med_added_success;

  /// Translation for med_name_error
  ///
  /// In en, this message translates to:
  /// **'Please enter medicine name'**
  String get med_name_error;

  /// Translation for custom_freq_title
  ///
  /// In en, this message translates to:
  /// **'Custom Frequency'**
  String get custom_freq_title;

  /// Translation for custom_freq_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Every 2 weeks'**
  String get custom_freq_hint;

  /// Translation for apply
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Translation for daily
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Translation for custom
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Translation for tablet
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// Translation for syrup
  ///
  /// In en, this message translates to:
  /// **'Syrup (ml)'**
  String get syrup;

  /// Translation for dose
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// Translation for capsule
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get capsule;

  /// Translation for drops
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get drops;

  /// Translation for limit_title
  ///
  /// In en, this message translates to:
  /// **'Storage Full! 🚀'**
  String get limit_title;

  /// Translation for limit_desc
  ///
  /// In en, this message translates to:
  /// **'Your current limit is {count} documents. Would you like to watch a short video to gain +5 more slots?'**
  String limit_desc(int count);

  /// Translation for limit_desc_meds
  ///
  /// In en, this message translates to:
  /// **'Your current limit is {count} medicines. Would you like to watch a short video to gain +5 more slots?'**
  String limit_desc_meds(int count);

  /// Translation for limit_desc_appts
  ///
  /// In en, this message translates to:
  /// **'Your current limit is {count} appointments. Would you like to watch a short video to gain +5 more slots?'**
  String limit_desc_appts(int count);

  /// Translation for limit_close
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get limit_close;

  /// Translation for limit_reward_btn
  ///
  /// In en, this message translates to:
  /// **'WATCH AND GAIN'**
  String get limit_reward_btn;

  /// Translation for limit_reward_success
  ///
  /// In en, this message translates to:
  /// **'Congratulations! +10 document slots added.'**
  String get limit_reward_success;

  /// Translation for limit_ad_free_info
  ///
  /// In en, this message translates to:
  /// **'Safe & Private Local Storage 🛡️'**
  String get limit_ad_free_info;

  /// Translation for limit_slots_used
  ///
  /// In en, this message translates to:
  /// **'{count}/{limit} slots used'**
  String limit_slots_used(int count, int limit);

  /// Translation for lock_title
  ///
  /// In en, this message translates to:
  /// **'VitaCase Locked'**
  String get lock_title;

  /// Translation for lock_subtitle
  ///
  /// In en, this message translates to:
  /// **'Please verify to access'**
  String get lock_subtitle;

  /// Translation for unlock
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Translation for bmi_underweight
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmi_underweight;

  /// Translation for bmi_normal
  ///
  /// In en, this message translates to:
  /// **'Normal (Ideal)'**
  String get bmi_normal;

  /// Translation for bmi_overweight
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmi_overweight;

  /// Translation for bmi_obese
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmi_obese;

  /// Translation for page_not_found
  ///
  /// In en, this message translates to:
  /// **'Page not found or an error occurred.'**
  String get page_not_found;

  /// Translation for legal_onboarding_clause
  ///
  /// In en, this message translates to:
  /// **'I acknowledge that VitaCase is an offline-first vault. I bear sole responsibility for the security of my device and the sensitive health data stored within it.'**
  String get legal_onboarding_clause;

  /// Translation for delete_all_data
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get delete_all_data;

  /// Translation for wipe_confirm_1
  ///
  /// In en, this message translates to:
  /// **'All your data, documents, and settings will be permanently deleted. This action cannot be undone. Do you want to continue?'**
  String get wipe_confirm_1;

  /// Translation for wipe_confirm_2
  ///
  /// In en, this message translates to:
  /// **'Are you ABSOLUTELY sure? All your medical archive and encrypted records will be wiped from this device.'**
  String get wipe_confirm_2;

  /// Translation for final_warning
  ///
  /// In en, this message translates to:
  /// **'Final Security Warning'**
  String get final_warning;

  /// Translation for wipe_btn_final
  ///
  /// In en, this message translates to:
  /// **'YES, DELETE EVERYTHING'**
  String get wipe_btn_final;

  /// Translation for all_data_deleted
  ///
  /// In en, this message translates to:
  /// **'All your data has been wiped. The app will now restart.'**
  String get all_data_deleted;

  /// Translation for edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Translation for delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Translation for theme_selection_title
  ///
  /// In en, this message translates to:
  /// **'Theme Selection'**
  String get theme_selection_title;

  /// Translation for watch_ad
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watch_ad;

  /// Translation for verify_sentry
  ///
  /// In en, this message translates to:
  /// **'Verify Sentry Integration'**
  String get verify_sentry;

  /// Translation for edit_panel_soon
  ///
  /// In en, this message translates to:
  /// **'Edit panel coming soon!'**
  String get edit_panel_soon;

  /// Translation for add_new_record
  ///
  /// In en, this message translates to:
  /// **'Add New Record'**
  String get add_new_record;

  /// Translation for category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Translation for fill_required_fields
  ///
  /// In en, this message translates to:
  /// **'Please fill required fields'**
  String get fill_required_fields;

  /// Translation for error_doctor_data
  ///
  /// In en, this message translates to:
  /// **'Please enter doctor name and department'**
  String get error_doctor_data;

  /// Translation for error_appointment_data
  ///
  /// In en, this message translates to:
  /// **'Please fill in the title and hospital/center fields'**
  String get error_appointment_data;

  /// Translation for appointment_reminder_title
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get appointment_reminder_title;

  /// Translation for appointment_reminder_body
  ///
  /// In en, this message translates to:
  /// **'You have an appointment in {time}: {doctor} ({dept})'**
  String appointment_reminder_body(String time, String doctor, String dept);

  /// Translation for select_language
  ///
  /// In en, this message translates to:
  /// **'Select Language / Dil Seçin'**
  String get select_language;

  /// Translation for ok
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Translation for text_size_small
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get text_size_small;

  /// Translation for text_size_medium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get text_size_medium;

  /// Translation for text_size_large
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get text_size_large;

  /// Translation for support_contact
  ///
  /// In en, this message translates to:
  /// **'To contact our support team: limanexsoftware@outlook.com'**
  String get support_contact;

  /// Translation for quick_actions_optimized
  ///
  /// In en, this message translates to:
  /// **'Quick Actions are already optimized for your profile.'**
  String get quick_actions_optimized;

  /// Translation for medication_reminder
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get medication_reminder;

  /// Translation for medication_reminder_body
  ///
  /// In en, this message translates to:
  /// **'Time for {name} ({dose})'**
  String medication_reminder_body(String name, String dose);

  /// Translation for no_doctors_found
  ///
  /// In en, this message translates to:
  /// **'No matching doctors found'**
  String get no_doctors_found;

  /// Translation for clear_filters
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clear_filters;

  /// Translation for verified
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Translation for height_label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height_label;

  /// Translation for weight_label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight_label;

  /// Translation for age_label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age_label;

  /// Translation for identity_contact
  ///
  /// In en, this message translates to:
  /// **'Identity & Contact'**
  String get identity_contact;

  /// Translation for id_number
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get id_number;

  /// Translation for update_info
  ///
  /// In en, this message translates to:
  /// **'Update Info'**
  String get update_info;

  /// Translation for vita_badge
  ///
  /// In en, this message translates to:
  /// **'VitaCase User'**
  String get vita_badge;

  /// Translation for default_job
  ///
  /// In en, this message translates to:
  /// **'Freelance / Health Enthusiast'**
  String get default_job;

  /// Translation for blood_type_val
  ///
  /// In en, this message translates to:
  /// **'A Rh+'**
  String get blood_type_val;

  /// Translation for clinical_note
  ///
  /// In en, this message translates to:
  /// **'Clinical Note'**
  String get clinical_note;

  /// Translation for last_control
  ///
  /// In en, this message translates to:
  /// **'Last Control'**
  String get last_control;

  /// Translation for bmi_ideal
  ///
  /// In en, this message translates to:
  /// **'Ideal Weight Range'**
  String get bmi_ideal;

  /// Translation for medical_info_desc_empty
  ///
  /// In en, this message translates to:
  /// **'Store your critical medical information here to carry it with you always.'**
  String get medical_info_desc_empty;

  /// Translation for category_critical
  ///
  /// In en, this message translates to:
  /// **'CRITICAL INFORMATION'**
  String get category_critical;

  /// Translation for category_important
  ///
  /// In en, this message translates to:
  /// **'IMPORTANT NOTES'**
  String get category_important;

  /// Translation for category_general
  ///
  /// In en, this message translates to:
  /// **'GENERAL INFORMATION'**
  String get category_general;

  /// Translation for medical_info_desc
  ///
  /// In en, this message translates to:
  /// **'All medical records critical for your health.'**
  String get medical_info_desc;

  /// Translation for title
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Translation for description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Translation for icon
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// Translation for save_record
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get save_record;

  /// Translation for critical
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// Translation for important
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get important;

  /// Translation for general
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Translation for theme_unlock_desc
  ///
  /// In en, this message translates to:
  /// **'You can try this theme or watch an ad to unlock it permanently.'**
  String get theme_unlock_desc;

  /// Translation for theme_previewing
  ///
  /// In en, this message translates to:
  /// **'Theme is being previewed for 10 seconds...'**
  String get theme_previewing;

  /// Translation for preview_10s
  ///
  /// In en, this message translates to:
  /// **'Preview (10s)'**
  String get preview_10s;

  /// Translation for congratulations
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// Translation for theme_unlocked_success
  ///
  /// In en, this message translates to:
  /// **'Your new theme is unlocked.'**
  String get theme_unlocked_success;

  /// Translation for please_enter_at_least_one_data
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one data point.'**
  String get please_enter_at_least_one_data;

  /// Translation for data_saved_success
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully.'**
  String get data_saved_success;

  /// Translation for add_data
  ///
  /// In en, this message translates to:
  /// **'Add Data'**
  String get add_data;

  /// Translation for save_data
  ///
  /// In en, this message translates to:
  /// **'Save Data'**
  String get save_data;

  /// Translation for today_summary
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get today_summary;

  /// Translation for target_water
  ///
  /// In en, this message translates to:
  /// **'Target Water'**
  String get target_water;

  /// Translation for target_steps
  ///
  /// In en, this message translates to:
  /// **'Target Steps'**
  String get target_steps;

  /// Translation for add_doctor
  ///
  /// In en, this message translates to:
  /// **'Add Doctor'**
  String get add_doctor;

  /// Translation for doctor_name_surname
  ///
  /// In en, this message translates to:
  /// **'Doctor Name Surname'**
  String get doctor_name_surname;

  /// Translation for specialty_department
  ///
  /// In en, this message translates to:
  /// **'Specialty / Department'**
  String get specialty_department;

  /// Translation for new_record
  ///
  /// In en, this message translates to:
  /// **'New Record'**
  String get new_record;

  /// Translation for appointment_updated
  ///
  /// In en, this message translates to:
  /// **'Appointment updated.'**
  String get appointment_updated;

  /// Translation for appointment_added
  ///
  /// In en, this message translates to:
  /// **'Appointment added successfully.'**
  String get appointment_added;

  /// Translation for edit_appointment
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment'**
  String get edit_appointment;

  /// Translation for appointment_title
  ///
  /// In en, this message translates to:
  /// **'Appointment Title'**
  String get appointment_title;

  /// Translation for importance_level
  ///
  /// In en, this message translates to:
  /// **'Importance Level'**
  String get importance_level;

  /// Translation for notes_optional
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notes_optional;

  /// Translation for address_department
  ///
  /// In en, this message translates to:
  /// **'Full Address / Department'**
  String get address_department;

  /// Translation for select_category
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get select_category;

  /// Translation for category_meeting
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get category_meeting;

  /// Translation for category_reminder
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get category_reminder;

  /// Translation for category_other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_other;

  /// Translation for app_slogan
  ///
  /// In en, this message translates to:
  /// **'Digital Sanctuary'**
  String get app_slogan;

  /// Translation for day_monday_short
  ///
  /// In en, this message translates to:
  /// **'MON'**
  String get day_monday_short;

  /// Translation for day_tuesday_short
  ///
  /// In en, this message translates to:
  /// **'TUE'**
  String get day_tuesday_short;

  /// Translation for day_wednesday_short
  ///
  /// In en, this message translates to:
  /// **'WED'**
  String get day_wednesday_short;

  /// Translation for day_thursday_short
  ///
  /// In en, this message translates to:
  /// **'THU'**
  String get day_thursday_short;

  /// Translation for day_friday_short
  ///
  /// In en, this message translates to:
  /// **'FRI'**
  String get day_friday_short;

  /// Translation for day_saturday_short
  ///
  /// In en, this message translates to:
  /// **'SAT'**
  String get day_saturday_short;

  /// Translation for day_sunday_short
  ///
  /// In en, this message translates to:
  /// **'SUN'**
  String get day_sunday_short;

  /// Translation for day_monday_very_short
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get day_monday_very_short;

  /// Translation for day_tuesday_very_short
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get day_tuesday_very_short;

  /// Translation for day_wednesday_very_short
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get day_wednesday_very_short;

  /// Translation for day_thursday_very_short
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get day_thursday_very_short;

  /// Translation for day_friday_very_short
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get day_friday_very_short;

  /// Translation for day_saturday_very_short
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get day_saturday_very_short;

  /// Translation for day_sunday_very_short
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get day_sunday_very_short;

  /// Translation for delete_medicine_confirm
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medicine?'**
  String get delete_medicine_confirm;

  /// Translation for i_agree_to
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the'**
  String get i_agree_to;

  /// Translation for read_privacy_policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get read_privacy_policy;

  /// Translation for read_terms
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get read_terms;

  /// Translation for read_disclaimer
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer'**
  String get read_disclaimer;

  /// Translation for must_agree
  ///
  /// In en, this message translates to:
  /// **'You must agree to all legal documents to continue.'**
  String get must_agree;

  /// Translation for legal_acceptance
  ///
  /// In en, this message translates to:
  /// **'Legal Acceptance'**
  String get legal_acceptance;

  /// Translation for manage_subscription
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manage_subscription;

  /// Translation for trust_offline_title
  ///
  /// In en, this message translates to:
  /// **'Offline Sanctuary'**
  String get trust_offline_title;

  /// Translation for trust_offline_desc
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves your device.'**
  String get trust_offline_desc;

  /// Translation for trust_encryption_title
  ///
  /// In en, this message translates to:
  /// **'AES-256 Encryption'**
  String get trust_encryption_title;

  /// Translation for trust_encryption_desc
  ///
  /// In en, this message translates to:
  /// **'Protected with maximum security.'**
  String get trust_encryption_desc;

  /// Translation for trust_adfree_desc
  ///
  /// In en, this message translates to:
  /// **'An uninterrupted experience.'**
  String get trust_adfree_desc;

  /// Translation for medals_trophies
  ///
  /// In en, this message translates to:
  /// **'Medals & Trophies'**
  String get medals_trophies;

  /// Translation for cat_streak
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get cat_streak;

  /// Translation for cat_ads
  ///
  /// In en, this message translates to:
  /// **'Support & Ads'**
  String get cat_ads;

  /// Translation for cat_documents
  ///
  /// In en, this message translates to:
  /// **'Record Archive'**
  String get cat_documents;

  /// Translation for cat_medications
  ///
  /// In en, this message translates to:
  /// **'Medicine Habits'**
  String get cat_medications;

  /// Translation for cat_appointments
  ///
  /// In en, this message translates to:
  /// **'Clinical Visits'**
  String get cat_appointments;

  /// Translation for cat_profile
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get cat_profile;

  /// Translation for cat_emergency
  ///
  /// In en, this message translates to:
  /// **'Safety & Preparation'**
  String get cat_emergency;

  /// Translation for cat_health
  ///
  /// In en, this message translates to:
  /// **'Vital Monitoring'**
  String get cat_health;

  /// Translation for cat_engagement
  ///
  /// In en, this message translates to:
  /// **'App Activity'**
  String get cat_engagement;

  /// Translation for cat_special
  ///
  /// In en, this message translates to:
  /// **'Honors'**
  String get cat_special;

  /// Translation for cat_premium
  ///
  /// In en, this message translates to:
  /// **'Supporters'**
  String get cat_premium;

  /// Translation for cat_power_user
  ///
  /// In en, this message translates to:
  /// **'Legendary Status'**
  String get cat_power_user;

  /// Translation for ach_legend_status
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get ach_legend_status;

  /// Translation for theme_boutique
  ///
  /// In en, this message translates to:
  /// **'Theme Boutique'**
  String get theme_boutique;

  /// Translation for days_left
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get days_left;

  /// Translation for unlocked
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// Translation for progress
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Translation for ach_hidden_desc
  ///
  /// In en, this message translates to:
  /// **'Keep playing to discover this secret achievement.'**
  String get ach_hidden_desc;

  /// Translation for ach_login_1_desc
  ///
  /// In en, this message translates to:
  /// **'Every legendary journey begins with a single step. You ignited your first streak!'**
  String get ach_login_1_desc;

  /// Translation for ach_login_3_title
  ///
  /// In en, this message translates to:
  /// **'Warming Up'**
  String get ach_login_3_title;

  /// Translation for ach_login_3_desc
  ///
  /// In en, this message translates to:
  /// **'Warm-up laps are over. You\'ve been here for 3 days straight, not bad at all! 🔥'**
  String get ach_login_3_desc;

  /// Translation for ach_login_7_title
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get ach_login_7_title;

  /// Translation for ach_login_7_desc
  ///
  /// In en, this message translates to:
  /// **'A whole week! You\'ve learned the ropes and lit the campfire.'**
  String get ach_login_7_desc;

  /// Translation for ach_login_14_title
  ///
  /// In en, this message translates to:
  /// **'Habitual'**
  String get ach_login_14_title;

  /// Translation for ach_login_14_desc
  ///
  /// In en, this message translates to:
  /// **'Two weeks straight! This is how habits are forged. Congrats.'**
  String get ach_login_14_desc;

  /// Translation for ach_login_30_title
  ///
  /// In en, this message translates to:
  /// **'Addicted'**
  String get ach_login_30_title;

  /// Translation for ach_login_30_desc
  ///
  /// In en, this message translates to:
  /// **'A whole month! We both know this is more than just a hobby now.'**
  String get ach_login_30_desc;

  /// Translation for ach_login_60_title
  ///
  /// In en, this message translates to:
  /// **'Loyal User'**
  String get ach_login_60_title;

  /// Translation for ach_login_60_desc
  ///
  /// In en, this message translates to:
  /// **'Two months... Are you paying rent, friend? Welcome to your second home. 🏠'**
  String get ach_login_60_desc;

  /// Translation for ach_login_100_title
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get ach_login_100_title;

  /// Translation for ach_login_100_desc
  ///
  /// In en, this message translates to:
  /// **'Century! No power can break a massive 100-day streak. 💯'**
  String get ach_login_100_desc;

  /// Translation for ach_login_200_title
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get ach_login_200_title;

  /// Translation for ach_login_200_desc
  ///
  /// In en, this message translates to:
  /// **'200 days. People are starting to suspect you\'re an AI bot. 🤖'**
  String get ach_login_200_desc;

  /// Translation for ach_login_365_title
  ///
  /// In en, this message translates to:
  /// **'Legendary Year'**
  String get ach_login_365_title;

  /// Translation for ach_login_365_desc
  ///
  /// In en, this message translates to:
  /// **'A full Solar year! You\'ve been here through everything. Coronation tomorrow. 👑'**
  String get ach_login_365_desc;

  /// Translation for ach_ads_1_title
  ///
  /// In en, this message translates to:
  /// **'First Ad'**
  String get ach_ads_1_title;

  /// Translation for ach_ads_1_desc
  ///
  /// In en, this message translates to:
  /// **'Ads are good... sometimes. Thanks for the tiny support!'**
  String get ach_ads_1_desc;

  /// Translation for ach_ads_5_title
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get ach_ads_5_title;

  /// Translation for ach_ads_5_desc
  ///
  /// In en, this message translates to:
  /// **'You seem to love our sponsors as much as we do.'**
  String get ach_ads_5_desc;

  /// Translation for ach_ads_15_title
  ///
  /// In en, this message translates to:
  /// **'Loyal Viewer'**
  String get ach_ads_15_title;

  /// Translation for ach_ads_15_desc
  ///
  /// In en, this message translates to:
  /// **'Grab your popcorn, you completed a 15-ad marathon. 🍿'**
  String get ach_ads_15_desc;

  /// Translation for ach_ads_30_title
  ///
  /// In en, this message translates to:
  /// **'Keep it Up'**
  String get ach_ads_30_title;

  /// Translation for ach_ads_30_desc
  ///
  /// In en, this message translates to:
  /// **'Like watching TV! Your support is worth its weight in gold.'**
  String get ach_ads_30_desc;

  /// Translation for ach_ads_50_title
  ///
  /// In en, this message translates to:
  /// **'Power User'**
  String get ach_ads_50_title;

  /// Translation for ach_ads_50_desc
  ///
  /// In en, this message translates to:
  /// **'You can now predict which ad is coming to the second.'**
  String get ach_ads_50_desc;

  /// Translation for ach_ads_100_title
  ///
  /// In en, this message translates to:
  /// **'Addicted'**
  String get ach_ads_100_title;

  /// Translation for ach_ads_100_desc
  ///
  /// In en, this message translates to:
  /// **'100 ads! We owe you a special medal for your patience.'**
  String get ach_ads_100_desc;

  /// Translation for ach_ads_250_title
  ///
  /// In en, this message translates to:
  /// **'Ad Master'**
  String get ach_ads_250_title;

  /// Translation for ach_ads_250_desc
  ///
  /// In en, this message translates to:
  /// **'A marketing genius lost on the screen. Your support reached the sky.'**
  String get ach_ads_250_desc;

  /// Translation for ach_ads_500_title
  ///
  /// In en, this message translates to:
  /// **'Monetization King'**
  String get ach_ads_500_title;

  /// Translation for ach_ads_500_desc
  ///
  /// In en, this message translates to:
  /// **'Are you a financier? You\'re single-handedly running the market! 📉'**
  String get ach_ads_500_desc;

  /// Translation for ach_doc_1_title
  ///
  /// In en, this message translates to:
  /// **'First Document'**
  String get ach_doc_1_title;

  /// Translation for ach_doc_1_desc
  ///
  /// In en, this message translates to:
  /// **'Not a government office, but you successfully filed your first document. 📇'**
  String get ach_doc_1_desc;

  /// Translation for ach_doc_5_title
  ///
  /// In en, this message translates to:
  /// **'Beginning'**
  String get ach_doc_5_title;

  /// Translation for ach_doc_5_desc
  ///
  /// In en, this message translates to:
  /// **'Your first folder is almost full. You\'re getting organized.'**
  String get ach_doc_5_desc;

  /// Translation for ach_doc_10_title
  ///
  /// In en, this message translates to:
  /// **'Regular User'**
  String get ach_doc_10_title;

  /// Translation for ach_doc_10_desc
  ///
  /// In en, this message translates to:
  /// **'Files are piling up. Lost and Found would love to work with you.'**
  String get ach_doc_10_desc;

  /// Translation for ach_doc_25_title
  ///
  /// In en, this message translates to:
  /// **'Archivist'**
  String get ach_doc_25_title;

  /// Translation for ach_doc_25_desc
  ///
  /// In en, this message translates to:
  /// **'Paperwork and all... You blew through 25 documents in your archive.'**
  String get ach_doc_25_desc;

  /// Translation for ach_doc_50_title
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get ach_doc_50_title;

  /// Translation for ach_doc_50_desc
  ///
  /// In en, this message translates to:
  /// **'Forget secretarial work, this is what a professional filing knight looks like.'**
  String get ach_doc_50_desc;

  /// Translation for ach_doc_100_title
  ///
  /// In en, this message translates to:
  /// **'Vault Master'**
  String get ach_doc_100_title;

  /// Translation for ach_doc_100_desc
  ///
  /// In en, this message translates to:
  /// **'100 documents? Time to appoint a librarian for this massive archive. 📚'**
  String get ach_doc_100_desc;

  /// Translation for ach_doc_250_title
  ///
  /// In en, this message translates to:
  /// **'Data Collector'**
  String get ach_doc_250_title;

  /// Translation for ach_doc_250_desc
  ///
  /// In en, this message translates to:
  /// **'Welcome to Big Data scenarios. You rule the stacks.'**
  String get ach_doc_250_desc;

  /// Translation for ach_doc_500_title
  ///
  /// In en, this message translates to:
  /// **'Digital Archive Expert'**
  String get ach_doc_500_title;

  /// Translation for ach_doc_500_desc
  ///
  /// In en, this message translates to:
  /// **'Digital Library of Alexandria! Your archives will live for generations.'**
  String get ach_doc_500_desc;

  /// Translation for ach_med_1_title
  ///
  /// In en, this message translates to:
  /// **'First Med'**
  String get ach_med_1_title;

  /// Translation for ach_med_1_desc
  ///
  /// In en, this message translates to:
  /// **'You started valuing yourself. A great milestone for your health.'**
  String get ach_med_1_desc;

  /// Translation for ach_med_3_title
  ///
  /// In en, this message translates to:
  /// **'Tracking Started'**
  String get ach_med_3_title;

  /// Translation for ach_med_3_desc
  ///
  /// In en, this message translates to:
  /// **'Loyal to your prescription. Sip water and never miss reminders.'**
  String get ach_med_3_desc;

  /// Translation for ach_med_5_title
  ///
  /// In en, this message translates to:
  /// **'Regular User'**
  String get ach_med_5_title;

  /// Translation for ach_med_5_desc
  ///
  /// In en, this message translates to:
  /// **'Pharmacists\' favorite customer! You maintain your form carefully.'**
  String get ach_med_5_desc;

  /// Translation for ach_med_10_title
  ///
  /// In en, this message translates to:
  /// **'Disciplined'**
  String get ach_med_10_title;

  /// Translation for ach_med_10_desc
  ///
  /// In en, this message translates to:
  /// **'Meds on time, your body works like a clock. 10 times confirmed!'**
  String get ach_med_10_desc;

  /// Translation for ach_med_25_title
  ///
  /// In en, this message translates to:
  /// **'Health Expert'**
  String get ach_med_25_title;

  /// Translation for ach_med_25_desc
  ///
  /// In en, this message translates to:
  /// **'You understand your body\'s language. Med log became an art for you.'**
  String get ach_med_25_desc;

  /// Translation for ach_med_50_title
  ///
  /// In en, this message translates to:
  /// **'Health Master'**
  String get ach_med_50_title;

  /// Translation for ach_med_50_desc
  ///
  /// In en, this message translates to:
  /// **'Even doctors envy your discipline. You are the master of your body chemistry! 🧬'**
  String get ach_med_50_desc;

  /// Translation for ach_app_1_title
  ///
  /// In en, this message translates to:
  /// **'First Appt'**
  String get ach_app_1_title;

  /// Translation for ach_app_1_desc
  ///
  /// In en, this message translates to:
  /// **'No success without naturally planning! First calendar entry safely taken.'**
  String get ach_app_1_desc;

  /// Translation for ach_app_3_title
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get ach_app_3_title;

  /// Translation for ach_app_3_desc
  ///
  /// In en, this message translates to:
  /// **'Time Management 101. You rise by staying loyal to your plans.'**
  String get ach_app_3_desc;

  /// Translation for ach_app_5_title
  ///
  /// In en, this message translates to:
  /// **'Organized'**
  String get ach_app_5_title;

  /// Translation for ach_app_5_desc
  ///
  /// In en, this message translates to:
  /// **'Your agenda is filling up. That busy but charismatic person is definitely you.'**
  String get ach_app_5_desc;

  /// Translation for ach_app_10_title
  ///
  /// In en, this message translates to:
  /// **'Disciplined Planner'**
  String get ach_app_10_title;

  /// Translation for ach_app_10_desc
  ///
  /// In en, this message translates to:
  /// **'No need for alarms, there\'s an atomic clock inside your head.'**
  String get ach_app_10_desc;

  /// Translation for ach_app_20_title
  ///
  /// In en, this message translates to:
  /// **'Planner Pro'**
  String get ach_app_20_title;

  /// Translation for ach_app_20_desc
  ///
  /// In en, this message translates to:
  /// **'Everything is clear to the minute... You\'re like a digital assistant!'**
  String get ach_app_20_desc;

  /// Translation for ach_app_30_title
  ///
  /// In en, this message translates to:
  /// **'Master Planner'**
  String get ach_app_30_title;

  /// Translation for ach_app_30_desc
  ///
  /// In en, this message translates to:
  /// **'Time bender! It seems impossible for one person to manage these appts... but it wasn\'t.'**
  String get ach_app_30_desc;

  /// Translation for ach_profile_created_title
  ///
  /// In en, this message translates to:
  /// **'Profile Created'**
  String get ach_profile_created_title;

  /// Translation for ach_profile_created_desc
  ///
  /// In en, this message translates to:
  /// **'Officially joined us. You already made your digital mark!'**
  String get ach_profile_created_desc;

  /// Translation for ach_profile_completed_title
  ///
  /// In en, this message translates to:
  /// **'Profile Completed'**
  String get ach_profile_completed_title;

  /// Translation for ach_profile_completed_desc
  ///
  /// In en, this message translates to:
  /// **'You hate missing gaps, right? All info is perfectly full.'**
  String get ach_profile_completed_desc;

  /// Translation for ach_profile_updated_title
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get ach_profile_updated_title;

  /// Translation for ach_profile_updated_desc
  ///
  /// In en, this message translates to:
  /// **'Change is progress! You stayed in the game by refreshing yourself.'**
  String get ach_profile_updated_desc;

  /// Translation for ach_profile_with_photo_title
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get ach_profile_with_photo_title;

  /// Translation for ach_profile_with_photo_desc
  ///
  /// In en, this message translates to:
  /// **'Saved from being a faceless avatar. Smile for the camera! 📸'**
  String get ach_profile_with_photo_desc;

  /// Translation for ach_profile_master_title
  ///
  /// In en, this message translates to:
  /// **'Profile Master'**
  String get ach_profile_master_title;

  /// Translation for ach_profile_master_desc
  ///
  /// In en, this message translates to:
  /// **'With your identity and bio, you are the sleekest user in the system.'**
  String get ach_profile_master_desc;

  /// Translation for ach_emergency_added_title
  ///
  /// In en, this message translates to:
  /// **'Emergency Card Added'**
  String get ach_emergency_added_title;

  /// Translation for ach_emergency_added_desc
  ///
  /// In en, this message translates to:
  /// **'Precaution is never left behind. Your emergency shield is active.'**
  String get ach_emergency_added_desc;

  /// Translation for ach_emergency_contact_title
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get ach_emergency_contact_title;

  /// Translation for ach_emergency_contact_desc
  ///
  /// In en, this message translates to:
  /// **'It\'s clear who to call in tough times. Circle of trust created. 📞'**
  String get ach_emergency_contact_desc;

  /// Translation for ach_emergency_complete_title
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ach_emergency_complete_title;

  /// Translation for ach_emergency_complete_desc
  ///
  /// In en, this message translates to:
  /// **'Ready for scenarios. Security level at the highest.'**
  String get ach_emergency_complete_desc;

  /// Translation for ach_emergency_ready_title
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ach_emergency_ready_title;

  /// Translation for ach_emergency_ready_desc
  ///
  /// In en, this message translates to:
  /// **'Everything will work like a clock in red alert. Safely secured.'**
  String get ach_emergency_ready_desc;

  /// Translation for ach_emergency_master_title
  ///
  /// In en, this message translates to:
  /// **'Emergency Master'**
  String get ach_emergency_master_title;

  /// Translation for ach_emergency_master_desc
  ///
  /// In en, this message translates to:
  /// **'Tough and cool enough to manage first aid before an ambulance arrives!'**
  String get ach_emergency_master_desc;

  /// Translation for ach_health_1_title
  ///
  /// In en, this message translates to:
  /// **'First Data'**
  String get ach_health_1_title;

  /// Translation for ach_health_1_desc
  ///
  /// In en, this message translates to:
  /// **'You did yourself a favor today. Your body thanks you from the inside.'**
  String get ach_health_1_desc;

  /// Translation for ach_health_5_title
  ///
  /// In en, this message translates to:
  /// **'Tracking Started'**
  String get ach_health_5_title;

  /// Translation for ach_health_5_desc
  ///
  /// In en, this message translates to:
  /// **'Data is piling up, you are advancing your conversation with your biorhythm.'**
  String get ach_health_5_desc;

  /// Translation for ach_health_10_title
  ///
  /// In en, this message translates to:
  /// **'Health Conscious'**
  String get ach_health_10_title;

  /// Translation for ach_health_10_desc
  ///
  /// In en, this message translates to:
  /// **'You are a statistical wonder! Your body reads like an encrypted book. 📈'**
  String get ach_health_10_desc;

  /// Translation for ach_health_20_title
  ///
  /// In en, this message translates to:
  /// **'Regular Tracking'**
  String get ach_health_20_title;

  /// Translation for ach_health_20_desc
  ///
  /// In en, this message translates to:
  /// **'You are like a machine. Pulse, metrics, steps... none escape your sensors.'**
  String get ach_health_20_desc;

  /// Translation for ach_health_50_title
  ///
  /// In en, this message translates to:
  /// **'Health Expert'**
  String get ach_health_50_title;

  /// Translation for ach_health_50_desc
  ///
  /// In en, this message translates to:
  /// **'Approaching Cyborg level. The bond between you and your bio-data is unbreakable.'**
  String get ach_health_50_desc;

  /// Translation for ach_health_master_title
  ///
  /// In en, this message translates to:
  /// **'Health Master'**
  String get ach_health_master_title;

  /// Translation for ach_health_master_desc
  ///
  /// In en, this message translates to:
  /// **'High priest of the temple! You established absolute mastery over your own body. 🧘'**
  String get ach_health_master_desc;

  /// Translation for ach_first_login_title
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get ach_first_login_title;

  /// Translation for ach_first_login_desc
  ///
  /// In en, this message translates to:
  /// **'The actual adventure is just beginning. You just stepped inside.'**
  String get ach_first_login_desc;

  /// Translation for ach_first_upload_title
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get ach_first_upload_title;

  /// Translation for ach_first_upload_desc
  ///
  /// In en, this message translates to:
  /// **'Left your first permanent mark. You are engraved here now.'**
  String get ach_first_upload_desc;

  /// Translation for ach_first_ad_title
  ///
  /// In en, this message translates to:
  /// **'Free User'**
  String get ach_first_ad_title;

  /// Translation for ach_first_ad_desc
  ///
  /// In en, this message translates to:
  /// **'First ad interaction! You gave lifeblood to the ecosystem.'**
  String get ach_first_ad_desc;

  /// Translation for ach_first_premium_title
  ///
  /// In en, this message translates to:
  /// **'Premium User'**
  String get ach_first_premium_title;

  /// Translation for ach_first_premium_desc
  ///
  /// In en, this message translates to:
  /// **'A matter of vision. Enjoy the VIP lounge, the red carpet is rolled out! 🎟️'**
  String get ach_first_premium_desc;

  /// Translation for ach_active_3_days_title
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ach_active_3_days_title;

  /// Translation for ach_active_3_days_desc
  ///
  /// In en, this message translates to:
  /// **'Cables are warming up, engines started. We feel your energy.'**
  String get ach_active_3_days_desc;

  /// Translation for ach_active_7_days_title
  ///
  /// In en, this message translates to:
  /// **'Loyal'**
  String get ach_active_7_days_title;

  /// Translation for ach_active_7_days_desc
  ///
  /// In en, this message translates to:
  /// **'Synchronized with the system for a whole week. Things got electric!'**
  String get ach_active_7_days_desc;

  /// Translation for ach_active_30_days_title
  ///
  /// In en, this message translates to:
  /// **'Core User'**
  String get ach_active_30_days_title;

  /// Translation for ach_active_30_days_desc
  ///
  /// In en, this message translates to:
  /// **'Practically honorary staff now. This place wouldn\'t be the same without you.'**
  String get ach_active_30_days_desc;

  /// Translation for ach_streak_saved_title
  ///
  /// In en, this message translates to:
  /// **'Streak Savior'**
  String get ach_streak_saved_title;

  /// Translation for ach_streak_saved_desc
  ///
  /// In en, this message translates to:
  /// **'Returned from the edge! Saving that beautiful streak was a great reflex.'**
  String get ach_streak_saved_desc;

  /// Translation for ach_streak_saved_5_title
  ///
  /// In en, this message translates to:
  /// **'Resilient'**
  String get ach_streak_saved_5_title;

  /// Translation for ach_streak_saved_5_desc
  ///
  /// In en, this message translates to:
  /// **'Not falling despite battle scars, you know how to rise when you stumble.'**
  String get ach_streak_saved_5_desc;

  /// Translation for ach_streak_saved_10_title
  ///
  /// In en, this message translates to:
  /// **'Never Gives Up'**
  String get ach_streak_saved_10_title;

  /// Translation for ach_streak_saved_10_desc
  ///
  /// In en, this message translates to:
  /// **'Are you a Phoenix? Rising from ashes is just a typical Tuesday activity for you. 🐦🔥'**
  String get ach_streak_saved_10_desc;

  /// Translation for ach_streak_perfect_30_title
  ///
  /// In en, this message translates to:
  /// **'Perfect Streak'**
  String get ach_streak_perfect_30_title;

  /// Translation for ach_streak_perfect_30_desc
  ///
  /// In en, this message translates to:
  /// **'Not a single miss. You were perfect for 30 whole days, like a Swiss watch!'**
  String get ach_streak_perfect_30_desc;

  /// Translation for ach_premium_trial_used_title
  ///
  /// In en, this message translates to:
  /// **'Premium Experience'**
  String get ach_premium_trial_used_title;

  /// Translation for ach_premium_trial_used_desc
  ///
  /// In en, this message translates to:
  /// **'Opened the door to privileges. The view is mesmerizing, isn\'t it?'**
  String get ach_premium_trial_used_desc;

  /// Translation for ach_limit_breaker_title
  ///
  /// In en, this message translates to:
  /// **'Limit Breaker'**
  String get ach_limit_breaker_title;

  /// Translation for ach_limit_breaker_desc
  ///
  /// In en, this message translates to:
  /// **'Rules and limits are meant to be bent. You stepped out of the Matrix! 💥'**
  String get ach_limit_breaker_desc;

  /// Translation for ach_ad_skip_used_title
  ///
  /// In en, this message translates to:
  /// **'Ad Skip'**
  String get ach_ad_skip_used_title;

  /// Translation for ach_ad_skip_used_desc
  ///
  /// In en, this message translates to:
  /// **'You said I have no time for this, fast-forwarded time with one click.'**
  String get ach_ad_skip_used_desc;

  /// Translation for ach_reward_collector_title
  ///
  /// In en, this message translates to:
  /// **'Reward Collector'**
  String get ach_reward_collector_title;

  /// Translation for ach_reward_collector_desc
  ///
  /// In en, this message translates to:
  /// **'Scavenged every reward in corner. A true loot hunter! 🎁'**
  String get ach_reward_collector_desc;

  /// Translation for ach_multi_feature_user_title
  ///
  /// In en, this message translates to:
  /// **'Multi Feature User'**
  String get ach_multi_feature_user_title;

  /// Translation for ach_multi_feature_user_desc
  ///
  /// In en, this message translates to:
  /// **'Not a single button left untouched, curious explorer!'**
  String get ach_multi_feature_user_desc;

  /// Translation for ach_data_master_title
  ///
  /// In en, this message translates to:
  /// **'Data Master'**
  String get ach_data_master_title;

  /// Translation for ach_data_master_desc
  ///
  /// In en, this message translates to:
  /// **'Bytes and bits take shape around you. Absolute master of system data.'**
  String get ach_data_master_desc;

  /// Translation for ach_organized_master_title
  ///
  /// In en, this message translates to:
  /// **'Ultra Organized'**
  String get ach_organized_master_title;

  /// Translation for ach_organized_master_desc
  ///
  /// In en, this message translates to:
  /// **'Marie Kondo would tip her hat to your order. Everything is millimetric.'**
  String get ach_organized_master_desc;

  /// Translation for ach_security_master_title
  ///
  /// In en, this message translates to:
  /// **'Security Expert'**
  String get ach_security_master_title;

  /// Translation for ach_security_master_desc
  ///
  /// In en, this message translates to:
  /// **'Your account is a fortress, your passwords a cyber army. Intrusion is impossible! 🔐'**
  String get ach_security_master_desc;

  /// Translation for ach_daily_master_title
  ///
  /// In en, this message translates to:
  /// **'Daily Master'**
  String get ach_daily_master_title;

  /// Translation for ach_daily_master_desc
  ///
  /// In en, this message translates to:
  /// **'Legendary loyal user who sees the sun and stars with us every day.'**
  String get ach_daily_master_desc;

  /// Translation for backup_restore
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup_restore;

  /// Translation for backup_desc_settings
  ///
  /// In en, this message translates to:
  /// **'Encrypted local backup for this device only'**
  String get backup_desc_settings;

  /// Translation for smart_notifications
  ///
  /// In en, this message translates to:
  /// **'Smart Notifications'**
  String get smart_notifications;

  /// Translation for smart_streak_warning
  ///
  /// In en, this message translates to:
  /// **'🔥 Streak is about to be lost! Why not check your data?'**
  String get smart_streak_warning;

  /// Translation for smart_ad_reward
  ///
  /// In en, this message translates to:
  /// **'🎁 Watch 1 ad → +5 limit! A new opportunity for you today.'**
  String get smart_ad_reward;

  /// Translation for smart_doc_bonus
  ///
  /// In en, this message translates to:
  /// **'📂 Add 1 document today → get a bonus! Keep everything safe.'**
  String get smart_doc_bonus;

  /// Translation for smart_default
  ///
  /// In en, this message translates to:
  /// **'👀 A small update is waiting for you, what can we do today?'**
  String get smart_default;

  /// Translation for notif_bonus_ready
  ///
  /// In en, this message translates to:
  /// **'🎁 Bonus waiting for you! Thanks for your help.'**
  String get notif_bonus_ready;

  /// Translation for notif_doc_safe
  ///
  /// In en, this message translates to:
  /// **'🔥 Good job, your documents are safe! Keep going!'**
  String get notif_doc_safe;

  /// Translation for level_up_desc
  ///
  /// In en, this message translates to:
  /// **'You reached Level {level}! Check your Season Pass for new rewards.'**
  String level_up_desc(int level);

  /// Translation for notifications_active_msg
  ///
  /// In en, this message translates to:
  /// **'Notifications are active 🔔'**
  String get notifications_active_msg;

  /// Translation for show_sensitive_details
  ///
  /// In en, this message translates to:
  /// **'Show details in notification'**
  String get show_sensitive_details;

  /// Translation for sensitive_details_visible
  ///
  /// In en, this message translates to:
  /// **'Medicine name is visible'**
  String get sensitive_details_visible;

  /// Translation for sensitive_details_hidden
  ///
  /// In en, this message translates to:
  /// **'Hidden (recommended)'**
  String get sensitive_details_hidden;

  /// Translation for quiet_hours
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get quiet_hours;

  /// Translation for quiet_hours_msg
  ///
  /// In en, this message translates to:
  /// **'We won\'t disturb you tonight 🌙'**
  String get quiet_hours_msg;

  /// Translation for test_notification
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get test_notification;

  /// Translation for test_notification_desc
  ///
  /// In en, this message translates to:
  /// **'Test the system immediately'**
  String get test_notification_desc;

  /// Translation for test_notification_body
  ///
  /// In en, this message translates to:
  /// **'This is a test notification'**
  String get test_notification_body;

  /// Translation for app_lock_unavailable
  ///
  /// In en, this message translates to:
  /// **'App lock is unavailable on this device.'**
  String get app_lock_unavailable;

  /// Translation for backup_restore_desc
  ///
  /// In en, this message translates to:
  /// **'You can backup or restore your data encrypted. Backups are stored only on your device.'**
  String get backup_restore_desc;

  /// Translation for backup_export
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get backup_export;

  /// Translation for backup_export_desc
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted ZIP backup'**
  String get backup_export_desc;

  /// Translation for backup_import
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get backup_import;

  /// Translation for backup_import_desc
  ///
  /// In en, this message translates to:
  /// **'Restore from an existing ZIP backup'**
  String get backup_import_desc;

  /// Translation for warning
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Translation for import_warning_desc
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup will DELETE your current data and cannot be undone. Do you want to continue?'**
  String get import_warning_desc;

  /// Translation for yes_restore
  ///
  /// In en, this message translates to:
  /// **'Yes, Restore'**
  String get yes_restore;

  /// Translation for start_time
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get start_time;

  /// Translation for end_time
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get end_time;

  /// Translation for email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Translation for phone
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Translation for add_record_success
  ///
  /// In en, this message translates to:
  /// **'Record saved successfully!'**
  String get add_record_success;

  /// Translation for delete_confirm
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get delete_confirm;

  /// Translation for plus_5_slots
  ///
  /// In en, this message translates to:
  /// **'+5 Slots Earned! 🚀'**
  String get plus_5_slots;

  /// Translation for watch_to_unlock
  ///
  /// In en, this message translates to:
  /// **'Watch to unlock'**
  String get watch_to_unlock;

  /// Translation for remaining_days
  ///
  /// In en, this message translates to:
  /// **'Remaining: {days} days'**
  String remaining_days(int days);

  /// Translation for add_1_day_success
  ///
  /// In en, this message translates to:
  /// **'+1 day added! 🎉'**
  String get add_1_day_success;

  /// Translation for plus_1_day
  ///
  /// In en, this message translates to:
  /// **'+1 Day'**
  String get plus_1_day;

  /// Translation for watch
  ///
  /// In en, this message translates to:
  /// **'WATCH'**
  String get watch;

  /// Translation for unlock_theme_question
  ///
  /// In en, this message translates to:
  /// **'Would you like to use this theme for 5 days for free?'**
  String get unlock_theme_question;

  /// Translation for watch_ad_plus_5
  ///
  /// In en, this message translates to:
  /// **'WATCH AD (+5 days)'**
  String get watch_ad_plus_5;

  /// Translation for preview_5s
  ///
  /// In en, this message translates to:
  /// **'Preview (5s)'**
  String get preview_5s;

  /// Translation for free_secure_release
  ///
  /// In en, this message translates to:
  /// **'Free secure release'**
  String get free_secure_release;

  /// Translation for encrypted_local_desc
  ///
  /// In en, this message translates to:
  /// **'Your encrypted documents stay local on this device. Ads support the free version.'**
  String get encrypted_local_desc;

  /// Translation for premium_soon
  ///
  /// In en, this message translates to:
  /// **'PREMIUM SOON'**
  String get premium_soon;

  /// Translation for label_title
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get label_title;

  /// Translation for label_location
  ///
  /// In en, this message translates to:
  /// **'LOCATION / INSTITUTION (OPTIONAL)'**
  String get label_location;

  /// Translation for label_person
  ///
  /// In en, this message translates to:
  /// **'RELATED PERSON (OPTIONAL)'**
  String get label_person;

  /// Translation for label_date_time
  ///
  /// In en, this message translates to:
  /// **'DATE & TIME'**
  String get label_date_time;

  /// Translation for label_importance
  ///
  /// In en, this message translates to:
  /// **'IMPORTANCE'**
  String get label_importance;

  /// Translation for label_reminder
  ///
  /// In en, this message translates to:
  /// **'REMINDER'**
  String get label_reminder;

  /// Translation for label_repeat
  ///
  /// In en, this message translates to:
  /// **'REPEAT'**
  String get label_repeat;

  /// Translation for label_notes
  ///
  /// In en, this message translates to:
  /// **'NOTES (OPTIONAL)'**
  String get label_notes;

  /// Translation for hint_title
  ///
  /// In en, this message translates to:
  /// **'e.g. Doctor appointment, Meeting...'**
  String get hint_title;

  /// Translation for hint_location
  ///
  /// In en, this message translates to:
  /// **'Office, Home, Online, Hospital...'**
  String get hint_location;

  /// Translation for hint_person
  ///
  /// In en, this message translates to:
  /// **'Name, Doctor, Lawyer...'**
  String get hint_person;

  /// Translation for hint_notes
  ///
  /// In en, this message translates to:
  /// **'Details, reminders...'**
  String get hint_notes;

  /// Translation for suggest_doctor
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get suggest_doctor;

  /// Translation for suggest_meeting
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get suggest_meeting;

  /// Translation for suggest_personal
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get suggest_personal;

  /// Translation for importance_low
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get importance_low;

  /// Translation for importance_medium
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get importance_medium;

  /// Translation for importance_high
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get importance_high;

  /// Translation for reminder_10m
  ///
  /// In en, this message translates to:
  /// **'10 min before'**
  String get reminder_10m;

  /// Translation for reminder_1h
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get reminder_1h;

  /// Translation for reminder_1d
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminder_1d;

  /// Translation for repeat_none
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get repeat_none;

  /// Translation for repeat_daily
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeat_daily;

  /// Translation for repeat_weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeat_weekly;

  /// Translation for label_date_added
  ///
  /// In en, this message translates to:
  /// **'DATE ADDED'**
  String get label_date_added;

  /// Translation for label_document_date
  ///
  /// In en, this message translates to:
  /// **'DOCUMENT DATE'**
  String get label_document_date;

  /// Translation for download_to_device
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD TO DEVICE'**
  String get download_to_device;

  /// Translation for delete_permanently
  ///
  /// In en, this message translates to:
  /// **'DELETE PERMANENTLY'**
  String get delete_permanently;

  /// Translation for save_document
  ///
  /// In en, this message translates to:
  /// **'Save Document'**
  String get save_document;

  /// Translation for success_doc_saved
  ///
  /// In en, this message translates to:
  /// **'Document saved successfully!'**
  String get success_doc_saved;

  /// Translation for error_failed_download
  ///
  /// In en, this message translates to:
  /// **'Failed to download: {error}'**
  String error_failed_download(String error);

  /// Translation for btn_add
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btn_add;

  /// Translation for docs_tag_lab
  ///
  /// In en, this message translates to:
  /// **'Lab Result'**
  String get docs_tag_lab;

  /// Translation for docs_tag_radiology
  ///
  /// In en, this message translates to:
  /// **'Radiology'**
  String get docs_tag_radiology;

  /// Translation for docs_tag_prescription
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get docs_tag_prescription;

  /// Translation for docs_tag_report
  ///
  /// In en, this message translates to:
  /// **'Doctor Report'**
  String get docs_tag_report;

  /// Translation for docs_tag_operation
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get docs_tag_operation;

  /// Translation for docs_tag_vaccination
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get docs_tag_vaccination;

  /// Translation for docs_tag_other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get docs_tag_other;

  /// Translation for season_pass
  ///
  /// In en, this message translates to:
  /// **'Season Pass'**
  String get season_pass;

  /// Translation for level_label
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level_label(int level);

  /// Translation for premium_reward
  ///
  /// In en, this message translates to:
  /// **'Premium Reward'**
  String get premium_reward;

  /// Translation for free_reward
  ///
  /// In en, this message translates to:
  /// **'Free Reward'**
  String get free_reward;

  /// Translation for claim
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get claim;

  /// Translation for reward_doc_slots
  ///
  /// In en, this message translates to:
  /// **'+{value} Docs'**
  String reward_doc_slots(int value);

  /// Translation for premium_unavailable_title
  ///
  /// In en, this message translates to:
  /// **'Premium is not available in this release.'**
  String get premium_unavailable_title;

  /// Translation for premium_unavailable_desc
  ///
  /// In en, this message translates to:
  /// **'VitaCase currently ships as a free app with local encrypted storage, ads, and optional reminders.'**
  String get premium_unavailable_desc;

  /// Translation for btn_close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btn_close;

  /// Translation for accept
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Translation for btn_save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btn_save;

  /// Translation for doctor_title_dr
  ///
  /// In en, this message translates to:
  /// **'Dr.'**
  String get doctor_title_dr;

  /// Translation for doctor_title_uzm
  ///
  /// In en, this message translates to:
  /// **'Spec. Dr.'**
  String get doctor_title_uzm;

  /// Translation for doctor_title_op
  ///
  /// In en, this message translates to:
  /// **'Op. Dr.'**
  String get doctor_title_op;

  /// Translation for doctor_title_prof
  ///
  /// In en, this message translates to:
  /// **'Prof. Dr.'**
  String get doctor_title_prof;

  /// Translation for doctor_title_doc
  ///
  /// In en, this message translates to:
  /// **'Assoc. Prof.'**
  String get doctor_title_doc;

  /// Translation for hint_doctor_name
  ///
  /// In en, this message translates to:
  /// **'Dr. John Doe'**
  String get hint_doctor_name;

  /// Translation for hint_specialty
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get hint_specialty;

  /// Translation for hint_hospital
  ///
  /// In en, this message translates to:
  /// **'City Hospital'**
  String get hint_hospital;

  /// Translation for hint_phone
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 000-0000'**
  String get hint_phone;

  /// Translation for hint_email
  ///
  /// In en, this message translates to:
  /// **'john.doe@hospital.com'**
  String get hint_email;

  /// Translation for hint_address
  ///
  /// In en, this message translates to:
  /// **'Main St. No:12...'**
  String get hint_address;

  /// Translation for hint_personal_notes
  ///
  /// In en, this message translates to:
  /// **'Notes about the doctor...'**
  String get hint_personal_notes;

  /// Translation for ad_reward_not_earned
  ///
  /// In en, this message translates to:
  /// **'Reward not earned. Please finish the ad to continue.'**
  String get ad_reward_not_earned;

  /// Translation for ad_unavailable
  ///
  /// In en, this message translates to:
  /// **'Ad unavailable.'**
  String get ad_unavailable;

  /// Translation for ad_failed
  ///
  /// In en, this message translates to:
  /// **'The rewarded ad could not be shown. Please try again.'**
  String get ad_failed;

  /// Translation for ad_watch_btn
  ///
  /// In en, this message translates to:
  /// **'Continue for free (watch ad)'**
  String get ad_watch_btn;

  /// Translation for btn_not_now
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get btn_not_now;

  /// Translation for theme_system
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// Translation for theme_light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// Translation for theme_dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// Translation for lock_timeout_1m
  ///
  /// In en, this message translates to:
  /// **'1 Minute'**
  String get lock_timeout_1m;

  /// Translation for lock_timeout_5m
  ///
  /// In en, this message translates to:
  /// **'5 Minutes'**
  String get lock_timeout_5m;

  /// Translation for lock_timeout_15m
  ///
  /// In en, this message translates to:
  /// **'15 Minutes'**
  String get lock_timeout_15m;

  /// Translation for error_title_required
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get error_title_required;

  /// Translation for notif_app_created_title
  ///
  /// In en, this message translates to:
  /// **'🎯 Appointment Created'**
  String get notif_app_created_title;

  /// Translation for notif_app_created_body
  ///
  /// In en, this message translates to:
  /// **'{title} has been scheduled.'**
  String notif_app_created_body(String title);

  /// Translation for notif_app_reminder_title
  ///
  /// In en, this message translates to:
  /// **'📅 Appointment Reminder'**
  String get notif_app_reminder_title;

  /// Translation for notif_app_reminder_body
  ///
  /// In en, this message translates to:
  /// **'Your appointment for {title} is approaching.'**
  String notif_app_reminder_body(String title);

  /// Translation for no_appointments_found
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get no_appointments_found;

  /// Translation for empty_appointments_desc
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any appointments yet. Tap the + button to add one.'**
  String get empty_appointments_desc;

  /// Translation for empty_appointments_filter_desc
  ///
  /// In en, this message translates to:
  /// **'No appointments found in this category.'**
  String get empty_appointments_filter_desc;

  /// Translation for btn_add_appointment
  ///
  /// In en, this message translates to:
  /// **'ADD APPOINTMENT'**
  String get btn_add_appointment;

  /// Translation for btn_clear_filters
  ///
  /// In en, this message translates to:
  /// **'CLEAR FILTERS'**
  String get btn_clear_filters;

  /// Translation for delete_confirm_appointment
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this appointment?'**
  String get delete_confirm_appointment;

  /// Translation for create_today_plan
  ///
  /// In en, this message translates to:
  /// **'Create Today\'s Plan'**
  String get create_today_plan;

  /// Translation for plan_time_desc
  ///
  /// In en, this message translates to:
  /// **'Organize your health schedule with ease.'**
  String get plan_time_desc;

  /// Translation for docs_add_short
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get docs_add_short;

  /// Translation for docs_open
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get docs_open;

  /// Translation for docs_download
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD TO DEVICE'**
  String get docs_download;

  /// Translation for docs_delete_perm
  ///
  /// In en, this message translates to:
  /// **'DELETE PERMANENTLY'**
  String get docs_delete_perm;

  /// Translation for docs_date_added
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get docs_date_added;

  /// Translation for docs_document_date
  ///
  /// In en, this message translates to:
  /// **'Document Date'**
  String get docs_document_date;

  /// Translation for docs_save_success
  ///
  /// In en, this message translates to:
  /// **'Document saved successfully!'**
  String get docs_save_success;

  /// Translation for docs_download_failed
  ///
  /// In en, this message translates to:
  /// **'Failed to download: {error}'**
  String docs_download_failed(String error);

  /// Translation for season_pass_title
  ///
  /// In en, this message translates to:
  /// **'Season Pass'**
  String get season_pass_title;

  /// Translation for season_level
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String season_level(int level);

  /// Translation for claim_reward
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get claim_reward;

  /// Translation for confirm_agree
  ///
  /// In en, this message translates to:
  /// **'I Agree'**
  String get confirm_agree;

  /// Translation for specialty_department_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Cardiology'**
  String get specialty_department_hint;

  /// Translation for hospital_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. City Hospital'**
  String get hospital_hint;

  /// Translation for address_hint
  ///
  /// In en, this message translates to:
  /// **'Street, No, Building...'**
  String get address_hint;

  /// Translation for notes_hint
  ///
  /// In en, this message translates to:
  /// **'Personal notes about the doctor...'**
  String get notes_hint;

  /// Translation for standard_modes
  ///
  /// In en, this message translates to:
  /// **'Standard Modes'**
  String get standard_modes;

  /// Translation for premium_palettes
  ///
  /// In en, this message translates to:
  /// **'Premium Palettes'**
  String get premium_palettes;

  /// Translation for apply_theme
  ///
  /// In en, this message translates to:
  /// **'Apply Theme'**
  String get apply_theme;

  /// Translation for theme_luxe_sanctuary
  ///
  /// In en, this message translates to:
  /// **'Luxe Sanctuary'**
  String get theme_luxe_sanctuary;

  /// Translation for theme_midnight_neon
  ///
  /// In en, this message translates to:
  /// **'Midnight Neon'**
  String get theme_midnight_neon;

  /// Translation for theme_amethyst_aura
  ///
  /// In en, this message translates to:
  /// **'Amethyst Aura'**
  String get theme_amethyst_aura;

  /// Translation for theme_emerald_garden
  ///
  /// In en, this message translates to:
  /// **'Emerald Garden'**
  String get theme_emerald_garden;

  /// Translation for theme_ocean_serenity
  ///
  /// In en, this message translates to:
  /// **'Ocean Serenity'**
  String get theme_ocean_serenity;

  /// Translation for theme_amber_glow
  ///
  /// In en, this message translates to:
  /// **'Amber Glow'**
  String get theme_amber_glow;

  /// Translation for db_recovery_title
  ///
  /// In en, this message translates to:
  /// **'Data Error'**
  String get db_recovery_title;

  /// Translation for db_recovery_desc
  ///
  /// In en, this message translates to:
  /// **'Could not access data. Would you like to try again?'**
  String get db_recovery_desc;

  /// Translation for db_recovery_retry
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get db_recovery_retry;

  /// Translation for db_recovery_reset
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get db_recovery_reset;

  /// Translation for notif_streak_warning_title
  ///
  /// In en, this message translates to:
  /// **'Check your daily plan'**
  String get notif_streak_warning_title;

  /// Translation for notif_streak_warning_body
  ///
  /// In en, this message translates to:
  /// **'Open VitaCase to review today\'s reminders and saved items.'**
  String get notif_streak_warning_body;

  /// Translation for notif_mission_reminder_title
  ///
  /// In en, this message translates to:
  /// **'🎯 Daily Missions Pending'**
  String get notif_mission_reminder_title;

  /// Translation for notif_mission_reminder_body
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss out on your daily rewards! Complete your tasks now.'**
  String get notif_mission_reminder_body;

  /// Translation for notif_limit_reached_title
  ///
  /// In en, this message translates to:
  /// **'🚀 Limit Reached'**
  String get notif_limit_reached_title;

  /// Translation for notif_limit_reached_body
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your free limit. Watch a rewarded ad to continue.'**
  String get notif_limit_reached_body;

  /// Translation for notif_good_morning_title
  ///
  /// In en, this message translates to:
  /// **'🌞 Good Morning!'**
  String get notif_good_morning_title;

  /// Translation for notif_good_morning_body
  ///
  /// In en, this message translates to:
  /// **'Start your day with VitaCase, check your daily tasks.'**
  String get notif_good_morning_body;

  /// Translation for notif_test_title
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get notif_test_title;

  /// Translation for notif_test_body
  ///
  /// In en, this message translates to:
  /// **'Your notifications are working perfectly!'**
  String get notif_test_body;

  /// Translation for notif_appointment_reminder_title
  ///
  /// In en, this message translates to:
  /// **'📅 Appointment Reminder'**
  String get notif_appointment_reminder_title;

  /// Translation for notif_appointment_reminder_body
  ///
  /// In en, this message translates to:
  /// **'Your appointment for {doctor} is approaching.'**
  String notif_appointment_reminder_body(String doctor);

  /// Translation for get_directions
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get get_directions;

  /// Translation for view_details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// Translation for no_scheduled_meds_today
  ///
  /// In en, this message translates to:
  /// **'No medications scheduled for today.'**
  String get no_scheduled_meds_today;

  /// Translation for add_appointment
  ///
  /// In en, this message translates to:
  /// **'Add Appointment'**
  String get add_appointment;

  /// Translation for add_document
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get add_document;

  /// Translation for ach_login_1_title
  ///
  /// In en, this message translates to:
  /// **'The Beginning'**
  String get ach_login_1_title;

  /// Translation for people_contacts
  ///
  /// In en, this message translates to:
  /// **'People & Contacts'**
  String get people_contacts;

  /// Translation for contacts_subtitle
  ///
  /// In en, this message translates to:
  /// **'People, institutions, and contact records'**
  String get contacts_subtitle;

  /// Translation for add_contact_subtitle
  ///
  /// In en, this message translates to:
  /// **'Add a new person or institution'**
  String get add_contact_subtitle;

  /// Translation for add_contact
  ///
  /// In en, this message translates to:
  /// **'Add Person / Contact'**
  String get add_contact;

  /// Translation for no_doctor
  ///
  /// In en, this message translates to:
  /// **'No doctor'**
  String get no_doctor;

  /// Translation for no_institution
  ///
  /// In en, this message translates to:
  /// **'No institution'**
  String get no_institution;

  /// Translation for edit_personal_info
  ///
  /// In en, this message translates to:
  /// **'Edit personal information'**
  String get edit_personal_info;

  /// Translation for personal_info_updated
  ///
  /// In en, this message translates to:
  /// **'Personal information updated.'**
  String get personal_info_updated;

  /// Translation for edit_important_info
  ///
  /// In en, this message translates to:
  /// **'Edit important information'**
  String get edit_important_info;

  /// Translation for hint_allergies
  ///
  /// In en, this message translates to:
  /// **'Separate with commas: Pollen, Penicillin'**
  String get hint_allergies;

  /// Translation for hint_medications
  ///
  /// In en, this message translates to:
  /// **'Separate with commas: Aspirin, Vitamin D'**
  String get hint_medications;

  /// Translation for relationship
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// Translation for hint_relationship
  ///
  /// In en, this message translates to:
  /// **'Spouse, mother, father, sibling...'**
  String get hint_relationship;

  /// Translation for important_info_updated
  ///
  /// In en, this message translates to:
  /// **'Important information updated.'**
  String get important_info_updated;

  /// Translation for reminder_troubleshooting
  ///
  /// In en, this message translates to:
  /// **'Reminder Troubleshooting'**
  String get reminder_troubleshooting;

  /// Translation for reminder_troubleshooting_desc
  ///
  /// In en, this message translates to:
  /// **'Check notification, exact alarm, and battery settings'**
  String get reminder_troubleshooting_desc;

  /// Translation for status_checking
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get status_checking;

  /// Translation for status_enabled
  ///
  /// In en, this message translates to:
  /// **'Notification permission is enabled'**
  String get status_enabled;

  /// Translation for status_disabled
  ///
  /// In en, this message translates to:
  /// **'Notification permission is disabled'**
  String get status_disabled;

  /// Translation for why_no_reminders
  ///
  /// In en, this message translates to:
  /// **'Why reminders may not arrive'**
  String get why_no_reminders;

  /// Translation for why_no_reminders_desc
  ///
  /// In en, this message translates to:
  /// **'Notification permission, exact alarm permission, or device battery management can block appointment and medicine reminders. Check permissions first; consider battery optimization only as a last step if tests fail.'**
  String get why_no_reminders_desc;

  /// Translation for status_card_title
  ///
  /// In en, this message translates to:
  /// **'Notification Status'**
  String get status_card_title;

  /// Translation for check_notif_permission
  ///
  /// In en, this message translates to:
  /// **'1. Check notification permission'**
  String get check_notif_permission;

  /// Translation for check_notif_permission_desc
  ///
  /// In en, this message translates to:
  /// **'If instant notifications are disabled, no reminders will appear.'**
  String get check_notif_permission_desc;

  /// Translation for req_notif_permission
  ///
  /// In en, this message translates to:
  /// **'Request Notification Permission'**
  String get req_notif_permission;

  /// Translation for check_exact_alarm
  ///
  /// In en, this message translates to:
  /// **'2. Check exact alarm permission'**
  String get check_exact_alarm;

  /// Translation for check_exact_alarm_desc
  ///
  /// In en, this message translates to:
  /// **'Required for appointment and medicine reminders to run on time.'**
  String get check_exact_alarm_desc;

  /// Translation for req_exact_alarm
  ///
  /// In en, this message translates to:
  /// **'Request Exact Alarm Permission'**
  String get req_exact_alarm;

  /// Translation for resched_saved
  ///
  /// In en, this message translates to:
  /// **'3. Reschedule saved reminders'**
  String get resched_saved;

  /// Translation for resched_saved_desc
  ///
  /// In en, this message translates to:
  /// **'After granting permissions, schedules your saved medicine and appointment reminders again.'**
  String get resched_saved_desc;

  /// Translation for resched_btn
  ///
  /// In en, this message translates to:
  /// **'Reschedule Reminders'**
  String get resched_btn;

  /// Translation for sched_test
  ///
  /// In en, this message translates to:
  /// **'4. Schedule a 1-minute test reminder'**
  String get sched_test;

  /// Translation for sched_test_desc
  ///
  /// In en, this message translates to:
  /// **'If this arrives, the reminder system is working.'**
  String get sched_test_desc;

  /// Translation for sched_test_btn
  ///
  /// In en, this message translates to:
  /// **'Schedule 1-Minute Test'**
  String get sched_test_btn;

  /// Translation for last_step_battery
  ///
  /// In en, this message translates to:
  /// **'5. Last step: check battery settings'**
  String get last_step_battery;

  /// Translation for last_step_battery_desc
  ///
  /// In en, this message translates to:
  /// **'Only if the tests above fail, check whether the device is restricting VitaCase battery usage.'**
  String get last_step_battery_desc;

  /// Translation for open_app_settings
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get open_app_settings;

  /// Translation for snack_notif_checked
  ///
  /// In en, this message translates to:
  /// **'Notification permission checked.'**
  String get snack_notif_checked;

  /// Translation for snack_exact_alarm_requested
  ///
  /// In en, this message translates to:
  /// **'Exact alarm permission requested. You may need to allow it in device settings.'**
  String get snack_exact_alarm_requested;

  /// Translation for test_notif_title
  ///
  /// In en, this message translates to:
  /// **'⏰ VitaCase Reminder Test'**
  String get test_notif_title;

  /// Translation for test_notif_body
  ///
  /// In en, this message translates to:
  /// **'This test reminder was scheduled for 1 minute later.'**
  String get test_notif_body;

  /// Translation for snack_test_sched
  ///
  /// In en, this message translates to:
  /// **'Test reminder scheduled for 1 minute later.'**
  String get snack_test_sched;

  /// Translation for snack_resched_completed
  ///
  /// In en, this message translates to:
  /// **'Saved medicine and appointment reminders were rescheduled.'**
  String get snack_resched_completed;

  /// Translation for choose_pdf_or_image
  ///
  /// In en, this message translates to:
  /// **'Choose PDF or Image'**
  String get choose_pdf_or_image;

  /// Translation for encrypted_local_file_info
  ///
  /// In en, this message translates to:
  /// **'Your file will be encrypted and stored locally on this device.'**
  String get encrypted_local_file_info;

  /// Translation for web_upload_info
  ///
  /// In en, this message translates to:
  /// **'File vault upload is available on Android/iOS builds.'**
  String get web_upload_info;

  /// Translation for web_preview_no_upload
  ///
  /// In en, this message translates to:
  /// **'Web preview does not store encrypted files. Use Android/iOS for vault upload.'**
  String get web_preview_no_upload;

  /// Translation for choose_file_first
  ///
  /// In en, this message translates to:
  /// **'Please choose a PDF or image first.'**
  String get choose_file_first;

  /// Translation for document_saved
  ///
  /// In en, this message translates to:
  /// **'Document saved securely.'**
  String get document_saved;

  /// Translation for save_document_failed
  ///
  /// In en, this message translates to:
  /// **'Could not save document: {error}'**
  String save_document_failed(String error);

  /// Translation for save_securely
  ///
  /// In en, this message translates to:
  /// **'Save Securely'**
  String get save_securely;

  /// Translation for saving
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Translation for local_organizer_disclaimer
  ///
  /// In en, this message translates to:
  /// **'VitaCase is a local document organizer. It does not diagnose, analyze, or provide medical advice.'**
  String get local_organizer_disclaimer;

  /// Translation for terms_and_legal_agreement
  ///
  /// In en, this message translates to:
  /// **'I agree to the Privacy Policy, Terms & Conditions, and Legal Disclaimer.'**
  String get terms_and_legal_agreement;

  /// Translation for free_themes
  ///
  /// In en, this message translates to:
  /// **'Free themes'**
  String get free_themes;

  /// Translation for reward_themes
  ///
  /// In en, this message translates to:
  /// **'Reward themes'**
  String get reward_themes;

  /// Translation for reward_themes_info
  ///
  /// In en, this message translates to:
  /// **'Watch one rewarded ad to unlock these themes for 3 days. Every extra ad adds +1 day.'**
  String get reward_themes_info;

  /// Translation for watch_ad_to_unlock
  ///
  /// In en, this message translates to:
  /// **'Watch ad to unlock'**
  String get watch_ad_to_unlock;

  /// Translation for tap_to_preview
  ///
  /// In en, this message translates to:
  /// **'Tap to preview'**
  String get tap_to_preview;

  /// Translation for add_one_day
  ///
  /// In en, this message translates to:
  /// **'Add +1 day'**
  String get add_one_day;

  /// Translation for one_day_added
  ///
  /// In en, this message translates to:
  /// **'+1 day added.'**
  String get one_day_added;

  /// Translation for ad_unavailable_try_later
  ///
  /// In en, this message translates to:
  /// **'Ad unavailable. Please try again later.'**
  String get ad_unavailable_try_later;

  /// Translation for theme_unlocked
  ///
  /// In en, this message translates to:
  /// **'Theme unlocked. Each extra ad adds +1 day.'**
  String get theme_unlocked;

  /// Translation for reward_themes_active
  ///
  /// In en, this message translates to:
  /// **'Reward themes active for {days} day(s).'**
  String reward_themes_active(String days);

  /// Translation for lock_use_pin
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get lock_use_pin;

  /// Translation for pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Subtitle for document details screen
  ///
  /// In en, this message translates to:
  /// **'Reviewing expanded document details.'**
  String get document_details_subtitle;

  /// Label for document name field
  ///
  /// In en, this message translates to:
  /// **'Document name'**
  String get document_name;

  /// Hint text for document name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Blood test result'**
  String get document_name_hint;

  /// Warning message when document upload limit is exceeded
  ///
  /// In en, this message translates to:
  /// **'You reached today\'s create limit ({limit}). You can add more tomorrow.'**
  String daily_limit_reached_message(int limit);

  /// Success message when document is saved
  ///
  /// In en, this message translates to:
  /// **'Document updated.'**
  String get document_updated;

  /// Error message when document update fails
  ///
  /// In en, this message translates to:
  /// **'Could not update document.'**
  String get document_update_failed;

  /// Error message when document fails to open
  ///
  /// In en, this message translates to:
  /// **'Could not open document.'**
  String get document_open_failed;

  /// Placeholder for empty notes
  ///
  /// In en, this message translates to:
  /// **'No additional notes provided.'**
  String get no_additional_notes;

  /// Label for document creation date
  ///
  /// In en, this message translates to:
  /// **'CREATED AT'**
  String get created_at_label;

  /// Label for document doctor/physician
  ///
  /// In en, this message translates to:
  /// **'PHYSICIAN'**
  String get physician_label;

  /// Generic open label
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Translation for document_vault
  ///
  /// In en, this message translates to:
  /// **'Document Vault'**
  String get document_vault;

  /// Translation for document_vault_view_subtitle
  ///
  /// In en, this message translates to:
  /// **'Reviewing expanded document details.'**
  String get document_vault_view_subtitle;

  /// Translation for institution_hospital
  ///
  /// In en, this message translates to:
  /// **'Institution / Hospital'**
  String get institution_hospital;

  /// Translation for doctor_related_person
  ///
  /// In en, this message translates to:
  /// **'Doctor / Related person'**
  String get doctor_related_person;

  /// Translation for add_contact_title
  ///
  /// In en, this message translates to:
  /// **'Add Person / Contact'**
  String get add_contact_title;

  /// Translation for contact_info_title
  ///
  /// In en, this message translates to:
  /// **'Person / Contact Info'**
  String get contact_info_title;

  /// Translation for contact_info_desc
  ///
  /// In en, this message translates to:
  /// **'Keep important person, institution, and contact details for quick access.'**
  String get contact_info_desc;

  /// Translation for person_contact_label
  ///
  /// In en, this message translates to:
  /// **'Person / Contact'**
  String get person_contact_label;

  /// Translation for category_area_label
  ///
  /// In en, this message translates to:
  /// **'Category / Area'**
  String get category_area_label;

  /// Translation for institution_source_label
  ///
  /// In en, this message translates to:
  /// **'Institution / Source'**
  String get institution_source_label;

  /// Translation for person_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Smith, advisor, clinic contact'**
  String get person_hint;

  /// Translation for category_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. checkup, dental, therapy, consultation'**
  String get category_hint;

  /// Translation for institution_hint
  ///
  /// In en, this message translates to:
  /// **'e.g. clinic, lab, office, online source'**
  String get institution_hint;

  /// Translation for required_contact_error
  ///
  /// In en, this message translates to:
  /// **'Please enter person/contact and category/area information.'**
  String get required_contact_error;

  /// Translation for contacts_title
  ///
  /// In en, this message translates to:
  /// **'Person / Contacts'**
  String get contacts_title;

  /// Translation for contacts_search_hint
  ///
  /// In en, this message translates to:
  /// **'Search person, institution, or category'**
  String get contacts_search_hint;

  /// Translation for no_contacts_found
  ///
  /// In en, this message translates to:
  /// **'No matching contacts found'**
  String get no_contacts_found;

  /// Translation for contact_detail_title
  ///
  /// In en, this message translates to:
  /// **'Person / Contact Detail'**
  String get contact_detail_title;

  /// Translation for institution_source
  ///
  /// In en, this message translates to:
  /// **'Institution / Source'**
  String get institution_source;

  /// Translation for category_area
  ///
  /// In en, this message translates to:
  /// **'Category / Area'**
  String get category_area;

  /// Translation for sub_area
  ///
  /// In en, this message translates to:
  /// **'Sub-area'**
  String get sub_area;

  /// Translation for privacy_policy_short
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy_short;

  /// Translation for terms_short
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms_short;

  /// Translation for disclaimer_short
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get disclaimer_short;

  /// Translation for debug_panel_taps_left
  ///
  /// In en, this message translates to:
  /// **'Debug panel: {remaining} taps left.'**
  String debug_panel_taps_left(String remaining);

  /// Translation for delete_confirm_dialog_title
  ///
  /// In en, this message translates to:
  /// **'Delete document?'**
  String get delete_confirm_dialog_title;

  /// Translation for delete_confirm_dialog_desc
  ///
  /// In en, this message translates to:
  /// **'This document will be removed from the vault. This action cannot be undone.'**
  String get delete_confirm_dialog_desc;

  /// Translation for document_deleted_msg
  ///
  /// In en, this message translates to:
  /// **'Document deleted.'**
  String get document_deleted_msg;

  /// Translation for sort_newest_first
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sort_newest_first;

  /// Translation for sort_oldest_first
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sort_oldest_first;

  /// Translation for sort_a_z
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sort_a_z;

  /// Translation for sort_label
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort_label;

  /// Translation for medication_reminder_past_note
  ///
  /// In en, this message translates to:
  /// **'If the selected time has already passed today, the first reminder is scheduled for the next suitable time.'**
  String get medication_reminder_past_note;

  /// Translation for appointment_reminder_past_note
  ///
  /// In en, this message translates to:
  /// **'If the selected reminder time is already in the past, VitaCase chooses the nearest suitable time.'**
  String get appointment_reminder_past_note;

  /// Translation for limit_unlock_token_title
  ///
  /// In en, this message translates to:
  /// **'Limit Unlock Token'**
  String get limit_unlock_token_title;

  /// Translation for limit_unlock_status_active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get limit_unlock_status_active;

  /// Translation for limit_unlock_status_coming_soon
  ///
  /// In en, this message translates to:
  /// **'Coming in {version}'**
  String limit_unlock_status_coming_soon(String version);

  /// Translation for limit_unlock_desc_active
  ///
  /// In en, this message translates to:
  /// **'Every {xp} XP grants 1 Limit Unlock Token. It is used automatically when the daily limit is reached.'**
  String limit_unlock_desc_active(String xp);

  /// Translation for limit_unlock_desc_inactive
  ///
  /// In en, this message translates to:
  /// **'Disabled in V1. In {version}, every {xp} XP will grant 1 Limit Unlock Token.'**
  String limit_unlock_desc_inactive(String version, String xp);

  /// Translation for limit_unlock_stat_total_xp
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get limit_unlock_stat_total_xp;

  /// Translation for limit_unlock_stat_xp_left
  ///
  /// In en, this message translates to:
  /// **'XP left'**
  String get limit_unlock_stat_xp_left;

  /// Translation for limit_unlock_stat_tokens
  ///
  /// In en, this message translates to:
  /// **'Tokens'**
  String get limit_unlock_stat_tokens;

  /// Translation for notes
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'pt', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'pt': return AppLocalizationsPt();
    case 'tr': return AppLocalizationsTr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
