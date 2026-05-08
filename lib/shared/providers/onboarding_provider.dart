import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';

const String _onboardingKey = 'onboarding_completed';

class OnboardingChecklist {
  final bool profileCreated;
  final bool documentAdded;
  final bool notificationsEnabled;

  OnboardingChecklist({
    this.profileCreated = false,
    this.documentAdded = false,
    this.notificationsEnabled = false,
  });

  bool get allDone => profileCreated && documentAdded && notificationsEnabled;

  OnboardingChecklist copyWith({
    bool? profileCreated,
    bool? documentAdded,
    bool? notificationsEnabled,
  }) {
    return OnboardingChecklist(
      profileCreated: profileCreated ?? this.profileCreated,
      documentAdded: documentAdded ?? this.documentAdded,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final onboardingChecklistProvider = NotifierProvider<OnboardingChecklistNotifier, OnboardingChecklist>(OnboardingChecklistNotifier.new);

class OnboardingChecklistNotifier extends Notifier<OnboardingChecklist> {
  @override
  OnboardingChecklist build() => OnboardingChecklist();

  void update(OnboardingChecklist Function(OnboardingChecklist) updater) {
    state = updater(state);
  }
}

final onboardingCompletedProvider = NotifierProvider<OnboardingCompletedNotifier, bool>(OnboardingCompletedNotifier.new);

class OnboardingCompletedNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_onboardingKey, true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_onboardingKey);
    state = false;
  }
}
