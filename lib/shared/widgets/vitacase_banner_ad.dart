import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:vitacase/core/extensions/l10n_extension.dart';

import '../../core/ads/ad_visibility_policy.dart';
import '../../core/config/app_config.dart';
import '../data/services/ad_service.dart';

class VitaCaseBannerAd extends ConsumerStatefulWidget {
  const VitaCaseBannerAd({
    super.key,
    this.ignoreVisibilityPolicy = false,
    this.showPlaceholderWhenLoading = false,
    this.showFailureMessage = false,
  });

  /// Used by the debug panel so the banner test can run even if the normal
  /// app-level ad policy would hide banners on that screen.
  final bool ignoreVisibilityPolicy;

  /// Normal production screens should not show an empty ad slot if AdMob does
  /// not return fill. The debug panel can enable this to make test state clear.
  final bool showPlaceholderWhenLoading;

  final bool showFailureMessage;

  @override
  ConsumerState<VitaCaseBannerAd> createState() => _VitaCaseBannerAdState();
}

class _VitaCaseBannerAdState extends ConsumerState<VitaCaseBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _loadFailed = false;
  String? _lastError;

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
    if (kIsWeb || !AppConfig.hasAdConfig || AppConfig.bannerAdId.isEmpty) {
      _loadFailed = true;
      _lastError = kIsWeb ? 'Web desteklenmiyor' : 'AdMob banner config eksik';
      return;
    }
    if (_bannerAd != null) return;

    // Check preloaded banner cache from AdService
    final preloaded = AdService().claimPreloadedBanner();
    if (preloaded != null) {
      setState(() {
        _bannerAd = preloaded;
        _isLoaded = true;
        _loadFailed = false;
        _lastError = null;
      });
      return;
    }

    final stopwatch = Stopwatch()..start();
    final ad = BannerAd(
      adUnitId: AppConfig.bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          stopwatch.stop();
          if (!mounted) return;
          if (kDebugMode) {
            debugPrint('[VitaCaseBannerAd] loaded in ${stopwatch.elapsedMilliseconds}ms');
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _loadFailed = false;
            _lastError = null;
          });
        },
        onAdFailedToLoad: (ad, error) {
          stopwatch.stop();
          ad.dispose();
          if (!mounted) return;
          if (kDebugMode) {
            debugPrint('[VitaCaseBannerAd] failed after ${stopwatch.elapsedMilliseconds}ms: ${error.code} ${error.message}');
          }
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _loadFailed = true;
            _lastError = '${error.code}: ${error.message}';
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
    if (!widget.ignoreVisibilityPolicy && !policy.canShowBanner) {
      return const SizedBox.shrink();
    }

    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        child: Center(
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    }

    if (!widget.showPlaceholderWhenLoading) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = _loadFailed
        ? (widget.showFailureMessage ? '${context.l10n.bannerLoadFailed}${_lastError == null ? '' : ' • $_lastError'}' : context.l10n.bannerLoadFailed)
        : context.l10n.bannerLoading;

    return SizedBox(
      width: double.infinity,
      height: AdSize.banner.height.toDouble(),
      child: Center(
        child: Container(
          width: AdSize.banner.width.toDouble(),
          height: AdSize.banner.height.toDouble(),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
