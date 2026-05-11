import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'VitaCase'**
  String get app_name;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @premium_feature.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature 🌟'**
  String get premium_feature;

  /// No description provided for @premium_required_desc.
  ///
  /// In en, this message translates to:
  /// **'Premium membership is required for App Lock.'**
  String get premium_required_desc;

  /// No description provided for @go_premium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get go_premium;

  /// No description provided for @index.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get index;

  /// No description provided for @view_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get view_weekly;

  /// No description provided for @view_monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get view_monthly;

  /// No description provided for @phone_country_code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get phone_country_code;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get coming_soon;

  /// No description provided for @coming_soon_desc.
  ///
  /// In en, this message translates to:
  /// **'This feature will be available in the next update.'**
  String get coming_soon_desc;

  /// No description provided for @tap_for_test.
  ///
  /// In en, this message translates to:
  /// **'Tap {count} more times for test notification'**
  String tap_for_test(Object count);

  /// No description provided for @unit_ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unit_ml;

  /// No description provided for @unit_l.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unit_l;

  /// No description provided for @metric_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get metric_water;

  /// No description provided for @metric_steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get metric_steps;

  /// No description provided for @metric_sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get metric_sleep;

  /// No description provided for @metric_heart_rate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get metric_heart_rate;

  /// No description provided for @unit_steps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get unit_steps;

  /// No description provided for @unit_hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get unit_hours;

  /// No description provided for @unit_bpm.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get unit_bpm;

  /// No description provided for @quick_actions_visibility.
  ///
  /// In en, this message translates to:
  /// **'Quick Access Visibility'**
  String get quick_actions_visibility;

  /// No description provided for @personal_notes.
  ///
  /// In en, this message translates to:
  /// **'Personal Notes'**
  String get personal_notes;

  /// No description provided for @save_and_list.
  ///
  /// In en, this message translates to:
  /// **'Save and List'**
  String get save_and_list;

  /// No description provided for @doctor_info.
  ///
  /// In en, this message translates to:
  /// **'Doctor Information'**
  String get doctor_info;

  /// No description provided for @add_doctor_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep your doctors contact info for quick access.'**
  String get add_doctor_desc;

  /// No description provided for @basic_info.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basic_info;

  /// No description provided for @institution_contact.
  ///
  /// In en, this message translates to:
  /// **'Institution & Contact'**
  String get institution_contact;

  /// No description provided for @notes_bio.
  ///
  /// In en, this message translates to:
  /// **'Notes & Bio'**
  String get notes_bio;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @hospital_clinic_name.
  ///
  /// In en, this message translates to:
  /// **'Hospital / Clinic Name'**
  String get hospital_clinic_name;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @emergency_info.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY INFORMATION'**
  String get emergency_info;

  /// No description provided for @emergency_contact_name.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact (Name)'**
  String get emergency_contact_name;

  /// No description provided for @emergency_contact_phone.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact (Phone)'**
  String get emergency_contact_phone;

  /// No description provided for @blood_type.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get blood_type;

  /// No description provided for @blood_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get blood_unknown;

  /// No description provided for @profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated! ✅'**
  String get profile_updated;

  /// No description provided for @please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get please_enter_name;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @let_start.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start'**
  String get let_start;

  /// No description provided for @ob_1_title.
  ///
  /// In en, this message translates to:
  /// **'VitaCase'**
  String get ob_1_title;

  /// No description provided for @ob_1_subtitle.
  ///
  /// In en, this message translates to:
  /// **'All Your Files in One Place'**
  String get ob_1_subtitle;

  /// No description provided for @ob_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Store your documents, appointments, and medications safely, always carry them with you.'**
  String get ob_1_desc;

  /// No description provided for @ob_2_title.
  ///
  /// In en, this message translates to:
  /// **'Organize All Your Files'**
  String get ob_2_title;

  /// No description provided for @ob_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Upload your documents, categorize them, and manage them easily.'**
  String get ob_2_desc;

  /// No description provided for @ob_3_title.
  ///
  /// In en, this message translates to:
  /// **'Save Your Appointments'**
  String get ob_3_title;

  /// No description provided for @ob_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep all your appointments in one place, never miss one with reminders.'**
  String get ob_3_desc;

  /// No description provided for @ob_4_title.
  ///
  /// In en, this message translates to:
  /// **'Save and Track Your Medications'**
  String get ob_4_title;

  /// No description provided for @ob_4_desc.
  ///
  /// In en, this message translates to:
  /// **'Record your medications and usage times, don’t forget to use them regularly with reminders.'**
  String get ob_4_desc;

  /// No description provided for @ob_5_title.
  ///
  /// In en, this message translates to:
  /// **'Save, Don’t Lose'**
  String get ob_5_title;

  /// No description provided for @ob_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep your appointments and medications safe, you stay relaxed.'**
  String get ob_5_desc;

  /// No description provided for @ob_feature_1_title.
  ///
  /// In en, this message translates to:
  /// **'Secure Storage'**
  String get ob_feature_1_title;

  /// No description provided for @ob_feature_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and only belongs to you.'**
  String get ob_feature_1_desc;

  /// No description provided for @ob_feature_2_title.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get ob_feature_2_title;

  /// No description provided for @ob_feature_2_desc.
  ///
  /// In en, this message translates to:
  /// **'Never miss your appointment and medication times.'**
  String get ob_feature_2_desc;

  /// No description provided for @ob_feature_3_title.
  ///
  /// In en, this message translates to:
  /// **'Access Everywhere'**
  String get ob_feature_3_title;

  /// No description provided for @ob_feature_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Access all your information whenever you want.'**
  String get ob_feature_3_desc;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'GOOD MORNING'**
  String get good_morning;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'GOOD AFTERNOON'**
  String get good_afternoon;

  /// No description provided for @good_evening.
  ///
  /// In en, this message translates to:
  /// **'GOOD EVENING'**
  String get good_evening;

  /// No description provided for @good_night.
  ///
  /// In en, this message translates to:
  /// **'GOOD NIGHT'**
  String get good_night;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @guest_mode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode Active'**
  String get guest_mode;

  /// No description provided for @guest_desc.
  ///
  /// In en, this message translates to:
  /// **'Data is local only. Create an account to back up.'**
  String get guest_desc;

  /// No description provided for @guest_user.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guest_user;

  /// No description provided for @all_records.
  ///
  /// In en, this message translates to:
  /// **'Secure Archive'**
  String get all_records;

  /// No description provided for @vault_is_empty.
  ///
  /// In en, this message translates to:
  /// **'Your Vault is Ready'**
  String get vault_is_empty;

  /// No description provided for @vault_desc.
  ///
  /// In en, this message translates to:
  /// **'Store and organize your most important records in a private sanctuary.'**
  String get vault_desc;

  /// No description provided for @quick_access.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACCESS'**
  String get quick_access;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @heart.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get heart;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ML'**
  String get ml;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @vault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vault;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @pharmacies.
  ///
  /// In en, this message translates to:
  /// **'Pharmacies'**
  String get pharmacies;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @health_data.
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get health_data;

  /// No description provided for @important_info.
  ///
  /// In en, this message translates to:
  /// **'Important Info'**
  String get important_info;

  /// No description provided for @create_profile.
  ///
  /// In en, this message translates to:
  /// **'Create Your Profile'**
  String get create_profile;

  /// No description provided for @profile_desc.
  ///
  /// In en, this message translates to:
  /// **'We need a few details to personalize your journey.'**
  String get profile_desc;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get full_name;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'GENDER'**
  String get gender;

  /// No description provided for @birth_date.
  ///
  /// In en, this message translates to:
  /// **'DATE OF BIRTH'**
  String get birth_date;

  /// No description provided for @date_format_hint.
  ///
  /// In en, this message translates to:
  /// **'DD.MM.YYYY'**
  String get date_format_hint;

  /// No description provided for @save_continue.
  ///
  /// In en, this message translates to:
  /// **'Save and Continue'**
  String get save_continue;

  /// No description provided for @security_badge_label.
  ///
  /// In en, this message translates to:
  /// **'VITACASE ADVANCED ENCRYPTION v2.4'**
  String get security_badge_label;

  /// No description provided for @health_stats.
  ///
  /// In en, this message translates to:
  /// **'Health Hub'**
  String get health_stats;

  /// No description provided for @health_stats_desc.
  ///
  /// In en, this message translates to:
  /// **'Your comprehensive daily health summary.'**
  String get health_stats_desc;

  /// No description provided for @recent_activity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recent_activity;

  /// No description provided for @no_health_records.
  ///
  /// In en, this message translates to:
  /// **'No records found yet.'**
  String get no_health_records;

  /// No description provided for @add_health_data.
  ///
  /// In en, this message translates to:
  /// **'Add Health Data'**
  String get add_health_data;

  /// No description provided for @step_unit.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get step_unit;

  /// No description provided for @privacy_guarantee.
  ///
  /// In en, this message translates to:
  /// **'Your data is safe'**
  String get privacy_guarantee;

  /// No description provided for @privacy_box_desc.
  ///
  /// In en, this message translates to:
  /// **'Your information is securely stored and never shared.'**
  String get privacy_box_desc;

  /// No description provided for @privacy_box_warning.
  ///
  /// In en, this message translates to:
  /// **'Your data is private and stored securely on your device. Please avoid uploading highly sensitive information. You are responsible for the data you store.'**
  String get privacy_box_warning;

  /// No description provided for @docs_secure_storage_title.
  ///
  /// In en, this message translates to:
  /// **'Secure Local Storage 🔒'**
  String get docs_secure_storage_title;

  /// No description provided for @docs_secure_storage_desc.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get docs_secure_storage_desc;

  /// No description provided for @docs_sensitive_warning.
  ///
  /// In en, this message translates to:
  /// **'Avoid storing highly sensitive information. You are responsible for your data.'**
  String get docs_sensitive_warning;

  /// No description provided for @gender_female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get gender_female;

  /// No description provided for @gender_male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get gender_male;

  /// No description provided for @gender_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get gender_other;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @theme_settings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get theme_settings;

  /// No description provided for @app_settings.
  ///
  /// In en, this message translates to:
  /// **'APP SETTINGS'**
  String get app_settings;

  /// No description provided for @text_size.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get text_size;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @data_security.
  ///
  /// In en, this message translates to:
  /// **'DATA & SECURITY'**
  String get data_security;

  /// No description provided for @app_lock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get app_lock;

  /// No description provided for @backup_zip.
  ///
  /// In en, this message translates to:
  /// **'Backup (ZIP)'**
  String get backup_zip;

  /// No description provided for @import_backup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get import_backup;

  /// No description provided for @import_desc.
  ///
  /// In en, this message translates to:
  /// **'Import a ZIP backup file'**
  String get import_desc;

  /// No description provided for @export_desc.
  ///
  /// In en, this message translates to:
  /// **'Export documents'**
  String get export_desc;

  /// No description provided for @emergency_contact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergency_contact;

  /// No description provided for @daily_step_goal.
  ///
  /// In en, this message translates to:
  /// **'Daily Step Goal'**
  String get daily_step_goal;

  /// No description provided for @support_legal.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT & LEGAL'**
  String get support_legal;

  /// No description provided for @help_center.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get help_center;

  /// No description provided for @report_issue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get report_issue;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @terms_conditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get terms_conditions;

  /// No description provided for @legal_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer'**
  String get legal_disclaimer;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get legal;

  /// No description provided for @lock_gate_title.
  ///
  /// In en, this message translates to:
  /// **'VitaCase Locked'**
  String get lock_gate_title;

  /// No description provided for @lock_gate_desc.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access your secure document vault.'**
  String get lock_gate_desc;

  /// No description provided for @lock_gate_unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Biometrics'**
  String get lock_gate_unlock;

  /// No description provided for @lock_set_pin.
  ///
  /// In en, this message translates to:
  /// **'Set Secure PIN'**
  String get lock_set_pin;

  /// No description provided for @lock_confirm_pin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get lock_confirm_pin;

  /// No description provided for @lock_pin_mismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get lock_pin_mismatch;

  /// No description provided for @lock_pin_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get lock_pin_incorrect;

  /// No description provided for @lock_use_biometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get lock_use_biometrics;

  /// No description provided for @lock_too_many_attempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s.'**
  String lock_too_many_attempts(Object seconds);

  /// No description provided for @lock_timeout_instant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get lock_timeout_instant;

  /// No description provided for @lock_timeout_1min.
  ///
  /// In en, this message translates to:
  /// **'1 Minute'**
  String get lock_timeout_1min;

  /// No description provided for @lock_timeout_5min.
  ///
  /// In en, this message translates to:
  /// **'5 Minutes'**
  String get lock_timeout_5min;

  /// No description provided for @lock_timeout_15min.
  ///
  /// In en, this message translates to:
  /// **'15 Minutes'**
  String get lock_timeout_15min;

  /// No description provided for @lock_timeout.
  ///
  /// In en, this message translates to:
  /// **'Lock Timeout'**
  String get lock_timeout;

  /// No description provided for @change_pin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get change_pin;

  /// No description provided for @biometric_login.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometric_login;

  /// No description provided for @biometric_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device.'**
  String get biometric_unavailable;

  /// No description provided for @digits.
  ///
  /// In en, this message translates to:
  /// **'digits'**
  String get digits;

  /// No description provided for @lock_skip_desc.
  ///
  /// In en, this message translates to:
  /// **'You can set this up later from Settings.'**
  String get lock_skip_desc;

  /// No description provided for @setup_pin_later.
  ///
  /// In en, this message translates to:
  /// **'Set up later from Settings'**
  String get setup_pin_later;

  /// No description provided for @skip_pin_setup.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip_pin_setup;

  /// No description provided for @setup_app_lock.
  ///
  /// In en, this message translates to:
  /// **'Set Up App Lock'**
  String get setup_app_lock;

  /// No description provided for @setup_app_lock_desc.
  ///
  /// In en, this message translates to:
  /// **'Protect your data with a 6-digit PIN.'**
  String get setup_app_lock_desc;

  /// No description provided for @step_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get step_profile;

  /// No description provided for @step_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get step_security;

  /// No description provided for @daily_missions.
  ///
  /// In en, this message translates to:
  /// **'DAILY MISSIONS'**
  String get daily_missions;

  /// No description provided for @mission_doc_daily.
  ///
  /// In en, this message translates to:
  /// **'Add 1 Document'**
  String get mission_doc_daily;

  /// No description provided for @mission_ad_daily.
  ///
  /// In en, this message translates to:
  /// **'Watch 1 Ad'**
  String get mission_ad_daily;

  /// No description provided for @mission_app_daily.
  ///
  /// In en, this message translates to:
  /// **'Schedule 1 Appointment'**
  String get mission_app_daily;

  /// No description provided for @mission_med_daily.
  ///
  /// In en, this message translates to:
  /// **'Add 1 Medicine'**
  String get mission_med_daily;

  /// No description provided for @export_data_zip.
  ///
  /// In en, this message translates to:
  /// **'Export Data (.zip)'**
  String get export_data_zip;

  /// No description provided for @clear_all_data.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clear_all_data;

  /// No description provided for @quick_actions_desc.
  ///
  /// In en, this message translates to:
  /// **'Quick shortcuts on dashboard'**
  String get quick_actions_desc;

  /// No description provided for @app_section.
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get app_section;

  /// No description provided for @premium_required.
  ///
  /// In en, this message translates to:
  /// **'Premium Required'**
  String get premium_required;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logout_confirm;

  /// No description provided for @yes_logout.
  ///
  /// In en, this message translates to:
  /// **'Yes, Logout'**
  String get yes_logout;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'VERSION'**
  String get version;

  /// No description provided for @my_medicines.
  ///
  /// In en, this message translates to:
  /// **'My Medicines'**
  String get my_medicines;

  /// No description provided for @med_count_desc.
  ///
  /// In en, this message translates to:
  /// **'You have {count} medicines for today.'**
  String med_count_desc(Object count);

  /// No description provided for @low_stock_warning.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get low_stock_warning;

  /// No description provided for @critical_level.
  ///
  /// In en, this message translates to:
  /// **'Critical level for {name}.'**
  String critical_level(Object name);

  /// No description provided for @refill.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get refill;

  /// No description provided for @intake_chart.
  ///
  /// In en, this message translates to:
  /// **'Intake Compliance Chart'**
  String get intake_chart;

  /// No description provided for @weekly_avg.
  ///
  /// In en, this message translates to:
  /// **'Weekly Avg: {perc}%'**
  String weekly_avg(Object perc);

  /// No description provided for @medicine_cabinet.
  ///
  /// In en, this message translates to:
  /// **'Medicine Cabinet'**
  String get medicine_cabinet;

  /// No description provided for @active_inventory.
  ///
  /// In en, this message translates to:
  /// **'Your active inventory'**
  String get active_inventory;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @daily_routine.
  ///
  /// In en, this message translates to:
  /// **'Daily Routine'**
  String get daily_routine;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @med_cabinet_add.
  ///
  /// In en, this message translates to:
  /// **'New Medicine'**
  String get med_cabinet_add;

  /// No description provided for @stock_left.
  ///
  /// In en, this message translates to:
  /// **'{count} LEFT'**
  String stock_left(Object count);

  /// No description provided for @vital_signs.
  ///
  /// In en, this message translates to:
  /// **'Vital Signs'**
  String get vital_signs;

  /// No description provided for @daily_goals.
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get daily_goals;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @step_counter.
  ///
  /// In en, this message translates to:
  /// **'Step Counter'**
  String get step_counter;

  /// No description provided for @water_tracker.
  ///
  /// In en, this message translates to:
  /// **'Water Tracker'**
  String get water_tracker;

  /// No description provided for @safety_footer_med.
  ///
  /// In en, this message translates to:
  /// **'VitaCase is a management tool. It does not provide medical advice or dosage recommendations. Always follow your doctor\'s instructions.'**
  String get safety_footer_med;

  /// No description provided for @safety_footer_health.
  ///
  /// In en, this message translates to:
  /// **'Health data is for informational purposes only. Consult a professional for diagnosis.'**
  String get safety_footer_health;

  /// No description provided for @medical_device_warning.
  ///
  /// In en, this message translates to:
  /// **'VitaCase is not a medical device. Always consult a professional.'**
  String get medical_device_warning;

  /// No description provided for @management_tool_warning.
  ///
  /// In en, this message translates to:
  /// **'VitaCase is a management tool, not a diagnostic service.'**
  String get management_tool_warning;

  /// No description provided for @hint_name.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get hint_name;

  /// No description provided for @hint_emergency.
  ///
  /// In en, this message translates to:
  /// **'Full Name / Phone'**
  String get hint_emergency;

  /// No description provided for @docs_title.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get docs_title;

  /// No description provided for @docs_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search your vault (document, note, identity...)'**
  String get docs_search_hint;

  /// No description provided for @docs_info_secure.
  ///
  /// In en, this message translates to:
  /// **'Your documents are stored securely and are exclusive to you.'**
  String get docs_info_secure;

  /// No description provided for @docs_info_encrypted.
  ///
  /// In en, this message translates to:
  /// **'Your data is protected locally with encryption.'**
  String get docs_info_encrypted;

  /// No description provided for @docs_sort_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get docs_sort_all;

  /// No description provided for @docs_sort_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get docs_sort_newest;

  /// No description provided for @docs_sort_oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get docs_sort_oldest;

  /// No description provided for @docs_empty_title.
  ///
  /// In en, this message translates to:
  /// **'It\'s Empty Here'**
  String get docs_empty_title;

  /// No description provided for @docs_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Start organizing your vault by adding your first document.'**
  String get docs_empty_subtitle;

  /// No description provided for @docs_category_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get docs_category_health;

  /// No description provided for @docs_category_identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get docs_category_identity;

  /// No description provided for @docs_category_finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get docs_category_finance;

  /// No description provided for @docs_category_legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get docs_category_legal;

  /// No description provided for @docs_category_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get docs_category_notes;

  /// No description provided for @docs_category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get docs_category_other;

  /// No description provided for @docs_loading_open.
  ///
  /// In en, this message translates to:
  /// **'Opening Secure File...'**
  String get docs_loading_open;

  /// No description provided for @docs_loading_decrypt.
  ///
  /// In en, this message translates to:
  /// **'AES-256 Decrypting'**
  String get docs_loading_decrypt;

  /// No description provided for @docs_add_btn.
  ///
  /// In en, this message translates to:
  /// **'ADD DOCUMENT'**
  String get docs_add_btn;

  /// No description provided for @docs_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get docs_add_title;

  /// No description provided for @docs_add_source.
  ///
  /// In en, this message translates to:
  /// **'Source / Institution (optional)'**
  String get docs_add_source;

  /// No description provided for @docs_add_person.
  ///
  /// In en, this message translates to:
  /// **'Related Person / Detail'**
  String get docs_add_person;

  /// No description provided for @docs_add_cat.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get docs_add_cat;

  /// No description provided for @docs_add_type.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get docs_add_type;

  /// No description provided for @docs_add_note.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get docs_add_note;

  /// No description provided for @docs_add_secure.
  ///
  /// In en, this message translates to:
  /// **'This info is encrypted with AES-256.'**
  String get docs_add_secure;

  /// No description provided for @docs_add_pick_diff.
  ///
  /// In en, this message translates to:
  /// **'Pick different file'**
  String get docs_add_pick_diff;

  /// No description provided for @docs_success.
  ///
  /// In en, this message translates to:
  /// **'Document saved successfully!'**
  String get docs_success;

  /// No description provided for @docs_error_save.
  ///
  /// In en, this message translates to:
  /// **'Failed to save document'**
  String get docs_error_save;

  /// No description provided for @docs_error_pick.
  ///
  /// In en, this message translates to:
  /// **'Please select a file'**
  String get docs_error_pick;

  /// No description provided for @docs_error_source.
  ///
  /// In en, this message translates to:
  /// **'Institution name is required for health docs'**
  String get docs_error_source;

  /// No description provided for @docs_error_size.
  ///
  /// In en, this message translates to:
  /// **'File size must be max 10 MB'**
  String get docs_error_size;

  /// No description provided for @docs_add_pick.
  ///
  /// In en, this message translates to:
  /// **'Select Document / Image'**
  String get docs_add_pick;

  /// No description provided for @docs_add_file_selected.
  ///
  /// In en, this message translates to:
  /// **'Selected File'**
  String get docs_add_file_selected;

  /// No description provided for @docs_action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get docs_action_delete;

  /// No description provided for @docs_no_results.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get docs_no_results;

  /// No description provided for @docs_no_matching.
  ///
  /// In en, this message translates to:
  /// **'No documents match your criteria'**
  String get docs_no_matching;

  /// No description provided for @docs_try_different.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different keyword.'**
  String get docs_try_different;

  /// No description provided for @docs_no_filter_match.
  ///
  /// In en, this message translates to:
  /// **'No documents found for the selected filter.'**
  String get docs_no_filter_match;

  /// No description provided for @docs_show_all.
  ///
  /// In en, this message translates to:
  /// **'SHOW ALL'**
  String get docs_show_all;

  /// No description provided for @privacy_warning_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Warning'**
  String get privacy_warning_title;

  /// No description provided for @privacy_warning_desc.
  ///
  /// In en, this message translates to:
  /// **'The sole responsibility for any sensitive information and uploaded documents belongs entirely to the user. Please be cautious when storing high-risk data.'**
  String get privacy_warning_desc;

  /// No description provided for @hint_select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get hint_select;

  /// No description provided for @hint_institution.
  ///
  /// In en, this message translates to:
  /// **'e.g. City Hospital, Bank, Notary'**
  String get hint_institution;

  /// No description provided for @hint_person_detail.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr. Mehmet, Lawyer Ahmet, Tax No'**
  String get hint_person_detail;

  /// No description provided for @hint_add_note.
  ///
  /// In en, this message translates to:
  /// **'Add note...'**
  String get hint_add_note;

  /// No description provided for @docs_category_prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get docs_category_prescriptions;

  /// No description provided for @docs_category_reports.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get docs_category_reports;

  /// No description provided for @docs_category_test_results.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get docs_category_test_results;

  /// No description provided for @docs_category_images.
  ///
  /// In en, this message translates to:
  /// **'Medical Image'**
  String get docs_category_images;

  /// No description provided for @upcoming_appointment.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING APPOINTMENT'**
  String get upcoming_appointment;

  /// No description provided for @my_appointments.
  ///
  /// In en, this message translates to:
  /// **'My Appointments'**
  String get my_appointments;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @no_more_appointments.
  ///
  /// In en, this message translates to:
  /// **'No more appointments found.'**
  String get no_more_appointments;

  /// No description provided for @add_new_appointment.
  ///
  /// In en, this message translates to:
  /// **'Add New Appointment'**
  String get add_new_appointment;

  /// No description provided for @join_meeting.
  ///
  /// In en, this message translates to:
  /// **'Join Meeting'**
  String get join_meeting;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @health_trend_desc.
  ///
  /// In en, this message translates to:
  /// **'7-Day Health Trend'**
  String get health_trend_desc;

  /// No description provided for @all_records_title.
  ///
  /// In en, this message translates to:
  /// **'All Records'**
  String get all_records_title;

  /// No description provided for @personal_health_data.
  ///
  /// In en, this message translates to:
  /// **'Personal Health Data'**
  String get personal_health_data;

  /// No description provided for @personal_info.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_info;

  /// No description provided for @account_settings.
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get account_settings;

  /// No description provided for @emergency_card.
  ///
  /// In en, this message translates to:
  /// **'Emergency Card'**
  String get emergency_card;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'ALLERGIES'**
  String get allergies;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @not_added.
  ///
  /// In en, this message translates to:
  /// **'Not Added'**
  String get not_added;

  /// No description provided for @active_goals.
  ///
  /// In en, this message translates to:
  /// **'Active Goals'**
  String get active_goals;

  /// No description provided for @daily_steps.
  ///
  /// In en, this message translates to:
  /// **'Daily Steps'**
  String get daily_steps;

  /// No description provided for @water_intake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get water_intake;

  /// No description provided for @liter_unit.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get liter_unit;

  /// No description provided for @speed_up.
  ///
  /// In en, this message translates to:
  /// **'SPEED UP'**
  String get speed_up;

  /// No description provided for @stay_fresh.
  ///
  /// In en, this message translates to:
  /// **'STAY FRESH'**
  String get stay_fresh;

  /// No description provided for @target_label.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target_label;

  /// No description provided for @logout_desc_safe.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? Your data will remain securely stored on your device.'**
  String get logout_desc_safe;

  /// No description provided for @years_old.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get years_old;

  /// No description provided for @add_medicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get add_medicine;

  /// No description provided for @medicine_name.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicine_name;

  /// No description provided for @med_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Aspirin'**
  String get med_name_hint;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @reminder_times.
  ///
  /// In en, this message translates to:
  /// **'Reminder Times'**
  String get reminder_times;

  /// No description provided for @current_stock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get current_stock;

  /// No description provided for @stock_warning.
  ///
  /// In en, this message translates to:
  /// **'We will remind you when stock falls below 5 units.'**
  String get stock_warning;

  /// No description provided for @hero_health_tip.
  ///
  /// In en, this message translates to:
  /// **'For Your Health'**
  String get hero_health_tip;

  /// No description provided for @hero_consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency is key'**
  String get hero_consistency;

  /// No description provided for @med_added_success.
  ///
  /// In en, this message translates to:
  /// **'Medicine added successfully!'**
  String get med_added_success;

  /// No description provided for @med_name_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter medicine name'**
  String get med_name_error;

  /// No description provided for @custom_freq_title.
  ///
  /// In en, this message translates to:
  /// **'Custom Frequency'**
  String get custom_freq_title;

  /// No description provided for @custom_freq_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Every 2 weeks'**
  String get custom_freq_hint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @tablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// No description provided for @syrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup (ml)'**
  String get syrup;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @capsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get capsule;

  /// No description provided for @drops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get drops;

  /// No description provided for @limit_title.
  ///
  /// In en, this message translates to:
  /// **'Storage Full! 🚀'**
  String get limit_title;

  /// No description provided for @limit_desc.
  ///
  /// In en, this message translates to:
  /// **'Your current limit is {count} documents. Would you like to watch a short video to gain +5 more slots?'**
  String limit_desc(Object count);

  /// No description provided for @limit_desc_meds.
  ///
  /// In en, this message translates to:
  /// **'Your current limit is {count} medicines. Would you like to watch a short video to gain +5 more slots?'**
  String limit_desc_meds(Object count);

  /// No description provided for @limit_desc_appts.
  ///
  /// In en, this message translates to:
  /// **'Your current limit is {count} appointments. Would you like to watch a short video to gain +5 more slots?'**
  String limit_desc_appts(Object count);

  /// No description provided for @limit_close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get limit_close;

  /// No description provided for @limit_reward_btn.
  ///
  /// In en, this message translates to:
  /// **'WATCH AND GAIN'**
  String get limit_reward_btn;

  /// No description provided for @limit_reward_success.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! +10 document slots added.'**
  String get limit_reward_success;

  /// No description provided for @limit_ad_free_info.
  ///
  /// In en, this message translates to:
  /// **'Safe & Private Local Storage 🛡️'**
  String get limit_ad_free_info;

  /// No description provided for @limit_slots_used.
  ///
  /// In en, this message translates to:
  /// **'{count}/{limit} slots used'**
  String limit_slots_used(Object count, Object limit);

  /// No description provided for @lock_title.
  ///
  /// In en, this message translates to:
  /// **'VitaCase Locked'**
  String get lock_title;

  /// No description provided for @lock_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Please verify to access'**
  String get lock_subtitle;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @bmi_underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmi_underweight;

  /// No description provided for @bmi_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal (Ideal)'**
  String get bmi_normal;

  /// No description provided for @bmi_overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmi_overweight;

  /// No description provided for @bmi_obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmi_obese;

  /// No description provided for @page_not_found.
  ///
  /// In en, this message translates to:
  /// **'Page not found or an error occurred.'**
  String get page_not_found;

  /// No description provided for @legal_onboarding_clause.
  ///
  /// In en, this message translates to:
  /// **'I acknowledge that VitaCase is an offline-first vault. I bear sole responsibility for the security of my device and the sensitive health data stored within it.'**
  String get legal_onboarding_clause;

  /// No description provided for @delete_all_data.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get delete_all_data;

  /// No description provided for @wipe_confirm_1.
  ///
  /// In en, this message translates to:
  /// **'All your data, documents, and settings will be permanently deleted. This action cannot be undone. Do you want to continue?'**
  String get wipe_confirm_1;

  /// No description provided for @wipe_confirm_2.
  ///
  /// In en, this message translates to:
  /// **'Are you ABSOLUTELY sure? All your medical archive and encrypted records will be wiped from this device.'**
  String get wipe_confirm_2;

  /// No description provided for @final_warning.
  ///
  /// In en, this message translates to:
  /// **'Final Security Warning'**
  String get final_warning;

  /// No description provided for @wipe_btn_final.
  ///
  /// In en, this message translates to:
  /// **'YES, DELETE EVERYTHING'**
  String get wipe_btn_final;

  /// No description provided for @all_data_deleted.
  ///
  /// In en, this message translates to:
  /// **'All your data has been wiped. The app will now restart.'**
  String get all_data_deleted;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @theme_selection_title.
  ///
  /// In en, this message translates to:
  /// **'Theme Selection'**
  String get theme_selection_title;

  /// No description provided for @watch_ad.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watch_ad;

  /// No description provided for @verify_sentry.
  ///
  /// In en, this message translates to:
  /// **'Verify Sentry Integration'**
  String get verify_sentry;

  /// No description provided for @edit_panel_soon.
  ///
  /// In en, this message translates to:
  /// **'Edit panel coming soon!'**
  String get edit_panel_soon;

  /// No description provided for @add_new_record.
  ///
  /// In en, this message translates to:
  /// **'Add New Record'**
  String get add_new_record;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @fill_required_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill required fields'**
  String get fill_required_fields;

  /// No description provided for @error_doctor_data.
  ///
  /// In en, this message translates to:
  /// **'Please enter doctor name and department'**
  String get error_doctor_data;

  /// No description provided for @error_appointment_data.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the title and hospital/center fields'**
  String get error_appointment_data;

  /// No description provided for @appointment_reminder_title.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get appointment_reminder_title;

  /// No description provided for @appointment_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'You have an appointment in {time}: {doctor} ({dept})'**
  String appointment_reminder_body(Object dept, Object doctor, Object time);

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language / Dil Seçin'**
  String get select_language;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @text_size_small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get text_size_small;

  /// No description provided for @text_size_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get text_size_medium;

  /// No description provided for @text_size_large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get text_size_large;

  /// No description provided for @support_contact.
  ///
  /// In en, this message translates to:
  /// **'To contact our support team: limanexsoftware@outlook.com'**
  String get support_contact;

  /// No description provided for @quick_actions_optimized.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions are already optimized for your profile.'**
  String get quick_actions_optimized;

  /// No description provided for @medication_reminder.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get medication_reminder;

  /// No description provided for @medication_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'Time for {name} ({dose})'**
  String medication_reminder_body(Object dose, Object name);

  /// No description provided for @no_doctors_found.
  ///
  /// In en, this message translates to:
  /// **'No matching doctors found'**
  String get no_doctors_found;

  /// No description provided for @clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clear_filters;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @height_label.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height_label;

  /// No description provided for @weight_label.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight_label;

  /// No description provided for @age_label.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age_label;

  /// No description provided for @identity_contact.
  ///
  /// In en, this message translates to:
  /// **'Identity & Contact'**
  String get identity_contact;

  /// No description provided for @id_number.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get id_number;

  /// No description provided for @update_info.
  ///
  /// In en, this message translates to:
  /// **'Update Info'**
  String get update_info;

  /// No description provided for @vita_badge.
  ///
  /// In en, this message translates to:
  /// **'VitaCase User'**
  String get vita_badge;

  /// No description provided for @default_job.
  ///
  /// In en, this message translates to:
  /// **'Freelance / Health Enthusiast'**
  String get default_job;

  /// No description provided for @blood_type_val.
  ///
  /// In en, this message translates to:
  /// **'A Rh+'**
  String get blood_type_val;

  /// No description provided for @clinical_note.
  ///
  /// In en, this message translates to:
  /// **'Clinical Note'**
  String get clinical_note;

  /// No description provided for @last_control.
  ///
  /// In en, this message translates to:
  /// **'Last Control'**
  String get last_control;

  /// No description provided for @bmi_ideal.
  ///
  /// In en, this message translates to:
  /// **'Ideal Weight Range'**
  String get bmi_ideal;

  /// No description provided for @medical_info_desc_empty.
  ///
  /// In en, this message translates to:
  /// **'Store your critical medical information here to carry it with you always.'**
  String get medical_info_desc_empty;

  /// No description provided for @category_critical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL INFORMATION'**
  String get category_critical;

  /// No description provided for @category_important.
  ///
  /// In en, this message translates to:
  /// **'IMPORTANT NOTES'**
  String get category_important;

  /// No description provided for @category_general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL INFORMATION'**
  String get category_general;

  /// No description provided for @medical_info_desc.
  ///
  /// In en, this message translates to:
  /// **'All medical records critical for your health.'**
  String get medical_info_desc;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @save_record.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get save_record;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @important.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get important;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @theme_unlock_desc.
  ///
  /// In en, this message translates to:
  /// **'You can try this theme or watch an ad to unlock it permanently.'**
  String get theme_unlock_desc;

  /// No description provided for @theme_previewing.
  ///
  /// In en, this message translates to:
  /// **'Theme is being previewed for 10 seconds...'**
  String get theme_previewing;

  /// No description provided for @preview_10s.
  ///
  /// In en, this message translates to:
  /// **'Preview (10s)'**
  String get preview_10s;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @theme_unlocked_success.
  ///
  /// In en, this message translates to:
  /// **'Your new theme is unlocked.'**
  String get theme_unlocked_success;

  /// No description provided for @please_enter_at_least_one_data.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one data point.'**
  String get please_enter_at_least_one_data;

  /// No description provided for @data_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully.'**
  String get data_saved_success;

  /// No description provided for @add_data.
  ///
  /// In en, this message translates to:
  /// **'Add Data'**
  String get add_data;

  /// No description provided for @save_data.
  ///
  /// In en, this message translates to:
  /// **'Save Data'**
  String get save_data;

  /// No description provided for @today_summary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get today_summary;

  /// No description provided for @target_water.
  ///
  /// In en, this message translates to:
  /// **'Target Water'**
  String get target_water;

  /// No description provided for @target_steps.
  ///
  /// In en, this message translates to:
  /// **'Target Steps'**
  String get target_steps;

  /// No description provided for @add_doctor.
  ///
  /// In en, this message translates to:
  /// **'Add Doctor'**
  String get add_doctor;

  /// No description provided for @doctor_name_surname.
  ///
  /// In en, this message translates to:
  /// **'Doctor Name Surname'**
  String get doctor_name_surname;

  /// No description provided for @specialty_department.
  ///
  /// In en, this message translates to:
  /// **'Specialty / Department'**
  String get specialty_department;

  /// No description provided for @new_record.
  ///
  /// In en, this message translates to:
  /// **'New Record'**
  String get new_record;

  /// No description provided for @appointment_updated.
  ///
  /// In en, this message translates to:
  /// **'Appointment updated.'**
  String get appointment_updated;

  /// No description provided for @appointment_added.
  ///
  /// In en, this message translates to:
  /// **'Appointment added successfully.'**
  String get appointment_added;

  /// No description provided for @edit_appointment.
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment'**
  String get edit_appointment;

  /// No description provided for @appointment_title.
  ///
  /// In en, this message translates to:
  /// **'Appointment Title'**
  String get appointment_title;

  /// No description provided for @importance_level.
  ///
  /// In en, this message translates to:
  /// **'Importance Level'**
  String get importance_level;

  /// No description provided for @notes_optional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notes_optional;

  /// No description provided for @address_department.
  ///
  /// In en, this message translates to:
  /// **'Full Address / Department'**
  String get address_department;

  /// No description provided for @select_category.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get select_category;

  /// No description provided for @category_meeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get category_meeting;

  /// No description provided for @category_reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get category_reminder;

  /// No description provided for @category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_other;

  /// No description provided for @app_slogan.
  ///
  /// In en, this message translates to:
  /// **'Digital Sanctuary'**
  String get app_slogan;

  /// No description provided for @day_monday_short.
  ///
  /// In en, this message translates to:
  /// **'MON'**
  String get day_monday_short;

  /// No description provided for @day_tuesday_short.
  ///
  /// In en, this message translates to:
  /// **'TUE'**
  String get day_tuesday_short;

  /// No description provided for @day_wednesday_short.
  ///
  /// In en, this message translates to:
  /// **'WED'**
  String get day_wednesday_short;

  /// No description provided for @day_thursday_short.
  ///
  /// In en, this message translates to:
  /// **'THU'**
  String get day_thursday_short;

  /// No description provided for @day_friday_short.
  ///
  /// In en, this message translates to:
  /// **'FRI'**
  String get day_friday_short;

  /// No description provided for @day_saturday_short.
  ///
  /// In en, this message translates to:
  /// **'SAT'**
  String get day_saturday_short;

  /// No description provided for @day_sunday_short.
  ///
  /// In en, this message translates to:
  /// **'SUN'**
  String get day_sunday_short;

  /// No description provided for @day_monday_very_short.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get day_monday_very_short;

  /// No description provided for @day_tuesday_very_short.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get day_tuesday_very_short;

  /// No description provided for @day_wednesday_very_short.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get day_wednesday_very_short;

  /// No description provided for @day_thursday_very_short.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get day_thursday_very_short;

  /// No description provided for @day_friday_very_short.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get day_friday_very_short;

  /// No description provided for @day_saturday_very_short.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get day_saturday_very_short;

  /// No description provided for @day_sunday_very_short.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get day_sunday_very_short;

  /// No description provided for @delete_medicine_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medicine?'**
  String get delete_medicine_confirm;

  /// No description provided for @i_agree_to.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the'**
  String get i_agree_to;

  /// No description provided for @read_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get read_privacy_policy;

  /// No description provided for @read_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get read_terms;

  /// No description provided for @read_disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer'**
  String get read_disclaimer;

  /// No description provided for @must_agree.
  ///
  /// In en, this message translates to:
  /// **'You must agree to all legal documents to continue.'**
  String get must_agree;

  /// No description provided for @legal_acceptance.
  ///
  /// In en, this message translates to:
  /// **'Legal Acceptance'**
  String get legal_acceptance;

  /// No description provided for @manage_subscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manage_subscription;

  /// No description provided for @trust_offline_title.
  ///
  /// In en, this message translates to:
  /// **'Offline Sanctuary'**
  String get trust_offline_title;

  /// No description provided for @trust_offline_desc.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves your device.'**
  String get trust_offline_desc;

  /// No description provided for @trust_encryption_title.
  ///
  /// In en, this message translates to:
  /// **'AES-256 Encryption'**
  String get trust_encryption_title;

  /// No description provided for @trust_encryption_desc.
  ///
  /// In en, this message translates to:
  /// **'Protected with maximum security.'**
  String get trust_encryption_desc;

  /// No description provided for @trust_adfree_desc.
  ///
  /// In en, this message translates to:
  /// **'An uninterrupted experience.'**
  String get trust_adfree_desc;

  /// No description provided for @medals_trophies.
  ///
  /// In en, this message translates to:
  /// **'Medals & Trophies'**
  String get medals_trophies;

  /// No description provided for @cat_streak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get cat_streak;

  /// No description provided for @cat_ads.
  ///
  /// In en, this message translates to:
  /// **'Support & Ads'**
  String get cat_ads;

  /// No description provided for @cat_documents.
  ///
  /// In en, this message translates to:
  /// **'Record Archive'**
  String get cat_documents;

  /// No description provided for @cat_medications.
  ///
  /// In en, this message translates to:
  /// **'Medicine Habits'**
  String get cat_medications;

  /// No description provided for @cat_appointments.
  ///
  /// In en, this message translates to:
  /// **'Clinical Visits'**
  String get cat_appointments;

  /// No description provided for @cat_profile.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get cat_profile;

  /// No description provided for @cat_emergency.
  ///
  /// In en, this message translates to:
  /// **'Safety & Preparation'**
  String get cat_emergency;

  /// No description provided for @cat_health.
  ///
  /// In en, this message translates to:
  /// **'Vital Monitoring'**
  String get cat_health;

  /// No description provided for @cat_engagement.
  ///
  /// In en, this message translates to:
  /// **'App Activity'**
  String get cat_engagement;

  /// No description provided for @cat_special.
  ///
  /// In en, this message translates to:
  /// **'Honors'**
  String get cat_special;

  /// No description provided for @cat_premium.
  ///
  /// In en, this message translates to:
  /// **'Supporters'**
  String get cat_premium;

  /// No description provided for @cat_power_user.
  ///
  /// In en, this message translates to:
  /// **'Legendary Status'**
  String get cat_power_user;

  /// No description provided for @ach_legend_status.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get ach_legend_status;

  /// No description provided for @theme_boutique.
  ///
  /// In en, this message translates to:
  /// **'Theme Boutique'**
  String get theme_boutique;

  /// No description provided for @days_left.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get days_left;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @ach_hidden_desc.
  ///
  /// In en, this message translates to:
  /// **'Keep playing to discover this secret achievement.'**
  String get ach_hidden_desc;

  /// No description provided for @ach_login_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Every legendary journey begins with a single step. You ignited your first streak!'**
  String get ach_login_1_desc;

  /// No description provided for @ach_login_3_title.
  ///
  /// In en, this message translates to:
  /// **'Warming Up'**
  String get ach_login_3_title;

  /// No description provided for @ach_login_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Warm-up laps are over. You\'ve been here for 3 days straight, not bad at all! 🔥'**
  String get ach_login_3_desc;

  /// No description provided for @ach_login_7_title.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get ach_login_7_title;

  /// No description provided for @ach_login_7_desc.
  ///
  /// In en, this message translates to:
  /// **'A whole week! You\'ve learned the ropes and lit the campfire.'**
  String get ach_login_7_desc;

  /// No description provided for @ach_login_14_title.
  ///
  /// In en, this message translates to:
  /// **'Habitual'**
  String get ach_login_14_title;

  /// No description provided for @ach_login_14_desc.
  ///
  /// In en, this message translates to:
  /// **'Two weeks straight! This is how habits are forged. Congrats.'**
  String get ach_login_14_desc;

  /// No description provided for @ach_login_30_title.
  ///
  /// In en, this message translates to:
  /// **'Addicted'**
  String get ach_login_30_title;

  /// No description provided for @ach_login_30_desc.
  ///
  /// In en, this message translates to:
  /// **'A whole month! We both know this is more than just a hobby now.'**
  String get ach_login_30_desc;

  /// No description provided for @ach_login_60_title.
  ///
  /// In en, this message translates to:
  /// **'Loyal User'**
  String get ach_login_60_title;

  /// No description provided for @ach_login_60_desc.
  ///
  /// In en, this message translates to:
  /// **'Two months... Are you paying rent, friend? Welcome to your second home. 🏠'**
  String get ach_login_60_desc;

  /// No description provided for @ach_login_100_title.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get ach_login_100_title;

  /// No description provided for @ach_login_100_desc.
  ///
  /// In en, this message translates to:
  /// **'Century! No power can break a massive 100-day streak. 💯'**
  String get ach_login_100_desc;

  /// No description provided for @ach_login_200_title.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get ach_login_200_title;

  /// No description provided for @ach_login_200_desc.
  ///
  /// In en, this message translates to:
  /// **'200 days. People are starting to suspect you\'re an AI bot. 🤖'**
  String get ach_login_200_desc;

  /// No description provided for @ach_login_365_title.
  ///
  /// In en, this message translates to:
  /// **'Legendary Year'**
  String get ach_login_365_title;

  /// No description provided for @ach_login_365_desc.
  ///
  /// In en, this message translates to:
  /// **'A full Solar year! You\'ve been here through everything. Coronation tomorrow. 👑'**
  String get ach_login_365_desc;

  /// No description provided for @ach_ads_1_title.
  ///
  /// In en, this message translates to:
  /// **'First Ad'**
  String get ach_ads_1_title;

  /// No description provided for @ach_ads_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Ads are good... sometimes. Thanks for the tiny support!'**
  String get ach_ads_1_desc;

  /// No description provided for @ach_ads_5_title.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get ach_ads_5_title;

  /// No description provided for @ach_ads_5_desc.
  ///
  /// In en, this message translates to:
  /// **'You seem to love our sponsors as much as we do.'**
  String get ach_ads_5_desc;

  /// No description provided for @ach_ads_15_title.
  ///
  /// In en, this message translates to:
  /// **'Loyal Viewer'**
  String get ach_ads_15_title;

  /// No description provided for @ach_ads_15_desc.
  ///
  /// In en, this message translates to:
  /// **'Grab your popcorn, you completed a 15-ad marathon. 🍿'**
  String get ach_ads_15_desc;

  /// No description provided for @ach_ads_30_title.
  ///
  /// In en, this message translates to:
  /// **'Keep it Up'**
  String get ach_ads_30_title;

  /// No description provided for @ach_ads_30_desc.
  ///
  /// In en, this message translates to:
  /// **'Like watching TV! Your support is worth its weight in gold.'**
  String get ach_ads_30_desc;

  /// No description provided for @ach_ads_50_title.
  ///
  /// In en, this message translates to:
  /// **'Power User'**
  String get ach_ads_50_title;

  /// No description provided for @ach_ads_50_desc.
  ///
  /// In en, this message translates to:
  /// **'You can now predict which ad is coming to the second.'**
  String get ach_ads_50_desc;

  /// No description provided for @ach_ads_100_title.
  ///
  /// In en, this message translates to:
  /// **'Addicted'**
  String get ach_ads_100_title;

  /// No description provided for @ach_ads_100_desc.
  ///
  /// In en, this message translates to:
  /// **'100 ads! We owe you a special medal for your patience.'**
  String get ach_ads_100_desc;

  /// No description provided for @ach_ads_250_title.
  ///
  /// In en, this message translates to:
  /// **'Ad Master'**
  String get ach_ads_250_title;

  /// No description provided for @ach_ads_250_desc.
  ///
  /// In en, this message translates to:
  /// **'A marketing genius lost on the screen. Your support reached the sky.'**
  String get ach_ads_250_desc;

  /// No description provided for @ach_ads_500_title.
  ///
  /// In en, this message translates to:
  /// **'Monetization King'**
  String get ach_ads_500_title;

  /// No description provided for @ach_ads_500_desc.
  ///
  /// In en, this message translates to:
  /// **'Are you a financier? You\'re single-handedly running the market! 📉'**
  String get ach_ads_500_desc;

  /// No description provided for @ach_doc_1_title.
  ///
  /// In en, this message translates to:
  /// **'First Document'**
  String get ach_doc_1_title;

  /// No description provided for @ach_doc_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Not a government office, but you successfully filed your first document. 📇'**
  String get ach_doc_1_desc;

  /// No description provided for @ach_doc_5_title.
  ///
  /// In en, this message translates to:
  /// **'Beginning'**
  String get ach_doc_5_title;

  /// No description provided for @ach_doc_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Your first folder is almost full. You\'re getting organized.'**
  String get ach_doc_5_desc;

  /// No description provided for @ach_doc_10_title.
  ///
  /// In en, this message translates to:
  /// **'Regular User'**
  String get ach_doc_10_title;

  /// No description provided for @ach_doc_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Files are piling up. Lost and Found would love to work with you.'**
  String get ach_doc_10_desc;

  /// No description provided for @ach_doc_25_title.
  ///
  /// In en, this message translates to:
  /// **'Archivist'**
  String get ach_doc_25_title;

  /// No description provided for @ach_doc_25_desc.
  ///
  /// In en, this message translates to:
  /// **'Paperwork and all... You blew through 25 documents in your archive.'**
  String get ach_doc_25_desc;

  /// No description provided for @ach_doc_50_title.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get ach_doc_50_title;

  /// No description provided for @ach_doc_50_desc.
  ///
  /// In en, this message translates to:
  /// **'Forget secretarial work, this is what a professional filing knight looks like.'**
  String get ach_doc_50_desc;

  /// No description provided for @ach_doc_100_title.
  ///
  /// In en, this message translates to:
  /// **'Vault Master'**
  String get ach_doc_100_title;

  /// No description provided for @ach_doc_100_desc.
  ///
  /// In en, this message translates to:
  /// **'100 documents? Time to appoint a librarian for this massive archive. 📚'**
  String get ach_doc_100_desc;

  /// No description provided for @ach_doc_250_title.
  ///
  /// In en, this message translates to:
  /// **'Data Collector'**
  String get ach_doc_250_title;

  /// No description provided for @ach_doc_250_desc.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Big Data scenarios. You rule the stacks.'**
  String get ach_doc_250_desc;

  /// No description provided for @ach_doc_500_title.
  ///
  /// In en, this message translates to:
  /// **'Digital Archive Expert'**
  String get ach_doc_500_title;

  /// No description provided for @ach_doc_500_desc.
  ///
  /// In en, this message translates to:
  /// **'Digital Library of Alexandria! Your archives will live for generations.'**
  String get ach_doc_500_desc;

  /// No description provided for @ach_med_1_title.
  ///
  /// In en, this message translates to:
  /// **'First Med'**
  String get ach_med_1_title;

  /// No description provided for @ach_med_1_desc.
  ///
  /// In en, this message translates to:
  /// **'You started valuing yourself. A great milestone for your health.'**
  String get ach_med_1_desc;

  /// No description provided for @ach_med_3_title.
  ///
  /// In en, this message translates to:
  /// **'Tracking Started'**
  String get ach_med_3_title;

  /// No description provided for @ach_med_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Loyal to your prescription. Sip water and never miss reminders.'**
  String get ach_med_3_desc;

  /// No description provided for @ach_med_5_title.
  ///
  /// In en, this message translates to:
  /// **'Regular User'**
  String get ach_med_5_title;

  /// No description provided for @ach_med_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Pharmacists\' favorite customer! You maintain your form carefully.'**
  String get ach_med_5_desc;

  /// No description provided for @ach_med_10_title.
  ///
  /// In en, this message translates to:
  /// **'Disciplined'**
  String get ach_med_10_title;

  /// No description provided for @ach_med_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Meds on time, your body works like a clock. 10 times confirmed!'**
  String get ach_med_10_desc;

  /// No description provided for @ach_med_25_title.
  ///
  /// In en, this message translates to:
  /// **'Health Expert'**
  String get ach_med_25_title;

  /// No description provided for @ach_med_25_desc.
  ///
  /// In en, this message translates to:
  /// **'You understand your body\'s language. Med log became an art for you.'**
  String get ach_med_25_desc;

  /// No description provided for @ach_med_50_title.
  ///
  /// In en, this message translates to:
  /// **'Health Master'**
  String get ach_med_50_title;

  /// No description provided for @ach_med_50_desc.
  ///
  /// In en, this message translates to:
  /// **'Even doctors envy your discipline. You are the master of your body chemistry! 🧬'**
  String get ach_med_50_desc;

  /// No description provided for @ach_app_1_title.
  ///
  /// In en, this message translates to:
  /// **'First Appt'**
  String get ach_app_1_title;

  /// No description provided for @ach_app_1_desc.
  ///
  /// In en, this message translates to:
  /// **'No success without naturally planning! First calendar entry safely taken.'**
  String get ach_app_1_desc;

  /// No description provided for @ach_app_3_title.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get ach_app_3_title;

  /// No description provided for @ach_app_3_desc.
  ///
  /// In en, this message translates to:
  /// **'Time Management 101. You rise by staying loyal to your plans.'**
  String get ach_app_3_desc;

  /// No description provided for @ach_app_5_title.
  ///
  /// In en, this message translates to:
  /// **'Organized'**
  String get ach_app_5_title;

  /// No description provided for @ach_app_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Your agenda is filling up. That busy but charismatic person is definitely you.'**
  String get ach_app_5_desc;

  /// No description provided for @ach_app_10_title.
  ///
  /// In en, this message translates to:
  /// **'Disciplined Planner'**
  String get ach_app_10_title;

  /// No description provided for @ach_app_10_desc.
  ///
  /// In en, this message translates to:
  /// **'No need for alarms, there\'s an atomic clock inside your head.'**
  String get ach_app_10_desc;

  /// No description provided for @ach_app_20_title.
  ///
  /// In en, this message translates to:
  /// **'Planner Pro'**
  String get ach_app_20_title;

  /// No description provided for @ach_app_20_desc.
  ///
  /// In en, this message translates to:
  /// **'Everything is clear to the minute... You\'re like a digital assistant!'**
  String get ach_app_20_desc;

  /// No description provided for @ach_app_30_title.
  ///
  /// In en, this message translates to:
  /// **'Master Planner'**
  String get ach_app_30_title;

  /// No description provided for @ach_app_30_desc.
  ///
  /// In en, this message translates to:
  /// **'Time bender! It seems impossible for one person to manage these appts... but it wasn\'t.'**
  String get ach_app_30_desc;

  /// No description provided for @ach_profile_created_title.
  ///
  /// In en, this message translates to:
  /// **'Profile Created'**
  String get ach_profile_created_title;

  /// No description provided for @ach_profile_created_desc.
  ///
  /// In en, this message translates to:
  /// **'Officially joined us. You already made your digital mark!'**
  String get ach_profile_created_desc;

  /// No description provided for @ach_profile_completed_title.
  ///
  /// In en, this message translates to:
  /// **'Profile Completed'**
  String get ach_profile_completed_title;

  /// No description provided for @ach_profile_completed_desc.
  ///
  /// In en, this message translates to:
  /// **'You hate missing gaps, right? All info is perfectly full.'**
  String get ach_profile_completed_desc;

  /// No description provided for @ach_profile_updated_title.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get ach_profile_updated_title;

  /// No description provided for @ach_profile_updated_desc.
  ///
  /// In en, this message translates to:
  /// **'Change is progress! You stayed in the game by refreshing yourself.'**
  String get ach_profile_updated_desc;

  /// No description provided for @ach_profile_with_photo_title.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get ach_profile_with_photo_title;

  /// No description provided for @ach_profile_with_photo_desc.
  ///
  /// In en, this message translates to:
  /// **'Saved from being a faceless avatar. Smile for the camera! 📸'**
  String get ach_profile_with_photo_desc;

  /// No description provided for @ach_profile_master_title.
  ///
  /// In en, this message translates to:
  /// **'Profile Master'**
  String get ach_profile_master_title;

  /// No description provided for @ach_profile_master_desc.
  ///
  /// In en, this message translates to:
  /// **'With your identity and bio, you are the sleekest user in the system.'**
  String get ach_profile_master_desc;

  /// No description provided for @ach_emergency_added_title.
  ///
  /// In en, this message translates to:
  /// **'Emergency Card Added'**
  String get ach_emergency_added_title;

  /// No description provided for @ach_emergency_added_desc.
  ///
  /// In en, this message translates to:
  /// **'Precaution is never left behind. Your emergency shield is active.'**
  String get ach_emergency_added_desc;

  /// No description provided for @ach_emergency_contact_title.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get ach_emergency_contact_title;

  /// No description provided for @ach_emergency_contact_desc.
  ///
  /// In en, this message translates to:
  /// **'It\'s clear who to call in tough times. Circle of trust created. 📞'**
  String get ach_emergency_contact_desc;

  /// No description provided for @ach_emergency_complete_title.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ach_emergency_complete_title;

  /// No description provided for @ach_emergency_complete_desc.
  ///
  /// In en, this message translates to:
  /// **'Ready for scenarios. Security level at the highest.'**
  String get ach_emergency_complete_desc;

  /// No description provided for @ach_emergency_ready_title.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ach_emergency_ready_title;

  /// No description provided for @ach_emergency_ready_desc.
  ///
  /// In en, this message translates to:
  /// **'Everything will work like a clock in red alert. Safely secured.'**
  String get ach_emergency_ready_desc;

  /// No description provided for @ach_emergency_master_title.
  ///
  /// In en, this message translates to:
  /// **'Emergency Master'**
  String get ach_emergency_master_title;

  /// No description provided for @ach_emergency_master_desc.
  ///
  /// In en, this message translates to:
  /// **'Tough and cool enough to manage first aid before an ambulance arrives!'**
  String get ach_emergency_master_desc;

  /// No description provided for @ach_health_1_title.
  ///
  /// In en, this message translates to:
  /// **'First Data'**
  String get ach_health_1_title;

  /// No description provided for @ach_health_1_desc.
  ///
  /// In en, this message translates to:
  /// **'You did yourself a favor today. Your body thanks you from the inside.'**
  String get ach_health_1_desc;

  /// No description provided for @ach_health_5_title.
  ///
  /// In en, this message translates to:
  /// **'Tracking Started'**
  String get ach_health_5_title;

  /// No description provided for @ach_health_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Data is piling up, you are advancing your conversation with your biorhythm.'**
  String get ach_health_5_desc;

  /// No description provided for @ach_health_10_title.
  ///
  /// In en, this message translates to:
  /// **'Health Conscious'**
  String get ach_health_10_title;

  /// No description provided for @ach_health_10_desc.
  ///
  /// In en, this message translates to:
  /// **'You are a statistical wonder! Your body reads like an encrypted book. 📈'**
  String get ach_health_10_desc;

  /// No description provided for @ach_health_20_title.
  ///
  /// In en, this message translates to:
  /// **'Regular Tracking'**
  String get ach_health_20_title;

  /// No description provided for @ach_health_20_desc.
  ///
  /// In en, this message translates to:
  /// **'You are like a machine. Pulse, metrics, steps... none escape your sensors.'**
  String get ach_health_20_desc;

  /// No description provided for @ach_health_50_title.
  ///
  /// In en, this message translates to:
  /// **'Health Expert'**
  String get ach_health_50_title;

  /// No description provided for @ach_health_50_desc.
  ///
  /// In en, this message translates to:
  /// **'Approaching Cyborg level. The bond between you and your bio-data is unbreakable.'**
  String get ach_health_50_desc;

  /// No description provided for @ach_health_master_title.
  ///
  /// In en, this message translates to:
  /// **'Health Master'**
  String get ach_health_master_title;

  /// No description provided for @ach_health_master_desc.
  ///
  /// In en, this message translates to:
  /// **'High priest of the temple! You established absolute mastery over your own body. 🧘'**
  String get ach_health_master_desc;

  /// No description provided for @ach_first_login_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get ach_first_login_title;

  /// No description provided for @ach_first_login_desc.
  ///
  /// In en, this message translates to:
  /// **'The actual adventure is just beginning. You just stepped inside.'**
  String get ach_first_login_desc;

  /// No description provided for @ach_first_upload_title.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get ach_first_upload_title;

  /// No description provided for @ach_first_upload_desc.
  ///
  /// In en, this message translates to:
  /// **'Left your first permanent mark. You are engraved here now.'**
  String get ach_first_upload_desc;

  /// No description provided for @ach_first_ad_title.
  ///
  /// In en, this message translates to:
  /// **'Free User'**
  String get ach_first_ad_title;

  /// No description provided for @ach_first_ad_desc.
  ///
  /// In en, this message translates to:
  /// **'First ad interaction! You gave lifeblood to the ecosystem.'**
  String get ach_first_ad_desc;

  /// No description provided for @ach_first_premium_title.
  ///
  /// In en, this message translates to:
  /// **'Premium User'**
  String get ach_first_premium_title;

  /// No description provided for @ach_first_premium_desc.
  ///
  /// In en, this message translates to:
  /// **'A matter of vision. Enjoy the VIP lounge, the red carpet is rolled out! 🎟️'**
  String get ach_first_premium_desc;

  /// No description provided for @ach_active_3_days_title.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ach_active_3_days_title;

  /// No description provided for @ach_active_3_days_desc.
  ///
  /// In en, this message translates to:
  /// **'Cables are warming up, engines started. We feel your energy.'**
  String get ach_active_3_days_desc;

  /// No description provided for @ach_active_7_days_title.
  ///
  /// In en, this message translates to:
  /// **'Loyal'**
  String get ach_active_7_days_title;

  /// No description provided for @ach_active_7_days_desc.
  ///
  /// In en, this message translates to:
  /// **'Synchronized with the system for a whole week. Things got electric!'**
  String get ach_active_7_days_desc;

  /// No description provided for @ach_active_30_days_title.
  ///
  /// In en, this message translates to:
  /// **'Core User'**
  String get ach_active_30_days_title;

  /// No description provided for @ach_active_30_days_desc.
  ///
  /// In en, this message translates to:
  /// **'Practically honorary staff now. This place wouldn\'t be the same without you.'**
  String get ach_active_30_days_desc;

  /// No description provided for @ach_streak_saved_title.
  ///
  /// In en, this message translates to:
  /// **'Streak Savior'**
  String get ach_streak_saved_title;

  /// No description provided for @ach_streak_saved_desc.
  ///
  /// In en, this message translates to:
  /// **'Returned from the edge! Saving that beautiful streak was a great reflex.'**
  String get ach_streak_saved_desc;

  /// No description provided for @ach_streak_saved_5_title.
  ///
  /// In en, this message translates to:
  /// **'Resilient'**
  String get ach_streak_saved_5_title;

  /// No description provided for @ach_streak_saved_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Not falling despite battle scars, you know how to rise when you stumble.'**
  String get ach_streak_saved_5_desc;

  /// No description provided for @ach_streak_saved_10_title.
  ///
  /// In en, this message translates to:
  /// **'Never Gives Up'**
  String get ach_streak_saved_10_title;

  /// No description provided for @ach_streak_saved_10_desc.
  ///
  /// In en, this message translates to:
  /// **'Are you a Phoenix? Rising from ashes is just a typical Tuesday activity for you. 🐦🔥'**
  String get ach_streak_saved_10_desc;

  /// No description provided for @ach_streak_perfect_30_title.
  ///
  /// In en, this message translates to:
  /// **'Perfect Streak'**
  String get ach_streak_perfect_30_title;

  /// No description provided for @ach_streak_perfect_30_desc.
  ///
  /// In en, this message translates to:
  /// **'Not a single miss. You were perfect for 30 whole days, like a Swiss watch!'**
  String get ach_streak_perfect_30_desc;

  /// No description provided for @ach_premium_trial_used_title.
  ///
  /// In en, this message translates to:
  /// **'Premium Experience'**
  String get ach_premium_trial_used_title;

  /// No description provided for @ach_premium_trial_used_desc.
  ///
  /// In en, this message translates to:
  /// **'Opened the door to privileges. The view is mesmerizing, isn\'t it?'**
  String get ach_premium_trial_used_desc;

  /// No description provided for @ach_limit_breaker_title.
  ///
  /// In en, this message translates to:
  /// **'Limit Breaker'**
  String get ach_limit_breaker_title;

  /// No description provided for @ach_limit_breaker_desc.
  ///
  /// In en, this message translates to:
  /// **'Rules and limits are meant to be bent. You stepped out of the Matrix! 💥'**
  String get ach_limit_breaker_desc;

  /// No description provided for @ach_ad_skip_used_title.
  ///
  /// In en, this message translates to:
  /// **'Ad Skip'**
  String get ach_ad_skip_used_title;

  /// No description provided for @ach_ad_skip_used_desc.
  ///
  /// In en, this message translates to:
  /// **'You said I have no time for this, fast-forwarded time with one click.'**
  String get ach_ad_skip_used_desc;

  /// No description provided for @ach_reward_collector_title.
  ///
  /// In en, this message translates to:
  /// **'Reward Collector'**
  String get ach_reward_collector_title;

  /// No description provided for @ach_reward_collector_desc.
  ///
  /// In en, this message translates to:
  /// **'Scavenged every reward in corner. A true loot hunter! 🎁'**
  String get ach_reward_collector_desc;

  /// No description provided for @ach_multi_feature_user_title.
  ///
  /// In en, this message translates to:
  /// **'Multi Feature User'**
  String get ach_multi_feature_user_title;

  /// No description provided for @ach_multi_feature_user_desc.
  ///
  /// In en, this message translates to:
  /// **'Not a single button left untouched, curious explorer!'**
  String get ach_multi_feature_user_desc;

  /// No description provided for @ach_data_master_title.
  ///
  /// In en, this message translates to:
  /// **'Data Master'**
  String get ach_data_master_title;

  /// No description provided for @ach_data_master_desc.
  ///
  /// In en, this message translates to:
  /// **'Bytes and bits take shape around you. Absolute master of system data.'**
  String get ach_data_master_desc;

  /// No description provided for @ach_organized_master_title.
  ///
  /// In en, this message translates to:
  /// **'Ultra Organized'**
  String get ach_organized_master_title;

  /// No description provided for @ach_organized_master_desc.
  ///
  /// In en, this message translates to:
  /// **'Marie Kondo would tip her hat to your order. Everything is millimetric.'**
  String get ach_organized_master_desc;

  /// No description provided for @ach_security_master_title.
  ///
  /// In en, this message translates to:
  /// **'Security Expert'**
  String get ach_security_master_title;

  /// No description provided for @ach_security_master_desc.
  ///
  /// In en, this message translates to:
  /// **'Your account is a fortress, your passwords a cyber army. Intrusion is impossible! 🔐'**
  String get ach_security_master_desc;

  /// No description provided for @ach_daily_master_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Master'**
  String get ach_daily_master_title;

  /// No description provided for @ach_daily_master_desc.
  ///
  /// In en, this message translates to:
  /// **'Legendary loyal user who sees the sun and stars with us every day.'**
  String get ach_daily_master_desc;

  /// No description provided for @backup_restore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup_restore;

  /// No description provided for @backup_desc_settings.
  ///
  /// In en, this message translates to:
  /// **'Encrypted local backup for this device only'**
  String get backup_desc_settings;

  /// No description provided for @smart_notifications.
  ///
  /// In en, this message translates to:
  /// **'Smart Notifications'**
  String get smart_notifications;

  /// No description provided for @smart_streak_warning.
  ///
  /// In en, this message translates to:
  /// **'🔥 Streak is about to be lost! Why not check your data?'**
  String get smart_streak_warning;

  /// No description provided for @smart_ad_reward.
  ///
  /// In en, this message translates to:
  /// **'🎁 Watch 1 ad → +5 limit! A new opportunity for you today.'**
  String get smart_ad_reward;

  /// No description provided for @smart_doc_bonus.
  ///
  /// In en, this message translates to:
  /// **'📂 Add 1 document today → get a bonus! Keep everything safe.'**
  String get smart_doc_bonus;

  /// No description provided for @smart_default.
  ///
  /// In en, this message translates to:
  /// **'👀 A small update is waiting for you, what can we do today?'**
  String get smart_default;

  /// No description provided for @notif_bonus_ready.
  ///
  /// In en, this message translates to:
  /// **'🎁 Bonus waiting for you! Thanks for your help.'**
  String get notif_bonus_ready;

  /// No description provided for @notif_doc_safe.
  ///
  /// In en, this message translates to:
  /// **'🔥 Good job, your documents are safe! Keep going!'**
  String get notif_doc_safe;

  /// No description provided for @level_up_desc.
  ///
  /// In en, this message translates to:
  /// **'You reached Level {level}! Check your Season Pass for new rewards.'**
  String level_up_desc(Object level);

  /// No description provided for @notifications_active_msg.
  ///
  /// In en, this message translates to:
  /// **'Notifications are active 🔔'**
  String get notifications_active_msg;

  /// No description provided for @show_sensitive_details.
  ///
  /// In en, this message translates to:
  /// **'Show details in notification'**
  String get show_sensitive_details;

  /// No description provided for @sensitive_details_visible.
  ///
  /// In en, this message translates to:
  /// **'Medicine name is visible'**
  String get sensitive_details_visible;

  /// No description provided for @sensitive_details_hidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden (recommended)'**
  String get sensitive_details_hidden;

  /// No description provided for @quiet_hours.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get quiet_hours;

  /// No description provided for @quiet_hours_msg.
  ///
  /// In en, this message translates to:
  /// **'We won\'t disturb you tonight 🌙'**
  String get quiet_hours_msg;

  /// No description provided for @test_notification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get test_notification;

  /// No description provided for @test_notification_desc.
  ///
  /// In en, this message translates to:
  /// **'Test the system immediately'**
  String get test_notification_desc;

  /// No description provided for @test_notification_body.
  ///
  /// In en, this message translates to:
  /// **'This is a test notification'**
  String get test_notification_body;

  /// No description provided for @app_lock_unavailable.
  ///
  /// In en, this message translates to:
  /// **'App lock is unavailable on this device.'**
  String get app_lock_unavailable;

  /// No description provided for @backup_restore_desc.
  ///
  /// In en, this message translates to:
  /// **'You can backup or restore your data encrypted. Backups are stored only on your device.'**
  String get backup_restore_desc;

  /// No description provided for @backup_export.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get backup_export;

  /// No description provided for @backup_export_desc.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted ZIP backup'**
  String get backup_export_desc;

  /// No description provided for @backup_import.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get backup_import;

  /// No description provided for @backup_import_desc.
  ///
  /// In en, this message translates to:
  /// **'Restore from an existing ZIP backup'**
  String get backup_import_desc;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @import_warning_desc.
  ///
  /// In en, this message translates to:
  /// **'Restoring a backup will DELETE your current data and cannot be undone. Do you want to continue?'**
  String get import_warning_desc;

  /// No description provided for @yes_restore.
  ///
  /// In en, this message translates to:
  /// **'Yes, Restore'**
  String get yes_restore;

  /// No description provided for @start_time.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get start_time;

  /// No description provided for @end_time.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get end_time;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @add_record_success.
  ///
  /// In en, this message translates to:
  /// **'Record saved successfully!'**
  String get add_record_success;

  /// No description provided for @delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get delete_confirm;

  /// No description provided for @plus_5_slots.
  ///
  /// In en, this message translates to:
  /// **'+5 Slots Earned! 🚀'**
  String get plus_5_slots;

  /// No description provided for @watch_to_unlock.
  ///
  /// In en, this message translates to:
  /// **'Watch to unlock'**
  String get watch_to_unlock;

  /// No description provided for @remaining_days.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {days} days'**
  String remaining_days(Object days);

  /// No description provided for @add_1_day_success.
  ///
  /// In en, this message translates to:
  /// **'+1 day added! 🎉'**
  String get add_1_day_success;

  /// No description provided for @plus_1_day.
  ///
  /// In en, this message translates to:
  /// **'+1 Day'**
  String get plus_1_day;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'WATCH'**
  String get watch;

  /// No description provided for @unlock_theme_question.
  ///
  /// In en, this message translates to:
  /// **'Would you like to use this theme for 5 days for free?'**
  String get unlock_theme_question;

  /// No description provided for @watch_ad_plus_5.
  ///
  /// In en, this message translates to:
  /// **'WATCH AD (+5 days)'**
  String get watch_ad_plus_5;

  /// No description provided for @preview_5s.
  ///
  /// In en, this message translates to:
  /// **'Preview (5s)'**
  String get preview_5s;

  /// No description provided for @free_secure_release.
  ///
  /// In en, this message translates to:
  /// **'Free secure release'**
  String get free_secure_release;

  /// No description provided for @encrypted_local_desc.
  ///
  /// In en, this message translates to:
  /// **'Your encrypted documents stay local on this device. Ads support the free version.'**
  String get encrypted_local_desc;

  /// No description provided for @premium_soon.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM SOON'**
  String get premium_soon;

  /// No description provided for @label_title.
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get label_title;

  /// No description provided for @label_location.
  ///
  /// In en, this message translates to:
  /// **'LOCATION / INSTITUTION (OPTIONAL)'**
  String get label_location;

  /// No description provided for @label_person.
  ///
  /// In en, this message translates to:
  /// **'RELATED PERSON (OPTIONAL)'**
  String get label_person;

  /// No description provided for @label_date_time.
  ///
  /// In en, this message translates to:
  /// **'DATE & TIME'**
  String get label_date_time;

  /// No description provided for @label_importance.
  ///
  /// In en, this message translates to:
  /// **'IMPORTANCE'**
  String get label_importance;

  /// No description provided for @label_reminder.
  ///
  /// In en, this message translates to:
  /// **'REMINDER'**
  String get label_reminder;

  /// No description provided for @label_repeat.
  ///
  /// In en, this message translates to:
  /// **'REPEAT'**
  String get label_repeat;

  /// No description provided for @label_notes.
  ///
  /// In en, this message translates to:
  /// **'NOTES (OPTIONAL)'**
  String get label_notes;

  /// No description provided for @hint_title.
  ///
  /// In en, this message translates to:
  /// **'e.g. Doctor appointment, Meeting...'**
  String get hint_title;

  /// No description provided for @hint_location.
  ///
  /// In en, this message translates to:
  /// **'Office, Home, Online, Hospital...'**
  String get hint_location;

  /// No description provided for @hint_person.
  ///
  /// In en, this message translates to:
  /// **'Name, Doctor, Lawyer...'**
  String get hint_person;

  /// No description provided for @hint_notes.
  ///
  /// In en, this message translates to:
  /// **'Details, reminders...'**
  String get hint_notes;

  /// No description provided for @suggest_doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get suggest_doctor;

  /// No description provided for @suggest_meeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get suggest_meeting;

  /// No description provided for @suggest_personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get suggest_personal;

  /// No description provided for @importance_low.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get importance_low;

  /// No description provided for @importance_medium.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get importance_medium;

  /// No description provided for @importance_high.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get importance_high;

  /// No description provided for @reminder_10m.
  ///
  /// In en, this message translates to:
  /// **'10 min before'**
  String get reminder_10m;

  /// No description provided for @reminder_1h.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get reminder_1h;

  /// No description provided for @reminder_1d.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminder_1d;

  /// No description provided for @repeat_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get repeat_none;

  /// No description provided for @repeat_daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeat_daily;

  /// No description provided for @repeat_weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeat_weekly;

  /// No description provided for @label_date_added.
  ///
  /// In en, this message translates to:
  /// **'DATE ADDED'**
  String get label_date_added;

  /// No description provided for @label_document_date.
  ///
  /// In en, this message translates to:
  /// **'DOCUMENT DATE'**
  String get label_document_date;

  /// No description provided for @download_to_device.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD TO DEVICE'**
  String get download_to_device;

  /// No description provided for @delete_permanently.
  ///
  /// In en, this message translates to:
  /// **'DELETE PERMANENTLY'**
  String get delete_permanently;

  /// No description provided for @save_document.
  ///
  /// In en, this message translates to:
  /// **'Save Document'**
  String get save_document;

  /// No description provided for @success_doc_saved.
  ///
  /// In en, this message translates to:
  /// **'Document saved successfully!'**
  String get success_doc_saved;

  /// No description provided for @error_failed_download.
  ///
  /// In en, this message translates to:
  /// **'Failed to download: {error}'**
  String error_failed_download(Object error);

  /// No description provided for @btn_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btn_add;

  /// No description provided for @docs_tag_lab.
  ///
  /// In en, this message translates to:
  /// **'Lab Result'**
  String get docs_tag_lab;

  /// No description provided for @docs_tag_radiology.
  ///
  /// In en, this message translates to:
  /// **'Radiology'**
  String get docs_tag_radiology;

  /// No description provided for @docs_tag_prescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get docs_tag_prescription;

  /// No description provided for @docs_tag_report.
  ///
  /// In en, this message translates to:
  /// **'Doctor Report'**
  String get docs_tag_report;

  /// No description provided for @docs_tag_operation.
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get docs_tag_operation;

  /// No description provided for @docs_tag_vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get docs_tag_vaccination;

  /// No description provided for @docs_tag_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get docs_tag_other;

  /// No description provided for @season_pass.
  ///
  /// In en, this message translates to:
  /// **'Season Pass'**
  String get season_pass;

  /// No description provided for @level_label.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level_label(Object level);

  /// No description provided for @premium_reward.
  ///
  /// In en, this message translates to:
  /// **'Premium Reward'**
  String get premium_reward;

  /// No description provided for @free_reward.
  ///
  /// In en, this message translates to:
  /// **'Free Reward'**
  String get free_reward;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get claim;

  /// No description provided for @reward_doc_slots.
  ///
  /// In en, this message translates to:
  /// **'+{value} Docs'**
  String reward_doc_slots(Object value);

  /// No description provided for @premium_unavailable_title.
  ///
  /// In en, this message translates to:
  /// **'Premium is not available in this release.'**
  String get premium_unavailable_title;

  /// No description provided for @premium_unavailable_desc.
  ///
  /// In en, this message translates to:
  /// **'VitaCase currently ships as a free app with local encrypted storage, ads, and optional reminders.'**
  String get premium_unavailable_desc;

  /// No description provided for @btn_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btn_close;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @btn_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btn_save;

  /// No description provided for @doctor_title_dr.
  ///
  /// In en, this message translates to:
  /// **'Dr.'**
  String get doctor_title_dr;

  /// No description provided for @doctor_title_uzm.
  ///
  /// In en, this message translates to:
  /// **'Spec. Dr.'**
  String get doctor_title_uzm;

  /// No description provided for @doctor_title_op.
  ///
  /// In en, this message translates to:
  /// **'Op. Dr.'**
  String get doctor_title_op;

  /// No description provided for @doctor_title_prof.
  ///
  /// In en, this message translates to:
  /// **'Prof. Dr.'**
  String get doctor_title_prof;

  /// No description provided for @doctor_title_doc.
  ///
  /// In en, this message translates to:
  /// **'Assoc. Prof.'**
  String get doctor_title_doc;

  /// No description provided for @hint_doctor_name.
  ///
  /// In en, this message translates to:
  /// **'Dr. John Doe'**
  String get hint_doctor_name;

  /// No description provided for @hint_specialty.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get hint_specialty;

  /// No description provided for @hint_hospital.
  ///
  /// In en, this message translates to:
  /// **'City Hospital'**
  String get hint_hospital;

  /// No description provided for @hint_phone.
  ///
  /// In en, this message translates to:
  /// **'+1 (555) 000-0000'**
  String get hint_phone;

  /// No description provided for @hint_email.
  ///
  /// In en, this message translates to:
  /// **'john.doe@hospital.com'**
  String get hint_email;

  /// No description provided for @hint_address.
  ///
  /// In en, this message translates to:
  /// **'Main St. No:12...'**
  String get hint_address;

  /// No description provided for @hint_personal_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes about the doctor...'**
  String get hint_personal_notes;

  /// No description provided for @ad_reward_not_earned.
  ///
  /// In en, this message translates to:
  /// **'Reward not earned. Please finish the ad to continue.'**
  String get ad_reward_not_earned;

  /// No description provided for @ad_unavailable.
  ///
  /// In en, this message translates to:
  /// **'No rewarded ad is available right now. Please try again later.'**
  String get ad_unavailable;

  /// No description provided for @ad_failed.
  ///
  /// In en, this message translates to:
  /// **'The rewarded ad could not be shown. Please try again.'**
  String get ad_failed;

  /// No description provided for @ad_watch_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue for free (watch ad)'**
  String get ad_watch_btn;

  /// No description provided for @btn_not_now.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get btn_not_now;

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @lock_timeout_1m.
  ///
  /// In en, this message translates to:
  /// **'1 Minute'**
  String get lock_timeout_1m;

  /// No description provided for @lock_timeout_5m.
  ///
  /// In en, this message translates to:
  /// **'5 Minutes'**
  String get lock_timeout_5m;

  /// No description provided for @lock_timeout_15m.
  ///
  /// In en, this message translates to:
  /// **'15 Minutes'**
  String get lock_timeout_15m;

  /// No description provided for @error_title_required.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get error_title_required;

  /// No description provided for @notif_app_created_title.
  ///
  /// In en, this message translates to:
  /// **'🎯 Appointment Created'**
  String get notif_app_created_title;

  /// No description provided for @notif_app_created_body.
  ///
  /// In en, this message translates to:
  /// **'{title} has been scheduled.'**
  String notif_app_created_body(Object title);

  /// No description provided for @notif_app_reminder_title.
  ///
  /// In en, this message translates to:
  /// **'📅 Appointment Reminder'**
  String get notif_app_reminder_title;

  /// No description provided for @notif_app_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'Your appointment for {title} is approaching.'**
  String notif_app_reminder_body(Object title);

  /// No description provided for @no_appointments_found.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get no_appointments_found;

  /// No description provided for @empty_appointments_desc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any appointments yet. Tap the + button to add one.'**
  String get empty_appointments_desc;

  /// No description provided for @empty_appointments_filter_desc.
  ///
  /// In en, this message translates to:
  /// **'No appointments found in this category.'**
  String get empty_appointments_filter_desc;

  /// No description provided for @btn_add_appointment.
  ///
  /// In en, this message translates to:
  /// **'ADD APPOINTMENT'**
  String get btn_add_appointment;

  /// No description provided for @btn_clear_filters.
  ///
  /// In en, this message translates to:
  /// **'CLEAR FILTERS'**
  String get btn_clear_filters;

  /// No description provided for @delete_confirm_appointment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this appointment?'**
  String get delete_confirm_appointment;

  /// No description provided for @create_today_plan.
  ///
  /// In en, this message translates to:
  /// **'Create Today\'s Plan'**
  String get create_today_plan;

  /// No description provided for @plan_time_desc.
  ///
  /// In en, this message translates to:
  /// **'Organize your health schedule with ease.'**
  String get plan_time_desc;

  /// No description provided for @docs_add_short.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get docs_add_short;

  /// No description provided for @docs_open.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get docs_open;

  /// No description provided for @docs_download.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD TO DEVICE'**
  String get docs_download;

  /// No description provided for @docs_delete_perm.
  ///
  /// In en, this message translates to:
  /// **'DELETE PERMANENTLY'**
  String get docs_delete_perm;

  /// No description provided for @docs_date_added.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get docs_date_added;

  /// No description provided for @docs_document_date.
  ///
  /// In en, this message translates to:
  /// **'Document Date'**
  String get docs_document_date;

  /// No description provided for @docs_save_success.
  ///
  /// In en, this message translates to:
  /// **'Document saved successfully!'**
  String get docs_save_success;

  /// No description provided for @docs_download_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download: {error}'**
  String docs_download_failed(Object error);

  /// No description provided for @season_pass_title.
  ///
  /// In en, this message translates to:
  /// **'Season Pass'**
  String get season_pass_title;

  /// No description provided for @season_level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String season_level(Object level);

  /// No description provided for @claim_reward.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get claim_reward;

  /// No description provided for @confirm_agree.
  ///
  /// In en, this message translates to:
  /// **'I Agree'**
  String get confirm_agree;

  /// No description provided for @specialty_department_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Cardiology'**
  String get specialty_department_hint;

  /// No description provided for @hospital_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. City Hospital'**
  String get hospital_hint;

  /// No description provided for @address_hint.
  ///
  /// In en, this message translates to:
  /// **'Street, No, Building...'**
  String get address_hint;

  /// No description provided for @notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Personal notes about the doctor...'**
  String get notes_hint;

  /// No description provided for @standard_modes.
  ///
  /// In en, this message translates to:
  /// **'Standard Modes'**
  String get standard_modes;

  /// No description provided for @premium_palettes.
  ///
  /// In en, this message translates to:
  /// **'Premium Palettes'**
  String get premium_palettes;

  /// No description provided for @apply_theme.
  ///
  /// In en, this message translates to:
  /// **'Apply Theme'**
  String get apply_theme;

  /// No description provided for @theme_luxe_sanctuary.
  ///
  /// In en, this message translates to:
  /// **'Luxe Sanctuary'**
  String get theme_luxe_sanctuary;

  /// No description provided for @theme_midnight_neon.
  ///
  /// In en, this message translates to:
  /// **'Midnight Neon'**
  String get theme_midnight_neon;

  /// No description provided for @theme_amethyst_aura.
  ///
  /// In en, this message translates to:
  /// **'Amethyst Aura'**
  String get theme_amethyst_aura;

  /// No description provided for @theme_emerald_garden.
  ///
  /// In en, this message translates to:
  /// **'Emerald Garden'**
  String get theme_emerald_garden;

  /// No description provided for @theme_ocean_serenity.
  ///
  /// In en, this message translates to:
  /// **'Ocean Serenity'**
  String get theme_ocean_serenity;

  /// No description provided for @theme_amber_glow.
  ///
  /// In en, this message translates to:
  /// **'Amber Glow'**
  String get theme_amber_glow;

  /// No description provided for @db_recovery_title.
  ///
  /// In en, this message translates to:
  /// **'Data Error'**
  String get db_recovery_title;

  /// No description provided for @db_recovery_desc.
  ///
  /// In en, this message translates to:
  /// **'Could not access data. Would you like to try again?'**
  String get db_recovery_desc;

  /// No description provided for @db_recovery_retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get db_recovery_retry;

  /// No description provided for @db_recovery_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get db_recovery_reset;

  /// No description provided for @notif_streak_warning_title.
  ///
  /// In en, this message translates to:
  /// **'Check your daily plan'**
  String get notif_streak_warning_title;

  /// No description provided for @notif_streak_warning_body.
  ///
  /// In en, this message translates to:
  /// **'Open VitaCase to review today\'s reminders and saved items.'**
  String get notif_streak_warning_body;

  /// No description provided for @notif_mission_reminder_title.
  ///
  /// In en, this message translates to:
  /// **'🎯 Daily Missions Pending'**
  String get notif_mission_reminder_title;

  /// No description provided for @notif_mission_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss out on your daily rewards! Complete your tasks now.'**
  String get notif_mission_reminder_body;

  /// No description provided for @notif_limit_reached_title.
  ///
  /// In en, this message translates to:
  /// **'🚀 Limit Reached'**
  String get notif_limit_reached_title;

  /// No description provided for @notif_limit_reached_body.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your free limit. Watch a rewarded ad to continue.'**
  String get notif_limit_reached_body;

  /// No description provided for @notif_good_morning_title.
  ///
  /// In en, this message translates to:
  /// **'🌞 Good Morning!'**
  String get notif_good_morning_title;

  /// No description provided for @notif_good_morning_body.
  ///
  /// In en, this message translates to:
  /// **'Start your day with VitaCase, check your daily tasks.'**
  String get notif_good_morning_body;

  /// No description provided for @notif_test_title.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get notif_test_title;

  /// No description provided for @notif_test_body.
  ///
  /// In en, this message translates to:
  /// **'Your notifications are working perfectly!'**
  String get notif_test_body;

  /// No description provided for @notif_appointment_reminder_title.
  ///
  /// In en, this message translates to:
  /// **'📅 Appointment Reminder'**
  String get notif_appointment_reminder_title;

  /// No description provided for @notif_appointment_reminder_body.
  ///
  /// In en, this message translates to:
  /// **'Your appointment for {doctor} is approaching.'**
  String notif_appointment_reminder_body(Object doctor);

  /// No description provided for @get_directions.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get get_directions;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @no_scheduled_meds_today.
  ///
  /// In en, this message translates to:
  /// **'No medications scheduled for today.'**
  String get no_scheduled_meds_today;

  /// No description provided for @add_appointment.
  ///
  /// In en, this message translates to:
  /// **'Add Appointment'**
  String get add_appointment;

  /// No description provided for @add_document.
  ///
  /// In en, this message translates to:
  /// **'Add Document'**
  String get add_document;

  /// No description provided for @ach_login_1_title.
  ///
  /// In en, this message translates to:
  /// **'The Beginning'**
  String get ach_login_1_title;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
