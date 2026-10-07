import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/ads/ad_visibility_policy.dart';
import 'package:vitacase/core/bootstrap/app_bootstrap_controller.dart';
import 'package:vitacase/core/bootstrap/bootstrap_screen.dart';
import 'package:vitacase/core/config/app_config.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/shared/data/datasources/database_codec.dart';
import 'package:vitacase/shared/data/datasources/sembast_database.dart';
import 'package:vitacase/shared/data/services/ad_service.dart';
import 'package:vitacase/shared/data/services/backup_service.dart';
import 'package:vitacase/shared/data/services/consent_service.dart';
import 'package:vitacase/shared/data/services/encryption_service.dart';
import 'package:vitacase/shared/data/services/wipe_service.dart';
import 'package:vitacase/shared/widgets/vitacase_banner_ad.dart';

class MockFailingBootstrapController extends AppBootstrapController {
  @override
  Future<void> build() async {
    throw DatabaseRecoveryRequiredException(Exception('Simulated keystore locked'));
  }
}

class MockFailingKeyStorage implements SecureKeyStorage {
  @override
  Future<String?> read(String key) async => throw Exception('Secure storage locked / keystore failure');
  @override
  Future<void> write(String key, String value) async => throw Exception('Secure storage locked / keystore failure');
  @override
  Future<void> delete(String key) async {}
}

class InMemoryKeyStorage implements SecureKeyStorage {
  final Map<String, String> _data = {};
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<void> delete(String key) async => _data.remove(key);
}

class FakeInterstitialAdHandle implements InterstitialAdHandle {
  bool isDisposed = false;
  bool isShown = false;
  @override
  void dispose() {
    isDisposed = true;
  }
  @override
  Future<void> show({
    required void Function() onAdShowed,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  }) async {
    isShown = true;
    onAdShowed();
    onAdDismissed();
  }
}

class FakeInterstitialAdDelegate implements InterstitialAdDelegate {
  int loadCalls = 0;
  @override
  Future<InterstitialAdHandle?> loadInterstitial(String adUnitId) async {
    loadCalls++;
    return FakeInterstitialAdHandle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  final Map<String, String> secureStorageMockData = {};

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('vitacase_safety_test_');
    SharedPreferences.setMockInitialValues({});
    secureStorageMockData.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return tempDir.path;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        final args = methodCall.arguments is Map ? methodCall.arguments as Map : {};
        final key = args['key'] as String?;
        if (methodCall.method == 'read') {
          return secureStorageMockData[key];
        } else if (methodCall.method == 'write') {
          secureStorageMockData[key!] = args['value'] as String;
          return null;
        } else if (methodCall.method == 'delete') {
          secureStorageMockData.remove(key);
          return null;
        } else if (methodCall.method == 'deleteAll') {
          secureStorageMockData.clear();
          return null;
        } else if (methodCall.method == 'containsKey') {
          return secureStorageMockData.containsKey(key);
        }
        return null;
      },
    );
    AdService.resetForTesting();
  });

  tearDown(() async {
    AdService.resetForTesting();
    try {
      await SembastDatabase().close();
    } catch (_) {}
    SembastDatabase().reset();
    EncryptionService.clearCache();
    if (await tempDir.exists()) {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('Pre-Release Safety — Stage 1: Database Recovery & Data Preservation', () {
    test('1. SembastDatabase throws DatabaseRecoveryRequiredException on failure and preserves existing files', () async {
      final dbFile = File(p.join(tempDir.path, 'vitacase.db'));
      await dbFile.writeAsString('existing_user_encrypted_data_cannot_be_deleted');

      final docsSubDir = Directory(p.join(tempDir.path, 'documents'));
      await docsSubDir.create();
      final userDoc = File(p.join(docsSubDir.path, 'prescription.pdf'));
      await userDoc.writeAsString('user_pdf_content');

      final failingEncService = EncryptionService(storage: MockFailingKeyStorage());
      final db = SembastDatabase();

      await expectLater(
        db.init(failingEncService),
        throwsA(isA<DatabaseRecoveryRequiredException>()),
      );

      // Verify that user files were NOT deleted by any destructive self-healing block
      expect(await dbFile.exists(), isTrue, reason: 'Database file must never be deleted on init error');
      expect(await userDoc.exists(), isTrue, reason: 'User documents must never be deleted on init error');
    });

    test('2. SembastDatabase reset allows clean re-initialization after closing/wiping', () async {
      final db = SembastDatabase();
      db.reset();
      expect(db.ready, isNotNull);
    });

    test('3. Database codec throws FormatException on invalid ciphertext instead of returning silent nulls', () {
      final key = enc.Key.fromSecureRandom(32);
      final codec = DatabaseEncryptionCodec(key);

      expect(
        () => codec.codec.decoder.convert('invalid_corrupted_base64_data_!!!'),
        throwsA(isA<FormatException>()),
      );
    });

    test('4. In-session DB re-initialization and write/read works cleanly after full wipe', () async {
      final encStorage = InMemoryKeyStorage();
      final encService = EncryptionService(storage: encStorage);
      final dbInstance = SembastDatabase();

      // Step A: Initialize and write a record
      await dbInstance.init(encService);
      final db = await dbInstance.ready;
      final store = StoreRef<String, Map<String, dynamic>>.main();
      await store.record('med_1').put(db, {'name': 'Aspirin', 'dose': '100mg'});

      final recordBefore = await store.record('med_1').get(db);
      expect(recordBefore?['name'], equals('Aspirin'));

      // Step B: Wipe the app
      await WipeService.fullWipe();

      // Verify DB file was deleted by wipe
      final dbFile = File(p.join(tempDir.path, 'vitacase.db'));
      expect(await dbFile.exists(), isFalse);

      // Step C: Re-initialize database in the SAME test session
      await dbInstance.init(encService);
      final reopenedDb = await dbInstance.ready;
      expect(reopenedDb, isNotNull);

      // Write and read a new record
      await store.record('med_new').put(reopenedDb, {'name': 'Paracetamol', 'dose': '500mg'});
      final newRecord = await store.record('med_new').get(reopenedDb);
      expect(newRecord?['name'], equals('Paracetamol'));
    });

    test('5. WipeService cleans up recovery backups (.bak, .old, .tmp, .zip) during full wipe', () async {
      final encStorage = InMemoryKeyStorage();
      final encService = EncryptionService(storage: encStorage);
      final dbInstance = SembastDatabase();
      await dbInstance.init(encService);

      // Create dummy recovery backup artifacts in documents directory
      final bakFile = File(p.join(tempDir.path, 'vitacase.db.bak'));
      await bakFile.writeAsString('backup_db_content');

      final oldFile = File(p.join(tempDir.path, 'archive.old'));
      await oldFile.writeAsString('old_archive_content');

      final tmpFile = File(p.join(tempDir.path, 'pending.tmp'));
      await tmpFile.writeAsString('tmp_content');

      final zipFile = File(p.join(tempDir.path, BackupService.backupFileName));
      await zipFile.writeAsString('zip_content');

      await WipeService.fullWipe();

      expect(await bakFile.exists(), isFalse, reason: '.bak must be purged on full wipe');
      expect(await oldFile.exists(), isFalse, reason: '.old must be purged on full wipe');
      expect(await tmpFile.exists(), isFalse, reason: '.tmp must be purged on full wipe');
      expect(await zipFile.exists(), isFalse, reason: 'Backup zip must be purged on full wipe');
    });

    testWidgets('5b. Bootstrap error screen for DatabaseRecoveryRequiredException instructs user not to clear data/uninstall and does not promise data is definitely intact', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartupErrorScreen(
            error: DatabaseRecoveryRequiredException(Exception('Simulated keystore locked')),
            onRetry: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Veritabanı Başlatılamadı'), findsOneWidget);
      expect(find.textContaining('uygulama verilerini temizlemeyin'), findsOneWidget);
      expect(find.textContaining('uygulamayı cihazınızdan kaldırmayın'), findsOneWidget);
      expect(find.textContaining('kesinlikle sağlam'), findsNothing);
      expect(find.textContaining('Your data is safe'), findsNothing);
    });
  });

  group('Pre-Release Safety — Stage 2: Backup & Restore Validation & Rollback', () {
    test('6. Backup import rejects archive with missing manifest and preserves existing data', () async {
      final dbFile = File(p.join(tempDir.path, 'vitacase.db'));
      await dbFile.writeAsString('original_valid_db_bytes');

      final emptyArchiveZip = File(p.join(tempDir.path, 'invalid_no_manifest.zip'));
      final encoder = ZipEncoder();
      final archive = Archive();
      archive.addFile(ArchiveFile('dummy.txt', 5, utf8.encode('hello')));
      final zipBytes = encoder.encode(archive)!;
      await emptyArchiveZip.writeAsBytes(zipBytes);

      final backupService = BackupService();
      expect(
        () => backupService.importBackup(emptyArchiveZip.path),
        throwsA(anything),
      );

      // Verify original DB remains untouched
      expect(await dbFile.readAsString(), equals('original_valid_db_bytes'));
    });

    test('7. Backup import rejects mismatched device UID in same_device_only scope and preserves existing data', () async {
      final dbFile = File(p.join(tempDir.path, 'vitacase.db'));
      await dbFile.writeAsString('original_valid_db_bytes');

      final crossDeviceZip = File(p.join(tempDir.path, 'cross_device.zip'));
      final encoder = ZipEncoder();
      final archive = Archive();

      final manifestJson = jsonEncode({
        'version': 1,
        'scope': 'same_device_only',
        'device_uid': 'device_A_hardware_keystore',
        'includes': ['vitacase.db'],
      });
      archive.addFile(ArchiveFile('vitacase_manifest.json', manifestJson.length, utf8.encode(manifestJson)));
      archive.addFile(ArchiveFile('vitacase.db', 10, utf8.encode('dummy_db_data')));

      final zipBytes = encoder.encode(archive)!;
      await crossDeviceZip.writeAsBytes(zipBytes);

      final backupService = BackupService();
      expect(
        () => backupService.importBackup(crossDeviceZip.path),
        throwsA(anything),
      );

      // Verify original DB remains untouched
      expect(await dbFile.readAsString(), equals('original_valid_db_bytes'));
    });

    test('8. Backup restore failure preserves original database and documents, and original DB remains openable', () async {
      final encStorage = InMemoryKeyStorage();
      final encService = EncryptionService(storage: encStorage);
      final dbInstance = SembastDatabase();

      // Initialize real Sembast DB and write a prescription record
      await dbInstance.init(encService);
      final originalDb = await dbInstance.ready;
      final store = StoreRef<String, Map<String, dynamic>>.main();
      await store.record('card_1').put(originalDb, {'title': 'Allergy Card', 'severity': 'high'});

      final docsDir = Directory(p.join(tempDir.path, 'documents'));
      await docsDir.create();
      final docFile = File(p.join(docsDir.path, 'important_doc.pdf'));
      await docFile.writeAsString('important_pdf_binary');

      // Attempt to import a totally corrupt zip file
      final corruptZip = File(p.join(tempDir.path, 'corrupted_backup.zip'));
      await corruptZip.writeAsString('NOT_A_VALID_ZIP_ARCHIVE_DATA');

      final backupService = BackupService();
      await expectLater(
        backupService.importBackup(corruptZip.path),
        throwsA(anything),
      );

      // Verify original document was preserved
      expect(await docFile.exists(), isTrue);
      expect(await docFile.readAsString(), equals('important_pdf_binary'));

      // Verify original database is still valid and can be opened
      dbInstance.reset();
      await dbInstance.init(encService);
      final reopenedDb = await dbInstance.ready;
      final record = await store.record('card_1').get(reopenedDb);
      expect(record?['title'], equals('Allergy Card'));
    });

    test('8b. Backup import closes database before restore and resets SembastDatabase ready completer', () async {
      final encStorage = InMemoryKeyStorage();
      final encService = EncryptionService(storage: encStorage);
      final dbInstance = SembastDatabase();
      await dbInstance.init(encService);
      final db = await dbInstance.ready;
      final store = StoreRef<String, Map<String, dynamic>>.main();
      await store.record('key1').put(db, {'value': 42});
      await dbInstance.close();

      // Export a valid backup
      final backupService = BackupService();
      final backupPath = await backupService.exportBackup();

      // Now import it back
      await backupService.importBackup(backupPath);

      // Verify that after import, SembastDatabase can be initialized cleanly and record is present
      await dbInstance.init(encService);
      final reopenedDb = await dbInstance.ready;
      final readBack = await store.record('key1').get(reopenedDb);
      expect(readBack?['value'], equals(42));
    });
  });

  group('Pre-Release Safety — Stage 3: Ad Permission Gating & SDK Sequencing', () {
    test('9. AdService suppresses ad requests when ConsentService.canRequestAds() is false', () async {
      ConsentService.canRequestAdsOverrideForTesting = false;
      final fakeDelegate = FakeInterstitialAdDelegate();
      AdService.setInterstitialDelegateForTesting(fakeDelegate);

      final service = AdService();
      final handle = await service.loadInterstitial();

      expect(handle, isNull, reason: 'Ad request must be suppressed when consent is not granted');
      expect(fakeDelegate.loadCalls, equals(0), reason: 'Delegate should not receive load request');
    });

    test('10. AdService allows ad requests when ConsentService.canRequestAds() is true', () async {
      ConsentService.canRequestAdsOverrideForTesting = true;
      final fakeDelegate = FakeInterstitialAdDelegate();
      AdService.setInterstitialDelegateForTesting(fakeDelegate);

      final service = AdService();
      final handle = await service.loadInterstitial();

      expect(handle, isNotNull, reason: 'Ad request is permitted when consent is granted');
      expect(fakeDelegate.loadCalls, equals(1));
    });

    test('11. Default delegates check UMP consent and fail closed in test environments without native SDK', () async {
      // With default delegate (no mock injected) and no testing override,
      // ConsentService.canRequestAds() safely catches missing native platform and returns false.
      AdService.resetForTesting();
      final canRequest = await ConsentService.canRequestAds();
      expect(canRequest, isFalse, reason: 'Must fail closed when UMP is not initialized or platform is unconfigured');
    });

    testWidgets('11b. VitaCaseBannerAd suppresses ad request when ConsentService.canRequestAds() is false', (tester) async {
      ConsentService.canRequestAdsOverrideForTesting = false;

      bool? loadedState;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adVisibilityPolicyProvider.overrideWithValue(
              const AdVisibilityPolicy(
                bootstrapCompleted: true,
                isPremium: false,
                onboardingCompleted: true,
                profileCreated: true,
                lockEnabled: false,
                lockState: AppLockState.unlocked,
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VitaCaseBannerAd(
                onLoadedStateChanged: (loaded) => loadedState = loaded,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(loadedState, isFalse, reason: 'Banner loaded state must be false when UMP consent is not granted');
      expect(find.byType(AdWidget), findsNothing, reason: 'AdWidget must never be created without UMP consent');
    });

    testWidgets('11c. VitaCaseBannerAd suppresses ad request when adVisibilityPolicy.canShowBanner is false', (tester) async {
      ConsentService.canRequestAdsOverrideForTesting = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adVisibilityPolicyProvider.overrideWithValue(
              const AdVisibilityPolicy(
                bootstrapCompleted: true,
                isPremium: true, // Premium disables banners
                onboardingCompleted: true,
                profileCreated: true,
                lockEnabled: false,
                lockState: AppLockState.unlocked,
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: VitaCaseBannerAd(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AdWidget), findsNothing, reason: 'AdWidget must not be created when banner visibility is blocked by policy');
    });
  });

  group('Pre-Release Safety — Stage 4: AdMob Configuration Verification', () {
    test('12. Production AdMob IDs officially verified and collision-free', () {
      // 1. prodInterstitialAdId is not empty
      expect(AppConfig.prodInterstitialAdId, isNotEmpty);

      // 2. prodInterstitialAdId == ca-app-pub-5877011177866406/9281662404
      expect(
        AppConfig.prodInterstitialAdId,
        equals('ca-app-pub-5877011177866406/9281662404'),
        reason: 'Officially verified from latest Google AdMob placement document',
      );

      // 3. prodRewardedInterstitialAdId == ca-app-pub-5877011177866406/4940803235
      expect(
        AppConfig.prodRewardedInterstitialAdId,
        equals('ca-app-pub-5877011177866406/4940803235'),
        reason: 'Officially verified Rewarded Interstitial ID from AdMob document',
      );

      // 4. prodInterstitialAdId != prodRewardedInterstitialAdId
      expect(
        AppConfig.prodInterstitialAdId,
        isNot(equals(AppConfig.prodRewardedInterstitialAdId)),
        reason: 'Interstitial and Rewarded Interstitial must not share unit IDs',
      );

      // 5. prodBannerAdId == ca-app-pub-5877011177866406/8010224598
      expect(
        AppConfig.prodBannerAdId,
        equals('ca-app-pub-5877011177866406/8010224598'),
        reason: 'Officially verified Banner ID from latest Google AdMob document',
      );

      // 6. prodRewardedAdId == ca-app-pub-5877011177866406/8638855182
      expect(
        AppConfig.prodRewardedAdId,
        equals('ca-app-pub-5877011177866406/8638855182'),
        reason: 'Officially verified Rewarded ID from AdMob document',
      );

      // 7. prodAppOpenAdId == ca-app-pub-5877011177866406/3230238539
      expect(
        AppConfig.prodAppOpenAdId,
        equals('ca-app-pub-5877011177866406/3230238539'),
        reason: 'Officially verified App Open ID from AdMob document',
      );

      // Verification flag is true because both IDs are distinct and verified
      expect(AppConfig.isProductionInterstitialVerified, isTrue);
    });
  });

  group('Pre-Release Safety — Stage 5: Terms & Privacy Accuracy with Codebase', () {
    test('13. terms_and_privacy.md does not claim PBKDF2 and uses data-at-rest encryption', () async {
      final legalDoc = await rootBundle.loadString('assets/legal/terms_and_privacy.md');
      expect(legalDoc, isNot(contains('derived via PBKDF2')), reason: 'Master key is random bytes, not PBKDF2');
      expect(legalDoc, isNot(contains('uçtan uca yerel şifreleme')), reason: 'Must not claim end-to-end encryption');
      expect(legalDoc, contains('AES-256-GCM'));
      expect(legalDoc, contains('limanexsoftware@outlook.com'));
    });
  });
}
