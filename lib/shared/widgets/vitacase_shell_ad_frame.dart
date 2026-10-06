import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_visibility_policy.dart';
import 'vitacase_banner_ad.dart';

class VitaCaseShellAdFrame extends ConsumerStatefulWidget {
  const VitaCaseShellAdFrame({
    super.key,
    required this.child,
    required this.showBanner,
  });

  final Widget child;
  final bool showBanner;

  @override
  ConsumerState<VitaCaseShellAdFrame> createState() => _VitaCaseShellAdFrameState();
}

class _VitaCaseShellAdFrameState extends ConsumerState<VitaCaseShellAdFrame> {
  bool _isBannerLoaded = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.showBanner) return widget.child;

    final policy = ref.watch(adVisibilityPolicyProvider);
    if (!policy.canShowBanner) {
      return widget.child;
    }

    final topInset = MediaQuery.paddingOf(context).top;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: _isBannerLoaded
              ? EdgeInsets.only(top: topInset, left: 12, right: 12, bottom: 8)
              : EdgeInsets.zero,
          color: _isBannerLoaded ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
          child: VitaCaseBannerAd(
            onLoadedStateChanged: (loaded) {
              if (mounted && _isBannerLoaded != loaded) {
                setState(() => _isBannerLoaded = loaded);
              }
            },
          ),
        ),
        Expanded(
          child: _isBannerLoaded
              ? MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: widget.child,
                )
              : widget.child,
        ),
      ],
    );
  }
}
