import 'package:haptic_feedback/haptic_feedback.dart';

class HapticService {
  /// Subtle confirmation, like changing a tab or scrolling to a limit.
  static Future<void> light() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.light);
    }
  }

  /// Confident tactile click, like pressing a primary button.
  static Future<void> medium() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.medium);
    }
  }

  /// Heavy feedback for errors, destructive actions, or warnings.
  static Future<void> heavy() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.heavy);
    }
  }

  /// Joyful and rewarding feedback for saving, uploading, or marking complete.
  static Future<void> success() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.success);
    }
  }

  /// Warning feedback.
  static Future<void> warning() async {
    final canVibrate = await Haptics.canVibrate();
    if (canVibrate) {
      await Haptics.vibrate(HapticsType.warning);
    }
  }
}
