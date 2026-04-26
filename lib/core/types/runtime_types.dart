enum AppBootstrapState {
  ready,
  degraded,
}

enum AppLockState {
  unknown,
  locked,
  unlocked,
}

enum NotificationPermissionState {
  unknown,
  granted,
  denied,
  unsupported,
}

enum RewardAdResult {
  shownRewarded,
  shownNoReward,
  unavailable,
  failed,
}

enum PremiumAvailability {
  disabled,
  enabled,
}
