import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PremiumGuard {
  static bool check(BuildContext context, WidgetRef ref) {
    // Paywall disconnected for now
    return true;
  }
}

