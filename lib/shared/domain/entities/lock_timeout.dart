import 'package:flutter/material.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

enum LockTimeout {
  instant(Duration.zero, 'lock_timeout_instant'),
  oneMinute(Duration(minutes: 1), 'lock_timeout_1m'),
  fiveMinutes(Duration(minutes: 5), 'lock_timeout_5m'),
  fifteenMinutes(Duration(minutes: 15), 'lock_timeout_15m');

  final Duration duration;
  final String key;
  const LockTimeout(this.duration, this.key);

  String localizedLabel(BuildContext context) => context.tr(key);
}
