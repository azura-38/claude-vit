import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/navigation/app_bottom_nav.dart';
import '../../../shared/widgets/navigation/explore_menu.dart';
import '../../../shared/widgets/misc/banner_ad_container.dart';
import '../../../shared/providers/navigation_provider.dart';
import '../../../shared/providers/behavior_notifier.dart';


class HomeScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const HomeScreen({
    super.key,
    required this.navigationShell,
  });

  static void showExploreMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ExploreMenu(
          onClose: () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🧠 Initialize behavioral intelligence
    ref.read(behaviorProvider);

    final currentIndex = navigationShell.currentIndex;

    ref.listen<int>(navigationProvider, (previous, next) {
      if (next != navigationShell.currentIndex && next != 2) {
        navigationShell.goBranch(next, initialLocation: next == navigationShell.currentIndex);
      }
    });

    void onTabTapped(int index) {
      if (index != 2) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      }
    }

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          const BannerAdContainer(),
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        onExploreTap: () => showExploreMenu(context),
      ),
    );
  }
}
