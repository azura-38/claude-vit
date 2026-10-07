import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/config/app_config.dart';
import '../../../core/ads/ad_visibility_policy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/consent_service.dart';

class BannerAdContainer extends ConsumerStatefulWidget {
  const BannerAdContainer({super.key});

  @override
  ConsumerState<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends ConsumerState<BannerAdContainer> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasFailed = false;
  double? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (kIsWeb || _hasFailed || !AppConfig.hasAdConfig || AppConfig.bannerAdId.isEmpty) {
      return;
    }

    final width = MediaQuery.of(context).size.width;
    if (_lastWidth != width) {
      _lastWidth = width;
      _initAd();
    }
  }

  Future<void> _initAd() async {
    try {
      if (!await ConsentService.canRequestAds()) {
        if (!mounted) return;
        setState(() {
          _bannerAd = null;
          _isLoaded = false;
          _hasFailed = true;
        });
        return;
      }

      final mediaQuery = MediaQuery.of(context);
      final adWidth = mediaQuery.size.width.truncate();
      final orientation = mediaQuery.orientation;

      await _bannerAd?.dispose();
      if (!mounted) return;

      setState(() {
        _bannerAd = null;
        _isLoaded = false;
        _hasFailed = false;
      });

      final adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
        orientation,
        adWidth,
      );

      if (!mounted || adSize == null) return;

      final banner = BannerAd(
        adUnitId: AppConfig.bannerAdId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) return;
            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoaded = true;
              _hasFailed = false;
            });
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('[BannerAd] failed: $error');
            ad.dispose();
            if (!mounted) return;
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
              _hasFailed = true;
            });
          },
        ),
      );

      _bannerAd = banner;
      await banner.load();
    } catch (e, st) {
      debugPrint('[BannerAd] init error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() {
        _bannerAd = null;
        _isLoaded = false;
        _hasFailed = true;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(adVisibilityPolicyProvider);
    if (!policy.canShowBanner || kIsWeb) {
      return const SizedBox.shrink();
    }

    final adHeight = _bannerAd?.size.height.toDouble() ?? 60.0;

    if (_bannerAd == null || !_isLoaded || _hasFailed) {
      // Yeşil alan (Green placeholder area) to show that a banner ad is located here
      // fixed height prevents layout shifts, visible on every page.
      return Material(
        color: const Color(0xFF22C55E), // Slate-green / Tailwind Green 500
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            height: adHeight,
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ads_click, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Advertisement Space',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          height: adHeight,
          child: Center(child: AdWidget(ad: _bannerAd!)),
        ),
      ),
    );
  }
}
