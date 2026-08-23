import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/shared/data/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdService Preload & Performance Tests', () {
    test('AdService singleton initial state', () {
      final service = AdService();
      expect(service.bannerStatus, equals(AdLoadStatus.idle));
      expect(service.rewardedStatus, equals(AdLoadStatus.idle));
      expect(service.appOpenStatus, equals(AdLoadStatus.idle));
      expect(service.bannerLoadTimeMs, isNull);
    });

    test('claimPreloadedBanner returns null when no banner preloaded', () {
      final service = AdService();
      final claimed = service.claimPreloadedBanner();
      expect(claimed, isNull);
    });

    test('AdLoadStatus enum values are valid', () {
      expect(AdLoadStatus.values.length, equals(4));
      expect(AdLoadStatus.idle.name, equals('idle'));
      expect(AdLoadStatus.loading.name, equals('loading'));
      expect(AdLoadStatus.loaded.name, equals('loaded'));
      expect(AdLoadStatus.failed.name, equals('failed'));
    });
  });
}
