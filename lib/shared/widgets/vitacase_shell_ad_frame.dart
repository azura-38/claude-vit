import 'package:flutter/material.dart';

import 'vitacase_banner_ad.dart';

class VitaCaseShellAdFrame extends StatelessWidget {
  const VitaCaseShellAdFrame({super.key, required this.child, required this.showBanner});

  final Widget child;
  final bool showBanner;

  @override
  Widget build(BuildContext context) {
    if (!showBanner) return child;

    final topInset = MediaQuery.paddingOf(context).top;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: topInset, left: 12, right: 12, bottom: 8),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: const VitaCaseBannerAd(),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
