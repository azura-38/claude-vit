import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/ads/ad_visibility_policy.dart';
import '../../core/config/app_config.dart';

class VitaCaseBannerAd extends ConsumerStatefulWidget {
  const VitaCaseBannerAd({super.key});

  @override
  ConsumerState<VitaCaseBannerAd> createState() => _VitaCaseBannerAdState();
}

class _VitaCaseBannerAdState extends ConsumerState<VitaCaseBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBannerIfNeeded();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerIfNeeded() {
    if (kIsWeb || !AppConfig.hasAdConfig || AppConfig.bannerAdId.isEmpty) return;
    if (_bannerAd != null) return;

    final ad = BannerAd(
      adUnitId: AppConfig.bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
          debugPrint('[VitaCaseBannerAd] failed: ${error.code} ${error.message}');
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(adVisibilityPolicyProvider);
    if (!policy.canShowBanner || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
