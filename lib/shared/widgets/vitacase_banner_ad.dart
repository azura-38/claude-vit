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
  bool _loadFailed = false;

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
          debugPrint('[VitaCaseBannerAd] loaded');
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _loadFailed = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          debugPrint('[VitaCaseBannerAd] failed: ${error.code} ${error.message}');
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _loadFailed = true;
          });
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(adVisibilityPolicyProvider);
    if (!policy.canShowBanner) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: AdSize.banner.height.toDouble(),
      child: Center(
        child: _isLoaded && _bannerAd != null
            ? SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            : Container(
                width: AdSize.banner.width.toDouble(),
                height: AdSize.banner.height.toDouble(),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.025),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: kDebugMode && _loadFailed
                    ? const Text(
                        'Banner yüklenemedi',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      )
                    : const SizedBox.shrink(),
              ),
      ),
    );
  }
}
