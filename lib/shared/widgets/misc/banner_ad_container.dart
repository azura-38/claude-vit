import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/config/app_config.dart';
import '../../../core/ads/ad_visibility_policy.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (!policy.canShowBanner || kIsWeb || _hasFailed) {
      return const SizedBox.shrink();
    }

    if (_bannerAd == null || !_isLoaded) {
      // Reserve no space until loaded; prevents layout flashes and avoids
      // blocking the app if AdMob does not return a banner.
      return const SizedBox.shrink();
    }

    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          width: double.infinity,
          height: _bannerAd!.size.height.toDouble(),
          child: Center(child: AdWidget(ad: _bannerAd!)),
        ),
      ),
    );
  }
}
