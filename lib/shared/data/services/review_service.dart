import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../core/utils/external_launcher.dart';

abstract class ReviewPlatformDelegate {
  Future<bool> isAvailable();
  Future<void> requestReview();
  Future<void> openStoreListing({String? appStoreId});
}

class DefaultReviewPlatformDelegate implements ReviewPlatformDelegate {
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _inAppReview.isAvailable();
    } catch (e) {
      debugPrint('[ReviewService] isAvailable error: $e');
      return false;
    }
  }

  @override
  Future<void> requestReview() async {
    await _inAppReview.requestReview();
  }

  @override
  Future<void> openStoreListing({String? appStoreId}) async {
    await _inAppReview.openStoreListing(appStoreId: appStoreId);
  }
}

class ReviewService {
  ReviewService({ReviewPlatformDelegate? delegate})
      : _delegate = delegate ?? DefaultReviewPlatformDelegate();

  static final ReviewService instance = ReviewService();

  ReviewPlatformDelegate _delegate;
  DateTime? _lastReviewRequestTime;
  bool _isRequesting = false;

  static const String playStoreUrl = ExternalLauncher.playStoreUrl;

  @visibleForTesting
  void setDelegateForTesting(ReviewPlatformDelegate delegate) {
    _delegate = delegate;
  }

  @visibleForTesting
  void resetForTesting() {
    _delegate = DefaultReviewPlatformDelegate();
    _lastReviewRequestTime = null;
    _isRequesting = false;
  }

  /// Triggers the Google Play In-App Review flow:
  /// 1. Prevents concurrent requests and rapid-fire spam within the same session
  /// 2. Queries Google Play In-App Review API availability
  /// 3. If available, initiates `requestReview()`
  /// 4. If unavailable or if API fails, gracefully falls back to Google Play Store listing
  /// 5. Never throws unhandled exceptions or crashes user flow
  Future<bool> requestReviewOrOpenStore({bool forceStoreFallback = false}) async {
    if (_isRequesting) {
      debugPrint('[ReviewService] Review request already in progress.');
      return false;
    }

    // Anti-spam debounce (3 seconds between manual taps)
    if (_lastReviewRequestTime != null &&
        DateTime.now().difference(_lastReviewRequestTime!).inSeconds < 3) {
      debugPrint('[ReviewService] Suppressing rapid repeat review trigger.');
      return false;
    }

    _isRequesting = true;
    _lastReviewRequestTime = DateTime.now();

    try {
      if (!forceStoreFallback) {
        final isAvailable = await _delegate.isAvailable();
        if (isAvailable) {
          await _delegate.requestReview();
          return true;
        }
      }

      // If In-App Review not available or force fallback requested
      return await _openStoreFallback();
    } catch (e) {
      debugPrint('[ReviewService] In-App Review request failed, attempting fallback: $e');
      return await _openStoreFallback();
    } finally {
      _isRequesting = false;
    }
  }

  Future<bool> _openStoreFallback() async {
    try {
      await _delegate.openStoreListing();
      return true;
    } catch (e) {
      debugPrint('[ReviewService] openStoreListing failed, attempting ExternalLauncher: $e');
      try {
        return await ExternalLauncher.openPlayStore();
      } catch (err) {
        debugPrint('[ReviewService] ExternalLauncher fallback failed: $err');
        return false;
      }
    }
  }
}

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService.instance;
});
