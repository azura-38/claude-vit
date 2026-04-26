import 'dart:async';
import 'package:flutter/foundation.dart';
import 'ad_service.dart';

class RewardService {
  /// Simple but powerful wrapper around the existing AdService
  static Future<bool> watchAd() async {
    if (kDebugMode) debugPrint('[RewardService] Attempting to show rewarded ad...');
    
    // Check if ad is ready, or try to load and show
    return AdService.showRewardedAd();
  }
}
