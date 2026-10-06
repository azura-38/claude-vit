import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class UiUtils {
  /// Global navigator key access
  static GlobalKey<NavigatorState> get navigatorKey => AppRouter.navigatorKey;

  /// Standardized Floating Snackbar designed for VitaCase
  static void showCustomSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          bottom: 100, // Stay above bottom nav & FAB
          left: 16,
          right: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Safe pop that prevents crashes if the navigator can't pop
  /// Uses rootNavigator to escape bottom sheets if needed
  static void safePop([dynamic result]) {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(result);
      } else if (context.canPop()) {
        context.pop(result);
      }
    }
  }
}

/// Extension providing lifecycle-guarded safe navigation and pop methods
extension SafeNavigationContext on BuildContext {
  /// Safely pops the nearest navigator, dialog, or bottom sheet if and only if
  /// the context is mounted and an active route exists to pop.
  /// If the navigator cannot pop and [fallbackRoute] is provided, navigates to [fallbackRoute].
  /// Returns true if a navigation/pop action occurred, false otherwise without throwing.
  bool safePop<T extends Object?>({T? result, String? fallbackRoute}) {
    if (!mounted) return false;
    final nav = Navigator.maybeOf(this);
    if (nav != null && nav.canPop()) {
      nav.pop(result);
      return true;
    }
    final router = GoRouter.maybeOf(this);
    if (router != null && router.canPop()) {
      router.pop(result);
      return true;
    } else if (router != null && fallbackRoute != null) {
      router.go(fallbackRoute);
      return true;
    }
    return false;
  }
}

