import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider = NotifierProvider<NavigationNotifier, int>(NavigationNotifier.new);

class NavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}
