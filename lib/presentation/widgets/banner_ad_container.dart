import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/config/app_config.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/premium_provider.dart';

class BannerAdContainer extends ConsumerStatefulWidget {
  const BannerAdContainer({super.key});

  @override
  ConsumerState<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends ConsumerState<BannerAdContainer> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  double? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    
    // Only re-init if width has changed (e.g., orientation change)
    if (_lastWidth != width) {
      _lastWidth = width;
      _initAd(context);
    }
  }

  Future<void> _initAd(BuildContext context) async {
    if (!AppConfig.hasAdConfig || AppConfig.bannerAdId.isEmpty) {
      return;
    }

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // Dispose previous ad if it exists
    await _bannerAd?.dispose();
    if (!mounted) return;
    
    setState(() {
      _bannerAd = null;
      _isLoaded = false;
    });

    final adWidth = size.width.truncate();
    
    final adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
      orientation,
      adWidth,
    );

    if (adSize == null) return;

    _bannerAd = BannerAd(
      adUnitId: AppConfig.bannerAdId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider);
    if (isPremium) return const SizedBox.shrink();

    if (_bannerAd == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      color: Colors.transparent,
      child: SafeArea(
        bottom: false, // Scaffold handles bottom safe area if needed
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
